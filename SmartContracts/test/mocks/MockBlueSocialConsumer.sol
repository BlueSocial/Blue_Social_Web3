// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ProofOfInteraction} from "../../src/ProofOfInteraction.sol";

/**
 * @title MockBlueSocialConsumer
 * @dev Mock contract for simulating BlueSocialConsumer interactions with ProofOfInteraction contract
 */
contract MockBlueSocialConsumer {
    ProofOfInteraction public proofOfInteraction;
    bytes32 public lastRequestId;
    bytes public lastResponse;
    bytes public lastError;

    constructor(address _proofOfInteraction) {
        proofOfInteraction = ProofOfInteraction(_proofOfInteraction);
    }

    /**
     * @notice Mock function to simulate sending a Chainlink request
     * @param subscriptionId The ID for the Chainlink subscription
     * @param args The arguments to pass to the Chainlink request
     * @return requestId The ID of the request
     */
    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external returns (bytes32 requestId) {
        // Mock request initialization
        string memory requestType = args[2];
        // Simulating different responses based on requestType
        if (keccak256(abi.encodePacked(requestType)) == keccak256("POI")) {
            lastRequestId = bytes32(
                uint256(keccak256(abi.encodePacked(block.timestamp)))
            );
            lastResponse = abi.encode(
                "sender_id",
                "receiver_id",
                block.timestamp,
                "sender",
                "receiver",
                requestType
            );
            lastError = "";
        } else {
            // Simulate different type of request
            revert("Unsupported request type");
        }

        return lastRequestId;
    }

    /**
     * @notice Mock function to simulate fulfilling a Chainlink request
     * @param requestId The ID of the request to fulfill
     * @param response The simulated HTTP response data
     * @param err Any simulated errors from the Chainlink request
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) external {
        // Store the response and error
        lastResponse = response;
        lastError = err;

        // Handle the response based on the request type
        if (lastRequestId != requestId) {
            revert("Unexpected request ID");
        }

        (, , , , , string memory requestType) = abi.decode(
            response,
            (string, string, uint256, string, string, string)
        );

        if (keccak256(abi.encodePacked(requestType)) == keccak256("POI")) {
            // Call function from ProofOfInteraction contract to reward users
            proofOfInteraction.rewardUsers(requestId);
        } else {
            // Handle other types of requests
            revert("Unsupported request type");
        }
    }

    /**
     * @notice Mock function to get the last request ID
     */
    function getLastRequestId() external view returns (bytes32) {
        return lastRequestId;
    }

    /**
     * @notice Mock function to get the last response
     */
    function getLastResponse() external view returns (bytes memory) {
        return lastResponse;
    }

    /**
     * @notice Mock function to get the last error
     */
    function getLastError() external view returns (bytes memory) {
        return lastError;
    }
}
