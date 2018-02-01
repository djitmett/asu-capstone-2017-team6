<?php

//creating response array
$response = array();

if($_SERVER['REQUEST_METHOD']=='POST')
{
	if (!verifyRequiredParams(array('user_phone', 'location_latitude', 'location_longitude', 'location_datetime'))) 
	{

		//getting values
		$user_phone = $_POST['user_phone'];
		$location_latitude = $_POST['location_latitude'];
		$location_longitude = $_POST['location_longitude'];
		$location_datetime = $_POST['location_datetime'];

		//including the db operation file
		$root = $_SERVER['DOCUMENT_ROOT'];
		require_once ($root . "/ioswebservice/includes/dboperations.php");

		$db = new dboperations();
		
		//inserting values 
		$result = $db->addUserLocation($user_phone, $location_latitude, $location_longitude, $location_datetime);
		
		//making the response accordingly
        if ($result == LOCATION_CREATED) 
		{
            $response['status'] = 'success';
			$response['data'] = '';
			$response['message'] = 'Data added successfully!';
        } 
		else
		if ($result == LOCATION_NOT_CREATED) 
		{
            $response['status'] = 'failure';
			$response['data'] = '';
            $response['message'] = 'Some error occurred!';
        }
		else 
		if ($result == USER_NOT_EXIST)
		{
			$response['status'] = 'failure';
			$response['data'] = '';
			$response['message'] = 'User does not exist!';
		} 
	}
	else 
	{
        $response['status'] = 'failure';
		$response['data'] = '';
        $response['message'] = 'Required parameters are missing!';
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