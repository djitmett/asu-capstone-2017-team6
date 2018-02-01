<?php

//creating response array
$response = array();

if($_SERVER['REQUEST_METHOD']=='POST')
{
	if (!verifyRequiredParams(array('req_ID', 'req_status'))) 
	{

		//getting values
		$req_ID = $_POST['req_ID'];
		$req_status = $_POST['req_status'];
		$req_status_change_datetime = date('Y-m-d H:i:s');

		//including the db operation file
		$root = $_SERVER['DOCUMENT_ROOT'];
		require_once ($root . "/ioswebservice/includes/dboperations.php");

		$db = new dboperations();
		
		//inserting values 
		$result = $db->updateRequestByID($req_ID, $req_status, $req_status_change_datetime);
		
		//making the response accordingly
        if ($result == RID_NOT_FOUND)
		{
			$response['status'] = 'failure';
			$response['data'] = '';
			$response['message'] = 'RID does not exist!';
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