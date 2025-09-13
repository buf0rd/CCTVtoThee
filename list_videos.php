<?php
header('Content-Type: application/json');

// Get ZIP code from query parameter and sanitize it
$zip = isset($_GET['zip']) ? preg_replace('/[^0-9]/', '', $_GET['zip']) : '';
$dir = __DIR__ . "/zipcode/$zip";

$videos = [];

if (!$zip) {
    echo json_encode(["error" => "No ZIP code provided"]);
    exit;
}

if (!is_dir($dir)) {
    echo json_encode(["error" => "Directory for ZIP code $zip does not exist"]);
    exit;
}

// Scan for video files including MKV
foreach (scandir($dir) as $file) {
    if (preg_match('/\.(mp4|webm|ogg|mkv)$/i', $file)) {
        $videos[] = "/zipcode/$zip/$file";
    }
}

if (empty($videos)) {
    echo json_encode(["error" => "No video files found in ZIP code $zip"]);
} else {
    echo json_encode($videos);
}
