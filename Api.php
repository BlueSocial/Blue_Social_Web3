<?php
if (!defined('BASEPATH')) exit('No direct script access allowed');

class Api extends CI_Controller {

	private $userId;
	private $resType = 'json';
	private $aLgs = array('enable' => true);

	public function __construct(){

		parent::__construct();
		$req_method = $this->input->server('REQUEST_METHOD');
		if ($req_method != 'POST' && $req_method != 'GET'){
			redirect(base_url("home"));
		}
   	
		$method = $this->router->fetch_method(); 
		
		if($req_method == 'POST') {
			$jInput = file_get_contents('php://input');
			if(!empty($jInput)){
				$aInput = json_decode($jInput, true);
				if ($aInput) {
					foreach($aInput as $k => $v){
						$_POST[$k] = $v;
					}
				}
			}
		}
		
		$this->userId = $this->app->auth();
		$this->load->library('form_validation');
	}

	// public Methods
	public function routeHandler(){

		$this->benchmark->mark('start');
		try {
			$aUriSegment = $this->uri->segment_array();
			array_shift($aUriSegment);
			$method = $aUriSegment[0];
			$aValidResTypes = array("json", "array", "str");
			array_shift($aUriSegment);
			if (isset($aUriSegment[count($aUriSegment)-1]) && in_array($aUriSegment[count($aUriSegment)-1], $aValidResTypes)) {
				$this->resType = $aUriSegment[count($aUriSegment)-1];
				array_pop($aUriSegment);
			}
			if (!method_exists($this , $method)) {
				throw new Exception("Error invalid Route.");
			}

			$res = call_user_func(array($this, $method), $aUriSegment);
		} catch (Exception $e) {
			$res = array("success" => false, "msg" => $e->getMessage());
		}
		$this->benchmark->mark('end');
		switch ($this->resType) {
			case 'json':
				if ($this->aLgs['enable']) {
					if (!$res['success']) {
						$this->aLgs['aOpt']['logs']['msg'] = @$res['msg'];
					}
					$this->aLgs['aOpt']['logs']['success'] = @$res['success'];
					$this->aLgs['aOpt']['logs']['execTime'] = $this->benchmark->elapsed_time('start', 'end');
					$this->app->writeUserLogs($this->aLgs['aOpt']);
				}
				echo json_encode($res);
				break;
			case 'array':
				return $res;
				break;
			case 'str':
				echo $res;
				break;
		}
	}

