<?php

// set headers for csv download
$interactive = false;
if ($interactive) {
  $br = "<br>";
  $limit = 10;
} else {
  $br = "\n";
  $limit = 100; // max 200, slow load
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

// fetch user's info
$data = $api->showUser($id);
$image_url = $data["user"]["image_url"];
$user_name = $data["user"]["name"];

// gets most recent read books
$data = $api->getLatestReads($id, 'date_read', $limit, 1);

// extract desired fields from reviews
$reviews = $data['reviews']['review'];
$table = array();
foreach ($reviews as $i => $review) {
  $row = array();
  //var_dump($review);
  $row["url"] = 'https://www.goodreads.com/review/show/'.$review["id"];
  $row["my_rating"] = $review["rating"];
  $row["started_at"] = is_array($review["started_at"]) ? "NA" : date('Y-m-d', strtotime($review["started_at"]));
  $row["read_at"] = is_array($review["read_at"]) ? "NA" : date('Y-m-d', strtotime($review["read_at"]));
  $row["title"] = '"'.$review["book"]["title"].'"';
  $row["num_pages"] = is_array($review["book"]["num_pages"]) ? "NA" : $review["book"]["num_pages"];
  $row["author_id"] = $review["book"]["authors"]["author"]["id"];
  $row["author_name"] = $review["book"]["authors"]["author"]["name"];
  $row["publication_year"] = is_array($review["book"]["publication_year"]) ? "NA" : $review["book"]["publication_year"];
  $row["avg_rating"] = $review["book"]["average_rating"];
  $row["my_name"] = $user_name;
  $row["my_face"] = $image_url;
  $table[] = $row;
}

// fetch author details (slow)
foreach ($table as $i => $row) {
  $data = $api->getAuthor($row["author_id"]);
  $table[$i]["author_gender"] = is_array($data["author"]["gender"]) ? "NA" : $data["author"]["gender"];
}

// echo results as csv
echo implode(',',array_keys($table[0]));
foreach ($table as $i => $row) {
  echo $br;
  echo implode(',',$row);
}

?>
