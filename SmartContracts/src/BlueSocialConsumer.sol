// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {ProofOfInteraction} from "./ProofOfInteraction.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/resources/link-token-contracts/
 */

/**
 * @title GettingStartedFunctionsConsumer
 * @notice This is an example contract to show how to make HTTP requests using Chainlink
 * @dev This contract uses hardcoded values and should not be used in production.
 */
contract BlueSocialConsumer is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;
    bytes public encryptedSecretsUrls;
    ProofOfInteraction public proofOfInteraction;

    struct Message {
        string sender_id;
        string receiver_id;
        uint256 timestamp;
        string sender;
        string receiver;
        string requestType;
    }
    // Custom error type

    error UnexpectedRequestID(bytes32 requestId);

    // Event to log responses
    event Response(bytes32 indexed requestId, Message message, bytes response, bytes err);

    // Router address - Hardcoded for Sepolia
    // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    address router = 0xf9B8fc078197181C841c296C876945aaa425B278;

    // JavaScript source code
    // Fetch character name from the Star Wars API.
    // Documentation: https://swapi.info/people
    string poiProofSource = "const sender = args[0];" "const receiver = args[1];" "const requestType = args[2];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url:`https://www.profiles.blue/api/getProofOfInteractionData?SenderAddress=${sender}&ReceiverAddress=${receiver}`"
        "});" "if(apiResponse.error){" "console.error(apiResponse.error);" "throw new Error(apiResponse.error);" "}"
        "const { data } = apiResponse;" "const sender_id = data.sender_id;" "const receiver_id = data.receiver_id;"
        "const timestamp = data.timestamp;" "const unixTimestamp = Math.floor(new Date(timestamp) / 1000);"
        "const resultString = JSON.stringify({ sender_id, receiver_id, timestamp: unixTimestamp ,sender, receiver, requestType});"
        "const encodedResult = Functions.encodeString(resultString);" "return encodedResult;";

    string exchangeProofSource = "const sender = args[0];" "const receiver = args[1];"
        "const requestType = args[2];" "const apiResponse = await Functions.makeHttpRequest({"
        "url:`https://www.profiles.blue/api/getInteractionBstData?SenderAddress=${sender}&ReceiverAddress=${receiver}`"
        "});" "if(apiResponse.error){" "console.error(apiResponse.error);" "throw new Error(apiResponse.error);" "}"
        "const { data } = apiResponse;" "const sender_id = data.sender_id;" "const receiver_id = data.receiver_id;"
        "const timestamp = data.timestamp;" "const unixTimestamp = Math.floor(new Date(timestamp) / 1000);"
        "const resultString = JSON.stringify({ sender_id, receiver_id, timestamp: unixTimestamp ,sender, receiver,requestType});"
        "const encodedResult = Functions.encodeString(resultString);" "return encodedResult;";

    //Callback gas limit
    uint32 gasLimit = 300000;

    // donID - Hardcoded for Sepolia
    // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    bytes32 donID = 0x66756e2d626173652d7365706f6c69612d310000000000000000000000000000;

    /**
     * @notice Initializes the contract with the Chainlink router address and sets the contract owner
     */
    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

    /**
     * @notice Sends an HTTP request for amount information
     * @param subscriptionId The ID for the Chainlink subscription
     * @param args The arguments to pass to the HTTP request
     * @return requestId The ID of the request
     */
    function sendRequest(uint64 subscriptionId, string[] calldata args)
        external
        onlyOwner
        returns (bytes32 requestId)
    {
        FunctionsRequest.Request memory req;
        string memory requestType = args[2];
        //requesttype is 3rd argument and should be POI or EXC
        if (keccak256(abi.encodePacked(requestType)) == keccak256("POI")) {
            req.initializeRequestForInlineJavaScript(poiProofSource); // Initialize the request with corresponding JS code
        } else {
            req.initializeRequestForInlineJavaScript(exchangeProofSource); // Initialize the request with corresponding JS code
        }
        if (encryptedSecretsUrls.length > 0) {
            req.addSecretsReference(encryptedSecretsUrls);
        }
        if (args.length > 0) req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestId = _sendRequest(req.encodeCBOR(), subscriptionId, gasLimit, donID);

        return s_lastRequestId;
        // use use mapping to store the requestid request[requestid] = user address
    }

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     * @param err Any errors from the Functions request
     */
    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        //TODO: Verify the need for this logic
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }

        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;

        // Decode the bytes into the expected types
        (
            string memory sender_id,
            string memory receiver_id,
            uint256 timestamp,
            string memory sender,
            string memory receiver,
            string memory requestType
        ) = abi.decode(response, (string, string, uint256, string, string, string));

        Message memory message = Message({
            sender_id: sender_id,
            receiver_id: receiver_id,
            timestamp: timestamp,
            sender: sender,
            receiver: receiver,
            requestType: requestType
        });
        s_lastError = err;

        //TODO: check for error

        // Handle the response based on the request type
        if (keccak256(abi.encodePacked(requestType)) == keccak256("POI")) {
            // Call function from ProofOfInteraction contract to reward users
            proofOfInteraction.rewardUsers(requestId);
        } else {
            // Call function from Exchange contract (Assumed functionality)
        }

        // Emit an event to log the response
        emit Response(requestId, message, s_lastResponse, s_lastError);
    }

    /**
     * @notice Changes js code snippet
     * @param _source The js snippet for chainlink functions
     */
    function setSource(string memory requestType, string memory _source) external onlyOwner {
        if (keccak256(abi.encodePacked(requestType)) == keccak256("POI")) {
            poiProofSource = _source;
        } else {
            exchangeProofSource = _source;
        }
    }

    /**
     * @notice Changes donID
     * @param id The new donID
     */
    function setDonId(bytes32 id) external onlyOwner {
        donID = id;
    }

    /**
     * @notice Changes encryptedurl based on gist url
     * @param url The new gist url
     */
    function setEncryptedUrls(bytes memory url) external onlyOwner {
        encryptedSecretsUrls = url;
    }
}