	public function poirewardUsers()
	{
		$aPost = $this->input->post();
		$aConf = array(
			array(
				'field' => 'sender_id',
				'label' => 'Sender Id',
				'rules' => 'required'
			),
			array(
				'field' => 'receiver_id',
				'label' => 'Receiver Id',
				'rules' => 'required'
			),
			array(
				'field' => 'sender_address',
				'label' => 'Sender Address',
				'rules' => 'required'
			),
			array(
				'field' => 'receiver_address',
				'label' => 'Receiver Address',
				'rules' => 'required'
			),
			array(
				'field' => 'timestamp',
				'label' => 'Timestamp',
				'rules' => 'required'
			)
		);

		$this->form_validation->set_rules($aConf);
		if ($this->form_validation->run() == FALSE) {
			$aError = $this->form_validation->error_array();
			$error 	= '';
			foreach ($aError as $k => $v) {
				$error .= $v.', ';
			}
			throw new Exception('Error : '.$error);
		}

		$senderId = $aPost['sender_id'];
		$receiverId = $aPost['receiver_id'];
		$senderAddress = $aPost['sender_address'];
		$receiverAddress = $aPost['receiver_address'];

		$date = new DateTime($aPost['timestamp']);
        if (!$date) {

            $this->output
                ->set_content_type('application/json')
                ->set_output(json_encode(['message' => 'Invalid timestamp']))
                ->set_status_header(400);
            return;
        }

        $unixTimestamp = $date->getTimestamp();

        try {

            $postData = [
                'functionName' => 'rewardUsers',
                'args' => [
                    $senderAddress,
                    (int) $senderId,
                    $receiverAddress,
                    (int) $receiverId,
                    $unixTimestamp,
                ],
                'txOverrides' => [
                    'gas' => '530000',
                    'maxFeePerGas' => '1000000000',
                    'maxPriorityFeePerGas' => '1000000000',
                ],
                'abi' => [
                    [
                        'inputs' => [
                            ['internalType' => 'address', 'name' => '_senderAddress', 'type' => 'address'],
                            ['internalType' => 'uint256', 'name' => '_senderId', 'type' => 'uint256'],
                            ['internalType' => 'address', 'name' => '_receiverAddress', 'type' => 'address'],
                            ['internalType' => 'uint256', 'name' => '_receiverId', 'type' => 'uint256'],
                            ['internalType' => 'uint256', 'name' => '_timestamp', 'type' => 'uint256'],
                        ],
                        'stateMutability' => 'nonpayable',
                        'type' => 'function',
                        'name' => 'rewardUsers',
                    ],
                ],
            ];

            $access_token = $this->config->item('tw_access_token');
	        $backend_wallet = $this->config->item('tw_backend_wallet');
	        $engine_url = $this->config->item('tw_engine_url');
	        $chain = $this->config->item('chain');
	        $poi_address = $this->config->item('poicontract_address');

            $headers = [
                'Accept: application/json',
                'Content-Type: application/json',
                'Authorization: Bearer ' . $access_token,
                'x-backend-wallet-address: ' . $backend_wallet,
                'ngrok-skip-browser-warning: true',
            ];

            $apiUrl = $engine_url."/contract/".$chain."/".$poi_address."/write";

            // Initialize cURL session
            $ch = curl_init($apiUrl);

            // Set cURL options
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($postData));

            // Execute the request
            $response = curl_exec($ch);

            // Check for errors
            if (curl_errno($ch)) {
                $error_message = curl_error($ch);
                curl_close($ch);

                // Return error response
                $this->output
                    ->set_content_type('application/json')
                    ->set_output(json_encode([
                        'message' => 'Error setting up the request: ' . $error_message
                    ]))
                    ->set_status_header(500);

                return;
            }

            // Close cURL session
            curl_close($ch);

            // Decode the response
            $responseBody = json_decode($response, true);

            // Check for HTTP errors
            if (isset($responseBody['error'])) {

                $this->output
                    ->set_content_type('application/json')
                    ->set_output(json_encode([
                        'message' => 'Error posting data: ' . $responseBody['error']['message']
                    ]))
                    ->set_status_header(400);

                return;
            }

            // Successful request
            $this->output
                ->set_content_type('application/json')
                ->set_output(json_encode(['message' => 'Request successfully sent.']))
                ->set_status_header(200);
               return;
        } catch (Exception $e) {
            $this->output
                ->set_content_type('application/json')
                ->set_output(json_encode(['message' => $e->getMessage()]))
                ->set_status_header(500);
        }
	}

	public function pocexchangeContact()
	{
		$aPost = $this->input->post();
		$aConf = array(
			array(
				'field' => 'user_id',
				'label' => 'User Id',
				'rules' => 'required|'.$this->aRules['id']
			),
			array(
				'field' => 'contact_id',
				'label' => 'Contact Id',
				'rules' => 'required|'.$this->aRules['id']
			),
			array(
				'field' => 'user_address',
				'label' => 'User Address',
				'rules' => 'required'
			),
			array(
				'field' => 'contact_address',
				'label' => 'Contact Address',
				'rules' => 'required'
			)
		);

		$this->form_validation->set_rules($aConf);
		if ($this->form_validation->run() == FALSE) {
			$aError = $this->form_validation->error_array();
			$error 	= '';
			foreach ($aError as $k => $v) {
				$error .= $v.', ';
			}
			throw new Exception('Error : '.$error);
		}

		$userId = $aPost['user_id'];
		$contactId = $aPost['contact_id'];
		$userAddress = $aPost['user_address'];
		$contactAddress = $aPost['contact_address'];

		if(empty($userAddress)) {
			$userAddress = $this->config->item('treasury');
		}

		if(empty($contactAddress)) {
			$contactAddress = $this->config->item('treasury');
		}

		// Prepare the post data
        $postData = [
            'functionName' => 'exchangeContact',
            'args' => [
                $userAddress,
                (int) $userId,
                $contactAddress,
                (int) $contactId,
            ],
            'txOverrides' => [
                'gas' => '530000',
                'maxFeePerGas' => '1000000000',
                'maxPriorityFeePerGas' => '1000000000',
            ],
            'abi' => [
                [
                    'type' => 'function',
                    'name' => 'exchangeContact',
                    'inputs' => [
                        ['name' => '_userAddress', 'type' => 'address', 'internalType' => 'address'],
                        ['name' => '_userId', 'type' => 'uint256', 'internalType' => 'uint256'],
                        ['name' => '_contactAddress', 'type' => 'address', 'internalType' => 'address'],
                        ['name' => '_contactId', 'type' => 'uint256', 'internalType' => 'uint256'],
                    ],
                    'outputs' => [],
                    'stateMutability' => 'nonpayable',
                ],
            ],
        ];

        $access_token = $this->config->item('tw_access_token');
        $backend_wallet = $this->config->item('tw_backend_wallet');
        $engine_url = $this->config->item('tw_engine_url');
        $chain = $this->config->item('chain');
        $exc_address = $this->config->item('exc_contract_address');

        // Set the headers
        $headers = [
            'Accept: application/json',
            'Content-Type: application/json',
            'Authorization: Bearer ' . $access_token,
            'x-backend-wallet-address: ' . $backend_wallet,
            'ngrok-skip-browser-warning: true',
        ];

        // API URL
        $apiUrl = $engine_url."/contract/".$chain."/".$exc_address."/write";

        // Initialize cURL session
        $ch = curl_init($apiUrl);

        // Set cURL options
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($postData));

        // Execute the request
        $response = curl_exec($ch);

        // Check for errors
        if (curl_errno($ch)) {
            $error_message = curl_error($ch);
            curl_close($ch);

            // Return error response
            $this->output
                ->set_content_type('application/json')
                ->set_output(json_encode([
                    'message' => 'Error setting up the request: ' . $error_message
                ]))
                ->set_status_header(500);

            return;
        }

        // Close cURL session
        curl_close($ch);

        // Decode the response
        $responseBody = json_decode($response, true);

        // Check for HTTP errors
        if (isset($responseBody['error'])) {

            $this->output
                ->set_content_type('application/json')
                ->set_output(json_encode([
                    'message' => 'Error posting data: ' . $responseBody['error']['message']
                ]))
                ->set_status_header(400);

            return;
        }

        // Successful request
        $this->output
            ->set_content_type('application/json')
            ->set_output(json_encode(['message' => 'Request successfully sent.']))
            ->set_status_header(200);
	}
}