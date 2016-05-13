<?php

$interactive = false;
if ($interactive) {
  $br = "\n";
  $limit = 100;
  header("Content-type: text/csv");
  header("Content-Disposition: attachment; filename=file.csv");
  header("Pragma: no-cache");
  header("Expires: 0");
}

// load library
include 'GoodReads.php';
$api = new GoodReads('PUT YOUR API KEY HERE', 'tmp');
global $api;
$id = $_GET['id'];

// fetch user's info from author id
$data = $api->showAuthor($id);
if (array_key_exists("author", $data) && array_key_exists("user", $data["author"]) && array_key_exists("id", $data["author"]["user"])) {
  echo $data["author"]["user"]["id"]."\n";
} else {
  echo "NA\n";
}

?>
