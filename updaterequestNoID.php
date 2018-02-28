<?php

//creating response array
$response = array();

if($_SERVER['REQUEST_METHOD']=='POST')
{
	if (!verifyRequiredParams(array('req_status', 'req_from_user_phone', 'req_to_user_phone')))
	{
		$testing='Q';
		if ($testing == 'X')
		{
			$req_status = $_POST['req_status'];
			$req_status_change_datetime = date('Y-m-d H:i:s');
			$req_from_user_phone = $_POST['req_from_user_phone'];
			$req_to_user_phone = $_POST['req_to_user_phone'];

			$response['status'] = 'testing';
			$response['data'] = $req_from_user_phone;
			$response['message'] = 'Testing successful!';
		}
		else
		{
			//getting values
			$req_status = $_POST['req_status'];
			$req_status_change_datetime = date('Y-m-d H:i:s');
			$req_from_user_phone = $_POST['req_from_user_phone'];
			$req_to_user_phone = $_POST['req_to_user_phone'];

			//including the db operation file
			$root = $_SERVER['DOCUMENT_ROOT'];
			require_once ($root . "/ioswebservice/includes/dboperations.php");

			$db = new dboperations();
			
			//inserting values 
			$result = $db->updateRequestNoID($req_status, $req_status_change_datetime, $req_from_user_phone, $req_to_user_phone);
			
			//making the response accordingly
	        if ($result == RID_UPDATED)
			{
				$response['status'] = 'success';
				$response['data'] = $result;
				$response['message'] = 'Operation successful!';
			}
			else
			{
				$response['status'] = 'failure';
				$response['data'] = $result;
				$response['message'] = 'Record does not exist!';
			}
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