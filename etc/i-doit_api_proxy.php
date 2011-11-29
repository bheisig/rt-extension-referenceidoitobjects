<?php

/**
 * i-doit
 *
 * API Proxy: Act like a HTTP proxy to avoid browsers' same orgin policy.
 *
 * @package i-doit
 * @subpackage API
 * @author Benjamin Heisig <bheisig@synetics.de>
 * @version 0.1
 * @copyright synetics GmbH
 * @license http://www.i-doit.com/license
 */

ob_start();

// URL to i-doit's API:
$l_url = 'http://example.net/i-doit/index.php?api=jsonrpc';

$l_curl_handle = curl_init($l_url);
curl_setopt($l_curl_handle, CURLOPT_HEADER, 0);
curl_setopt($l_curl_handle, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt($l_curl_handle, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($l_curl_handle, CURLOPT_USERAGENT, "i-doit AJAX Proxy");

$l_content = curl_exec($l_curl_handle);
$l_content_type = curl_getinfo($l_curl_handle, CURLINFO_CONTENT_TYPE);
curl_close($l_curl_handle);

header('Content-Type: ' . $l_content_type);
echo $l_content;

ob_flush();

?>
