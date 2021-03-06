<?php

//creating response array
$response = array();

if($_SERVER['REQUEST_METHOD']=='POST')
{
	if (!verifyRequiredParams(array('user_fb_id', 'user_device_id', 'user_type', 'user_first_name', 'user_last_name', 'user_phone', 'user_email', 'user_password', 'user_avatar', 'user_join_datetime')))  
	{
		//getting values
		$user_fb_id = $_POST['user_fb_id'];
		$user_device_id = $_POST['user_device_id'];
		$user_type = $_POST['user_type'];
		$user_first_name = $_POST['user_first_name'];
		$user_last_name = $_POST['user_last_name'];
		$user_phone = $_POST['user_phone'];
		$user_email = $_POST['user_email'];
		$user_password = $_POST['user_password'];
		$user_avatar = $_POST['user_avatar'];
		$user_join_datetime = $_POST['user_join_datetime'];

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
			$result = $db->updateUserData($user_fb_id, $user_device_id, $user_type, $user_first_name, $user_last_name, $user_phone, $user_email, $user_password, $user_avatar, $user_join_datetime);

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