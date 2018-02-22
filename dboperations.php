<?php

class dboperations
{
    private $conn;

    //Constructor
    function __construct()
    {
        require_once dirname(__FILE__) . '/config.php';
        require_once dirname(__FILE__) . '/dbconnect.php';
        // opening db connection
        $db = new dbconnect();
        $this->conn = $db->connect();
    }
	
	public function checkUserExistsByPhone($user_phone)
	{		
        $stmt = $this->conn->prepare("SELECT user_id FROM users WHERE user_phone = ?");
        $stmt->bind_param("s", $user_phone);
        $stmt->execute();
        $stmt->store_result();
		
        return $stmt->num_rows > 0;
		
		echo $stmt->error;
		$stmt->close();
	}
	
	public function getUserIdByPhone($user_phone)
	{		
	    if ($this->checkUserExistsByPhone($user_phone))
		{
			$stmt = $this->conn->prepare("SELECT user_id FROM users WHERE user_phone = ?");
			$stmt->bind_param("s", $user_phone);
			
			if ($stmt->execute()) 
			{
			    $result = $stmt->get_result();
				$user_id = $result->fetch_array(MYSQLI_NUM);
            }
			else
			{
                return ID_NOT_FOUND;
            }
		}
		else
		{
            return USER_NOT_EXIST;
        }
		
		return $user_id;
		
		echo $stmt->error;
		$stmt->close();
	}

