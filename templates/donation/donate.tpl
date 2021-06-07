{extends "layout-admin.tpl"}

{block "title"}Donează{/block}

{block "content"}
  <div>
    <h3>Donează</h3>

    <p>
      Dacă ai ajuns pe această pagină, probabil că știi deja ce este <i>dexonline</i>
      (dacă nu, poți afla din
      <a
        href="https://wiki.dexonline.ro/wiki/Informa%C8%9Bii"
        target="_blank">pagina de informații</a>). Poți contribui la
      dezvoltarea proiectului <i>dexonline</i> și prin donarea unei sume de bani.
    </p>

    <div class="row">
      {if $haveEuPlatescCredentials}
        <div class="col-lg mb-3">
          <div class="card border-info paymentSection">
            <div
              class="card-header text-white bg-info"
              title="Comision fix de 3,5% la donațiile online și 9-18% la cele prin SMS">
              Donează online sau prin SMS
              {include "bits/icon.tpl" i=info class="float-end"}
            </div>
            <div class="card-body">
              <form
                id="donateOnline"
                action="{Router::link('donation/donateEP')}"
                method="post"
                enctype="multipart/form-data">
                <div class="row mb-3">
                  <label for="donateOnlineAmount" class="col-sm-3 col-form-label">Suma</label>
                  <div class="col-sm-9">
                    <select
                      id="donateOnlineAmount"
                      name="amount"
                      class="form-select">
                      <option value="10">10 lei</option>
                      <option value="20">20 lei</option>
                      <option value="50" selected>50 lei</option>
                      <option value="100">100 lei</option>
                      <option value="150">150 lei</option>
                      <option value="200">200 lei</option>
                      <option value="250">250 lei</option>
                    </select>
                  </div>
                </div>
                <div class="row mb-3">
                  <label
                    for="donateOnlineEmail"
                    title="e-mailul este necesar pentru trimiterea confirmării plății"
                    class="col-sm-3 col-form-label">
                    E-mail *
                  </label>
                  <div class="col-sm-9">
                    <input
                      id="donateOnlineEmail"
                      type="text"
                      name="email"
                      value="{$defaultEmail}"
                      class="form-control">
                  </div>
                </div>
                <div class="text-center">
                  <input type="submit" name="Doneaza" value="" class="onlineDonationButton btn">
                </div>
              </form>
            </div>
          </div>
        </div>
      {/if}

      <div class="col-lg mb-3">
        <div class="card border-info paymentSection">
          <div
            class="card-header text-white bg-info"
            title="Comision mediu 6,5% (10% la donații de 5€, 4% la 25€)">
            Donează prin PayPal
            {include "bits/icon.tpl" i=info class="float-end"}
          </div>
          <div class="card-body text-center">
            <form action="https://www.paypal.com/cgi-bin/webscr" method="post" class="payPal">
              <input type="hidden" name="cmd" value="_s-xclick">
              <input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----
                ">
              <input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
              <img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">
            </form>
          </div>
        </div>
      </div>

      <div class="col-lg mb-3">
        <div class="card border-info paymentSection">
          <div
            class="card-header text-white bg-info"
            title="Comisionul este oprit la trimitere">
            Donează prin transfer bancar
            {include "bits/icon.tpl" i=info class="float-end"}
          </div>
          <div class="card-body">
            <div class="mb-1">
              <strong class="me-2">Beneficiar</strong> Asociația dexonline
            </div>
            <div class="mb-1">
              <strong class="me-2">CIF</strong> 30855345
            </div>
            <div class="mb-1">
              <strong class="me-2">Adresa</strong> strada Remetea nr. 20, București, sector 2
            </div>
            <div class="mb-1">
              <strong class="me-2">Cont</strong> Banca Transilvania, sucursala Obor
            </div>
            <div class="mb-1">
              <strong class="me-2">RON</strong> RO96 BTRL 0440 1205 M306 19XX
            </div>
          </div>
        </div>
      </div>
    </div>

    {include "bits/doneaza-doi-la-suta.tpl"}
    {include "bits/doneaza-la-ce-folosim.tpl"}
    {include "bits/doneaza-firme.tpl"}
    {include "bits/doneaza-rasplata.tpl"}
  </div>
{/block}
