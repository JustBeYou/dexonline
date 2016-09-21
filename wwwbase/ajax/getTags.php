<?php
require_once("../../phplib/util.php");

$query = Request::get('term');

$tags = Model::factory('Tag')
      ->where_like('value', "%{$query}%")
      ->order_by_asc('value')
      ->limit(10)
      ->find_many();

$resp = ['results' => []];
foreach ($tags as $t) {
  $resp['results'][] = [
    'id' => $t->id,
    'text' => $t->value,
  ];
}

header('Content-Type: application/json');
print json_encode($resp);

?>
