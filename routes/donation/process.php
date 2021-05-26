<?php
User::mustHave(User::PRIV_DONATION);

const OTRS_DONATION_EMAIL_REGEX =
  '/^Mesaj raspuns: (Approved|SMS Pending Transaction).*' .
  '^3. PRET: (?<amount>[0-9.]+) RON.*' .
  '^   EMAIL: (?<email>[^\n]+)$/ms';

class Donor {
  // inclusive to the left, exclusive to the right
  const RANGE_MEDAL = [ [ 20, INF ] ];
  const RANGE_NO_BANNERS = [ [ 50, INF ] ];
  const RANGE_STICKER = [ [ 100, 150 ] ];
  const RANGE_LAPEL_PIN = [ [ 150, 200 ], [ 250, INF ] ];
  const RANGE_TEE = [ [ 200, INF ] ];

  const EMAIL_AMOUNT_THRESHOLD = 20;
  const EMAIL_YES = 0;         // this user should get an email response
  const EMAIL_LOW_AMOUNT = 1;  // no donations for amounts under EMAIL_AMOUNT_THRESHOLD
  const EMAIL_BAD_ADDRESS = 2; // email is incorrect (e.g. for SMS donations)  public $email;

  const EMAIL_REASON = [
    self::EMAIL_YES => '', // shouldn't ever need to read this value
    self::EMAIL_LOW_AMOUNT => 'Pentru sume mici nu este necesar să trimitem mesaj.',
    self::EMAIL_BAD_ADDRESS => 'Adresa de e-mail a donatorului pare incorectă.',
  ];

  public $amount;
  public $date;
  public $source;
  public $sendEmail;
  public $description;
  public $user;
  public $textMessage;
  public $htmlMessage;
  public $valid;

  function __construct($email, $amount, $date, $source, $sendEmail, $description) {
    $this->email = $email;
    $this->amount = $amount;
    $this->date = $date;
    $this->source = $source;
    $this->sendEmail = $sendEmail;
    $this->description = $description;
  }

  /**
   * @param array $arr One of the RANGE_ constants above.
   */
  function needsReward($arr) {
    foreach ($arr as $pair) {
      if (($this->amount >= $pair[0]) && ($this->amount < $pair[1])) {
        return true;
      }
    }
    return false;
  }

  function needsMaterialReward() {
    return
      $this->needsReward(self::RANGE_STICKER) ||
      $this->needsReward(self::RANGE_LAPEL_PIN) ||
      $this->needsReward(self::RANGE_TEE);
  }

  function needsEmail() {
    if (!filter_var($this->email, FILTER_VALIDATE_EMAIL)) {
      return self::EMAIL_BAD_ADDRESS;
    } else if ($this->amount < self::EMAIL_AMOUNT_THRESHOLD) {
      return self::EMAIL_LOW_AMOUNT;
    } else {
      return self::EMAIL_YES;
    }
  }

  // returns a description of the reason why this donor doesn't need an email
  function getEmailReason() {
    return self::EMAIL_REASON[$this->needsEmail()];
  }

  function validate() {
    $this->valid = $this->email && $this->amount && $this->date;

    if (!$this->valid) {
      FlashMessage::add("Donatorul {$this} nu poate fi procesat pentru că are câmpuri vide.");
    }

    return $this->valid;
  }

  function prepare() {
    $this->user = User::get_by_email($this->email);

    Smart::assign('donor', $this);

    if ($this->needsEmail() == self::EMAIL_YES) {
      $this->textMessage = Smart::fetch('email/donationThankYouTxt.tpl');
      $this->htmlMessage = Smart::fetch('email/donationThankYouHtml.tpl');
    }
  }

