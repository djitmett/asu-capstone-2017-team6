<?php

//creating response array
$response = array();

if($_SERVER['REQUEST_METHOD']=='POST')
{
	if (!verifyRequiredParams(array('req_from_user_phone', 'req_to_user_phone')))
	{

		//getting values
		$req_ID = $_POST['req_ID'];
		$req_from_user_phone = $_POST['req_from_user_phone'];
		$req_to_user_phone = $_POST['req_to_user_phone'];
		$req_expire_datetime = $_POST['req_expire_datetime'];
		$req_expire_location_latitude = $_POST['req_expire_location_latitude'];
		$req_expire_location_longitude = $_POST['req_expire_location_longitude'];
		$req_create_datetime = date('Y-m-d H:i:s');
		$req_status = 'PENDING';
		$req_status_change_datetime = $_POST['req_status_change_datetime'];

		//including the db operation file
		$root = $_SERVER['DOCUMENT_ROOT'];
		require_once ($root . "/ioswebservice/includes/dboperations.php");

		$db = new dboperations();
		
		//inserting values 
		$result = $db->addRequest($req_ID, $req_from_user_phone, $req_to_user_phone, $req_expire_datetime, $req_expire_location_latitude, $req_expire_location_longitude, $req_create_datetime, $req_status, $req_status_change_datetime);
		
		//making the response accordingly
        if ($result == REQUEST_ADDED) 
		{
            $response['status'] = 'success';
			$response['data'] = '';
			$response['message'] = 'Data added successfully!';
        } 
		else 
	    if ($result == REQUEST_NOT_ADDED) 
		{
            $response['status'] = 'failure';
			$response['data'] = '';
            $response['message'] = 'Error occured during add';
        } 
	}
	else 
	{
        $response['status'] = 'failure';
		$response['data'] = '';
        $response['message'] = 'Required parameters are missing (From, To)!';
	}	
}
else
{
	$response['status'] = 'failure';
    $response['data'] = '';
    $response['message'] = 'Invalid request!';
}

//function to validate the required parameter in request
function verifyRequiredParams($required_fields)
{
    //Getting the request parameters
    $request_params = $_REQUEST;
 
    //Looping through all the parameters
    foreach ($required_fields as $field) 
	{
        //if any requred parameter is missing
        if (!isset($request_params[$field]) || strlen(trim($request_params[$field])) <= 0) 
		{
            //returning true;
            return true;
        }
    }
    return false;
}

echo json_encode($response);
?>