    //Function to create a new user
    public function addUserData($user_fb_id, $user_device_id, $user_type, $user_first_name, $user_last_name, $user_phone, $user_email, $user_password, $user_avatar, $user_join_datetime)
    {
		if (!$this->checkUserExistsByPhone($user_phone))
		{
			$stmt = $this->conn->prepare("INSERT INTO users(user_fb_id, user_device_id, user_type, user_first_name, user_last_name, user_phone, user_email, user_password, user_avatar, user_join_datetime) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
			$stmt->bind_param("ssssssssss", $user_fb_id, $user_device_id, $user_type, $user_first_name, $user_last_name, $user_phone, $user_email, $user_password, $user_avatar, $user_join_datetime);
			
			if ($stmt->execute()) 
			{
                return USER_CREATED;
            } 
			else
			{
                return USER_NOT_CREATED;
            }
		}
		else 
		{
            return USER_ALREADY_EXIST;
        }
		
		echo $stmt->error;
	    $stmt->close();
    }
	
	public function getUserData($user_phone)
	{
		$user_id = $this->getUserIdByPhone($user_phone)[0];
		
		if ($this->checkUserExistsByPhone($user_phone))
		{
			$stmt = $this->conn->prepare("SELECT user_fb_id, user_device_id, user_first_name, user_last_name, user_phone, user_password, user_email, user_avatar, user_join_datetime, user_id FROM users WHERE user_id = ?");
			$stmt->bind_param("i", $user_id);
			
			if ($stmt->execute()) 
			{
			    $result = $stmt->get_result();
				$data = $result->fetch_array(MYSQLI_NUM);
            }
			else
			{
                return USER_NOT_FOUND;
            }
		}
		else
		{
            return USER_NOT_EXIST;
        }
		
		return $data;
		
		echo $stmt->error;
		$stmt->close();
	}
	
	public function addUserLocation($user_phone, $location_latitude, $location_longitude, $location_datetime)
	{
		$user_id = $this->getUserIdByPhone($user_phone)[0];
		
		if ($this->checkUserExistsByPhone($user_phone))
		{
			$stmt = $this->conn->prepare("INSERT INTO locations(location_user_id, location_latitude, location_longitude, location_datetime) values (?, ?, ?, ?)");
			$stmt->bind_param("isss", $user_id, $location_latitude, $location_longitude, $location_datetime);
			
			if ($stmt->execute()) 
			{
                return LOCATION_CREATED;
            } 
			else
			{
                return LOCATION_NOT_CREATED;
            }
		}
		else
		{
            return USER_NOT_EXIST;
        }
	}
	
	public function getUserLocation($user_phone)
	{
		$user_id = $this->getUserIdByPhone($user_phone)[0];
		
		if ($this->checkUserExistsByPhone($user_phone))
		{
			$stmt = $this->conn->prepare("SELECT location_latitude, location_longitude, location_datetime FROM locations WHERE location_user_id = ? ORDER BY location_id DESC LIMIT 1");
			$stmt->bind_param("i", $user_id);
			
			if ($stmt->execute()) 
			{
			    $result = $stmt->get_result();
				$location = $result->fetch_array(MYSQLI_NUM);
            }
			else
			{
                return LOCATION_NOT_FOUND;
            }
		}
		else
		{
            return USER_NOT_EXIST;
        }
		
		return $location;
		
		echo $stmt->error;
		$stmt->close();
	}

	//Function to create a new request
    public function addRequest($req_ID, $req_from_user_phone, $req_to_user_phone, $req_expire_datetime, $req_expire_location_latitude, $req_expire_location_longitude, $req_create_datetime, $req_status, $req_status_change_datetime)
    {
		$stmt = $this->conn->prepare("INSERT INTO requests(req_ID, req_from_user_phone, req_to_user_phone, req_expire_datetime, req_expire_location_latitude, req_expire_location_longitude, req_create_datetime, req_status, req_status_change_datetime) values (?, ?, ?, ?, ?, ?, ?, ?, ?)");
		$stmt->bind_param("sssssssss", $req_ID, $req_from_user_phone, $req_to_user_phone, $req_expire_datetime, $req_expire_location_latitude, $req_expire_location_longitude, $req_create_datetime, $req_status, $req_status_change_datetime);
		
		if ($stmt->execute()) 
		{
            return REQUEST_ADDED;
        } 
		else
		{
            return REQUEST_NOT_ADDED;
        }
		echo $stmt->error;
	    $stmt->close();
    }

	public function getRequestsByFrom($from_user_phone)
	{
		$stmt = $this->conn->prepare("SELECT requests.*, users.user_first_name, users.user_last_name FROM requests INNER JOIN users WHERE req_from_user_phone =? AND users.user_phone = req_from_user_phone ORDER BY requests.req_create_datetime");
		$stmt->bind_param("i", $from_user_phone);
		
		if ($stmt->execute()) 
		{
		    $result = $stmt->get_result();
			$requests = $result->fetch_all(MYSQLI_NUM);
        }
		else
		{
            return NO_RESULTS;
        }

		return $requests;
		
		echo $stmt->error;
		$stmt->close();
	}

	public function getRequestsByTo($to_user_phone)
	{
		$stmt = $this->conn->prepare("SELECT requests.*, users.user_first_name, users.user_last_name FROM requests INNER JOIN users WHERE req_to_user_phone =? AND users.user_phone = req_to_user_phone ORDER BY requests.req_create_datetime");
		$stmt->bind_param("i", $to_user_phone);
		
		if ($stmt->execute()) 
		{
		    $result = $stmt->get_result();
			$requests = $result->fetch_all(MYSQLI_NUM);
        }
		else
		{
            return NO_RESULTS;
        }

		return $requests;
		
		echo $stmt->error;
		$stmt->close();
	}

	//Function to update request status
    public function updateRequestByID($req_ID, $req_status, $req_status_change_datetime)
    {
		$stmt = $this->conn->prepare("UPDATE requests set req_status=?, req_status_change_datetime=? where req_ID=?");
		$stmt->bind_param("sss", $req_status, $req_status_change_datetime, $req_ID);
		
		if ($stmt->execute()) 
		{
            return RID_UPDATED;
        } 
		else
		{
            return RID_NOT_FOUND;
        }
		echo $stmt->error;
	    $stmt->close();
    }

   
    //Function to update a user's device ID
    public function updateUserDevice($user_device_id, $user_phone)
    {
		if ($this->checkUserExistsByPhone($user_phone))
		{
			$stmt = $this->conn->prepare("UPDATE users set user_device_id=? WHERE user_phone=?");
			$stmt->bind_param("ss", $user_device_id, $user_phone);
			if ($stmt->execute()) 
			{
                return USER_UPDATED;
            } 
			else
			{
                return USER_NOT_UPDATED;
            }
		}
		else 
		{
           return USER_DOESNT_EXIST;
        }
		
		echo $stmt->error;
	    $stmt->close();
    }

     //Function to update an existing user
    public function updateUserData($user_fb_id, $user_device_id, $user_type, $user_first_name, $user_last_name, $user_phone, $user_email, $user_password, $user_avatar, $user_join_datetime)
    {
		if ($this->checkUserExistsByPhone($user_phone))
		{
			$stmt = $this->conn->prepare("UPDATE users set user_fb_id=?, user_device_id=?, user_type=?, user_first_name=?, user_last_name=?, user_phone=?, user_email=?, user_password=?, user_avatar=?, user_join_datetime=? WHERE user_phone=?");
			$stmt->bind_param("sssssssssss", $user_fb_id, $user_device_id, $user_type, $user_first_name, $user_last_name, $user_phone, $user_email, $user_password, $user_avatar, $user_join_datetime, $user_phone);
			if ($stmt->execute()) 
			{
                return USER_UPDATED;
            } 
			else
			{
                return USER_NOT_UPDATED;
            }
		}
		else 
		{
           return USER_DOESNT_EXIST;
        }
		
		echo $stmt->error;
	    $stmt->close();
    }
}
?>