  function process() {
    if ($this->sendEmail) {
      $from = Config::CONTACT_EMAIL;
      $subject = 'Mulțumiri';

      try {
        Mailer::setRealMode();
        Mailer::send($from, [ $this->email ], $subject, $this->textMessage, $this->htmlMessage);
      } catch (Exception $e) {
        FlashMessage::add(sprintf('Emailul către %s a eșuat: %s',
                                  $this->email, $e->getMessage()));
      }
    }

    if ($this->user) {
      if ($this->needsReward(self::RANGE_MEDAL)) {
        $this->user->medalMask |= Medal::MEDAL_SPONSOR;
        $this->user->save();
      }
      if ($this->needsReward(self::RANGE_NO_BANNERS)) {
        $this->user->noAdsUntil = strtotime('+1 year');
        $this->user->save();
      }
    }

    $donation = Model::factory('Donation')->create();
    $donation->email = $this->email;
    $donation->amount = $this->amount;
    $donation->date = $this->date;
    $donation->userId = User::getActiveId();
    $donation->source = $this->source;
    $donation->emailSent = $this->sendEmail;
    $donation->save();
  }

  function __toString() {
    return (string)$this->description;
  }
}

class OtrsDonor extends Donor {
  public $ticketId;

  function __construct($email, $amount, $date, $source, $sendEmail, $ticketId) {
    parent::__construct($email, $amount, $date, $source, $sendEmail, $ticketId);
    $this->ticketId = $ticketId;
  }

  function process() {
    parent::process();
    OtrsApiClient::closeTicket($this->ticketId);
  }

  function __toString() {
    return "tichet ID={$this->ticketId}";
  }
}

abstract class DonationProvider {
  protected $donors;

  function getDonors() {
    return $this->donors;
  }

  function prepareDonors() {
    foreach ($this->donors as $d) {
      $d->prepare();
    }
  }

  function processDonors() {
    foreach ($this->donors as $d) {
      $d->process();
    }
  }
}

class OtrsDonationProvider extends DonationProvider {

  function __construct() {

    // get ticket IDs from the donation queue and save them for postprocessing
    $response = OtrsApiClient::searchTickets([
      'Queues' => 'ONG',
      'States' => 'new',
      'From' => '%@euplatesc.ro',
    ]);

    $ticketIds = isset($response->TicketID) ? $response->TicketID : [];
    $this->donors = [];

    // get the body for each ticket and, if it matches a donation email, build a new donor
    foreach ($ticketIds as $tid) {
      $ticket = OtrsApiClient::getTicket($tid);
      if (!$ticket ||
          !property_exists($ticket, 'Ticket') ||
          empty($ticket->Ticket) ||
          !property_exists($ticket->Ticket[0], 'Article') ||
          empty($ticket->Ticket[0]->Article)) {
        throw new Exception('Răspuns incorect de la OTRS');
      }
      $article = $ticket->Ticket[0]->Article[0];
      $created = $ticket->Ticket[0]->Created;
      $from = $article->From;
      $body = $article->Body;

      if (preg_match(OTRS_DONATION_EMAIL_REGEX, $body, $match)) {

        $d = new OtrsDonor($match['email'],
                           $match['amount'],
                           explode(' ', $created)[0], // just the date part
                           Donation::SOURCE_OTRS,
                           true,
                           $tid);
        $d->validate();
        $this->donors[] = $d;
      }
    }
  }

}

class ManualDonationProvider extends DonationProvider {

  function __construct($emails, $amounts, $dates, $sendEmail) {
    $this->donors = [];
    foreach ($emails as $i => $e) {
      if ($e || $amounts[$i] || $dates[$i]) {
        $s = in_array($i, $sendEmail);
        $d = new Donor($e, $amounts[$i], $dates[$i], Donation::SOURCE_MANUAL, $s, $i + 1);
        $d->validate();
        $this->donors[] = $d;
      }
    }
  }

  function getDonors() {
    return $this->donors;
  }
}

class OtrsApiClient {
  const METHOD_GET = 'GET';
  const METHOD_POST = 'POST';
  const METHOD_PATCH = 'PATCH';

