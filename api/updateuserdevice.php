<?php

//creating response array
$response = array();

if($_SERVER['REQUEST_METHOD']=='POST')
{
	if (!verifyRequiredParams(array('user_device_id', 'user_phone')))  
	{
		//getting values
		$user_device_id = $_POST['user_device_id'];
		$user_phone = $_POST['user_phone'];

		if ($user_phone == null)
		{
            $response['status'] = 'fail';
			$response['data'] = $_POST[1];
			$response['message'] = 'No user given';
        } 
        else
        {
			//including the db operation file
			$root = $_SERVER['DOCUMENT_ROOT'];
			require_once ($root . "/ioswebservice/includes/dboperations.php");

			$db = new dboperations();
			
			//inserting values 
			$result = $db->updateUserDevice($user_device_id, $user_phone);

			//making the response accordingly
	        if ($result == USER_UPDATED) 
			{
	            $response['status'] = 'success';
				$response['data'] = '';
				$response['message'] = 'Data updated successfully!';
	        } 
			else
			if ($result == USER_DOESNT_EXIST) 
			{
	            $response['status'] = 'failure';
				$response['data'] = '';
	            $response['message'] = 'INVALID USER';
	        }
			else
			if ($result == USER_NOT_UPDATED) 
			{
	            $response['status'] = 'failure';
				$response['data'] = '';
	            $response['message'] = 'Some error occurred!';
	        }
	       	else
			{
	           $response['status'] = 'failure';
				$response['data'] = '';
	           $response['message'] = 'untrapped error';
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