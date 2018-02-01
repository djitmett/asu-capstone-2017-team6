<?php

//creating response array
$response = array();

if($_SERVER['REQUEST_METHOD']=='POST')
{
	if (!verifyRequiredParams(array('to_user_phone'))) 
	{

		//getting values
		$to_user_phone = $_POST['to_user_phone'];

		//including the db operation file
		$root = $_SERVER['DOCUMENT_ROOT'];
		require_once ($root . "/ioswebservice/includes/dboperations.php");

		$db = new dboperations();
		
		//inserting values 
		$result = $db->getRequestsByTo($to_user_phone);
		
		//making the response accordingly
        if ($result == NO_RESULTS)
		{
			$response['status'] = 'failure';
			$response['data'] = '';
			$response['message'] = 'No results found';
		}
		else
		{
			$response['status'] = 'success';
			$response['data'] = $result;
			$response['message'] = 'Operation successful!';
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