  static function restQuery($page, $params, $method = self::METHOD_GET) {
    // add the login credentials
    $params['UserLogin'] = Config::OTRS_LOGIN;
    $params['Password'] = Config::OTRS_PASSWORD;

    $url = sprintf('%s/%s', Config::OTRS_REST_URL, $page);

    if ($method == SELF::METHOD_GET) {
      // URL-encode the params
      $getArgs = [];
      foreach ($params as $key => $value) {
        $getArgs[] = "{$key}=" . urlencode($value);
      }

      $url .= '?' . implode('&', $getArgs);
      list($response, $httpCode) = Util::fetchUrl($url);

    } else {
      $jsonData = json_encode($params);
      list($response, $httpCode) = Util::makeRequest($url, $jsonData, $method);
    }

    if ($httpCode != 200) {
      throw new Exception('Eroare la comunicarea cu OTRS');
    }

    return json_decode($response);
  }

  static function getTicket($ticketId) {
    return self::restQuery('TicketGet', [
      'TicketID' => $ticketId,
      'AllArticles' => '1',
    ]);
  }

  static function closeTicket($ticketId) {
    return self::restQuery('TicketUpdate', [
      'TicketID' => $ticketId,
      'Ticket' => [
        'State' => 'closed successful',
      ],
    ], self::METHOD_PATCH);
  }

  static function searchTickets($params) {
    return self::restQuery('TicketSearch', $params);
  }

}

function readManualDonorData() {
  $emails = Request::getArray('email');
  $amounts = Request::getArray('amount');
  $dates = Request::getArray('date');

  $sendEmail = [];
  foreach ($emails as $i => $e) {
    if (Request::has("manualSendMessage_{$i}")) {
      $sendEmail[] = $i;
    }
  }

  return new ManualDonationProvider($emails, $amounts, $dates, $sendEmail);
}

/********************************* main *********************************/

$previewButton = Request::has('previewButton');
$processButton = Request::has('processButton');
$backButton = Request::has('backButton');
$includeOtrs = Request::has('includeOtrs');

if ($processButton) {
  if ($includeOtrs) {
    $odp = new OtrsDonationProvider();
    $odp->prepareDonors();

    $processTicketIds = Request::getArray('processTicketId');
    $messageTicketIds = Request::getArray('messageTicketId');
    foreach ($odp->getDonors() as $d) {
      if (in_array($d->ticketId, $processTicketIds)) {
        $d->sendEmail = in_array($d->ticketId, $messageTicketIds);
        $d->process();
      }
    }
  }

  $mdp = readManualDonorData();
  $mdp->prepareDonors();
  $mdp->processDonors();
  FlashMessage::add('Am procesat donațiile. Dacă au existat utilizatori care au primit ' .
                    'medalii și/sau scutiri de bannere, nu uitați să goliți parțial cache-ul ' .
                    'lui Varnish: <b>sudo varnishadm ban req.url "~" ^/utilizator</b>',
                    'success');
  Util::redirectToSelf();

} else if ($previewButton) {
  if ($includeOtrs) {
    $odp = new OtrsDonationProvider();
    $odp->prepareDonors();
    Smart::assign('otrsDonors', $odp->getDonors());
  }

  $mdp = readManualDonorData();
  $mdp->prepareDonors();
  Smart::assign('manualDonors', $mdp->getDonors());
  Smart::assign('includeOtrs', $includeOtrs);

  if (FlashMessage::hasErrors()) {
    Smart::display('donation/process.tpl');
  } else {
    Smart::display('donation/process2.tpl');
  }

} else if ($backButton) {

  $mdp = readManualDonorData();
  Smart::assign('manualDonors', $mdp->getDonors());
  Smart::assign('includeOtrs', $includeOtrs);
  Smart::display('donation/process.tpl');

} else {

  Smart::display('donation/process.tpl');

}
