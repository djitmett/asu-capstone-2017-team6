<?php

//creating response array
$response = array();

if($_SERVER['REQUEST_METHOD']=='POST')
{
	if (!verifyRequiredParams(array('user_phone'))) 
	{

		//getting values
		$user_phone = $_POST['user_phone'];

		//including the db operation file
		$root = $_SERVER['DOCUMENT_ROOT'];
		require_once ($root . "/ioswebservice/includes/dboperations.php");

		$db = new dboperations();
		
		//inserting values 
		$result = $db->getUserLocation($user_phone);
		
		//making the response accordingly
        if ($result == USER_NOT_EXIST)
		{
			$response['status'] = 'failure';
			$response['data'] = '';
			$response['message'] = 'User does not exist!';
		}
		else
		if ($result == LOCATION_NOT_FOUND) 
		{
            $response['status'] = 'failure';
			$response['data'] = '';
            $response['message'] = 'Some error occurred!';
        }
		else
		{
			$response['status'] = 'success';
			$response['data'] = $result;
			$response['message'] = 'Operation successfully!';
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