<?php declare(strict_types = 1);

use GeoIp2\Database\Reader;
use GeoIp2\Exception\AddressNotFoundException;
use MaxMind\Db\Reader\InvalidDatabaseException;

require_once '../vendor/autoload.php';

$uri = $_SERVER['REQUEST_URI'];
if (!preg_match('/^\/country\/((?:[0-9]{1,3}\.){3}[0-9]{1,3})$/', $uri, $matches)) {
    http_response_code(404);
    return;
}

try {
    $reader = new Reader('../_data/GeoIP2-Country.mmdb');
    $record = $reader->country($matches[1]);

    header('Content-Type: application/json');
    echo json_encode($record->country);
} catch (InvalidDatabaseException $e) {
    http_response_code(500);
} catch (AddressNotFoundException $e) {
    http_response_code(404);
}
