<?php

class UploadUtils {
  static function csv_to_array($filename = '', $delimiter = '|')
  {
    $data = [];

    if (file_exists($filename) && is_readable($filename)) {
      $header = NULL;
      if (($handle = fopen($filename, 'r')) !== FALSE) {
        while (($row = fgetcsv($handle, 1000, $delimiter)) !== FALSE) {
          if (!$header) {
            $header = $row;
          } else {
            $data[] = array_combine($header, $row);
          }
        }
        fclose($handle);
      }
    }
    return $data;
  }

  // converts an array of associative arrays to an array of objects.
  static function csv_to_objects($csv, $sourceId, $userId) {
    $results = [];
    foreach ($csv as $row) {
      $results[] = process_row($sourceId, $userId, $row);
    }
    return $results;
  }

  static function processPage() {
    $sourceId = Request::get('source');
    $saveButton = Request::has('saveButton');
    $cancelButton = Request::has('cancelButton');
    $delimiter = Request::get('delimiter') ?: '|';
    $csvFile = Request::getFile('file');

    $userId = User::getActiveId();
    $csv = Session::get('csv', []);


    try {
      if ($csvFile) {
        if ($csvFile['error'] !== UPLOAD_ERR_OK) {
          throw new UploadException($csvFile['error']);
        } else {
          if ($csvFile['tmp_name'] != '') {
            //getting an array for csv file contents
            $csv = UploadUtils::csv_to_array($csvFile['tmp_name'], $delimiter);

            // stashing the array for saving operation
            Session::set('csv', $csv);
          }
        }
      }
    } catch (Exception $e) {
      FlashMessage::add($e->getMessage());
    }

    if ($saveButton) {
      if (count($csv) > 0) { // process the array only if we have some data

        $numSuccess = $numErrors = 0;
        foreach ($csv as $row) { // handle each row
          $obj = process_row($sourceId, $userId, $row);

          try {
            $obj->save();
            $numSuccess++;
          } catch (Exception $e) {
            FlashMessage::add($e->getMessage);
            $numErrors++;
          }
        }

        $message = sprintf(MSG_SUCCESS, $numSuccess);
        $class = 'success';
        if ($numErrors) {
          $message .= " Alte {$numErrors} au generat erori.";
          $class = 'warning';
        }
        FlashMessage::add($message, $class);
      }
      $cancelButton = true;
    } else {
      if ($csvFile && $csvFile['name'] != '' && !FlashMessage::hasErrors()) {
        $message = sprintf('Fișierul %s (%s linii) a fost încărcat.', $csvFile['name'], count($csv));
        $class = FlashMessage::hasErrors() ? 'warning' : 'success';
        FlashMessage::add($message, $class);
      }
    }

    if ($cancelButton) {
      Session::unsetVar('csv');
      $csv = [];
    }

    return $csv;
  }
}
