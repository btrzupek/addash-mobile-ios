<?php
$data = file_get_contents('php://input');
file_put_contents('/tmp/rawpost',$data);
$posted_hmac = $_POST['signature'];
$posted_data = $_POST['payload'];
if($_POST['advId'] == '*209d5fae8b2ba427d30650dd0250942ae944a0d5') {
    $key = "athirtytwobytekeyisthislong!!!!!";
}
$hmac = hash_hmac('sha256',$posted_data,$key,false);
if($hmac == $posted_hmac) {
    file_put_contents('/tmp/test.txt',"Valid:\n".print_r(json_decode($posted_data),true));
} else {
    file_put_contents('/tmp/test.txt',"Invalid. Got HMAC $hmac:\n".print_r($_POST,true));
}

?>
