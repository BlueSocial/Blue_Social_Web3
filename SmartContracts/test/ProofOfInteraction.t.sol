// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ProofOfInteraction} from "../src/ProofOfInteraction.sol";
import {console} from "forge-std/console.sol";
import {MockBlueSocialConsumer} from "../test/mocks/MockBlueSocialConsumer.sol";
import {BlueToken} from "../test/mocks/BlueToken.sol";
import {Test} from "forge-std/Test.sol";

contract ProofOfInteractionTest is Test {
    ProofOfInteraction public proofOfInteraction;
    MockBlueSocialConsumer public consumerContract;
    BlueToken public blueToken;
    address public user = address(1);
    address public invitee = address(2);
    address public treasury = address(3);
    uint64 public chainlinkSubId;

    function setUp() public {
        // Deploy the mock ERC20 token
        blueToken = new BlueToken("Blue Token", "BLUE", 18);
        chainlinkSubId = 64;

        // Deploy the ProofOfInteraction contract
        proofOfInteraction = new ProofOfInteraction(
            address(this), // Initial owner
            10e18, // Reward rate
            1e18, // Ice breaker fee
            1 seconds, // Minimum reward interval
            address(blueToken), // Address of the mock ERC20 token
            treasury, // Treasury address
            address(0), // Placeholder for consumer contract address
            chainlinkSubId // Chainlink subscription ID
        );

        // Deploy the mock consumer contract
        consumerContract = new MockBlueSocialConsumer(
            address(proofOfInteraction)
        );

        // Set the consumer address in the ProofOfInteraction contract
        proofOfInteraction.setConsumer(address(consumerContract));

        // Allocate some tokens to the user and the treasury
        blueToken.mint(user, 1000e18);
        blueToken.mint(treasury, 2000000e18);

        // Approve the ProofOfInteraction contract to spend tokens on behalf of the user
        vm.prank(user);
        blueToken.approve(address(proofOfInteraction), 200000e18);
        vm.prank(treasury);
        // Approve the ProofOfInteraction contract to spend tokens on behalf of the treasury
        blueToken.approve(address(proofOfInteraction), 200000e18);
    }

    function testRewardUsers(bool swap) public {
        vm.prank(user);
        // Define call data
        string[] memory callData = new string[](3);
        callData[0] = "arg1"; // Placeholder values
        callData[1] = "arg2"; // Placeholder values
        callData[2] = "POI"; // Indicating it's a Proof of Interaction request

        bytes32 requestId = proofOfInteraction.callConsumer(
            swap ? invitee : user,
            swap ? user : invitee,
            callData
        );

        // Verify the requestId is stored correctly

        // Fetch the hashed addresses
        uint256 hashedAddresses = uint256(
            keccak256(abi.encodePacked(user, invitee))
        );
        console.log("Hashed addresses:", hashedAddresses);

        // Calculate the expected reward
        uint256 rewardValue = proofOfInteraction.calculateRewards(
            hashedAddresses
        );
        console.log("Expected reward value:", rewardValue);

        uint256 initialUserBalance = blueToken.balanceOf(user);

        // Simulate fulfilling the request
        consumerContract.fulfillRequest(
            requestId,
            abi.encode(
                "sender_id",
                "receiver_id",
                block.timestamp,
                "sender",
                "receiver",
                "POI"
            ),
            ""
        );

        // // Check the invitee's balance
        uint256 inviteeBalance = blueToken.balanceOf(invitee);
        console.log("Invitee balance after reward:", inviteeBalance);
        // assertEq(
        //     inviteeBalance,
        //     rewardValue,
        //     "Invitee received wrong amount of tokens"
        // );

        // // Check the user's balance
        uint256 userBalance = blueToken.balanceOf(user);
        console.log("User balance after reward:", userBalance);
        // assertEq(
        //     userBalance,
        //     initialUserBalance + rewardValue,
        //     "User should have received correct amount of tokens"
        // );

        uint256 userLastRewardTime = proofOfInteraction.getLastRewardTime(
            user,
            invitee
        );
        uint256 inviteeLastRewardTime = proofOfInteraction.getLastRewardTime(
            invitee,
            user
        );
        console.log("Block timestamp:", block.timestamp);
        console.log("User last reward time:", userLastRewardTime);
        console.log("Invitee last reward time:", inviteeLastRewardTime);
        console.log(
            "interaction count:",
            proofOfInteraction.getInteractionCount(user, invitee)
        );
        assertEq(
            userLastRewardTime,
            block.timestamp,
            "User's last reward time should be the current block timestamp"
        );
        assertEq(
            inviteeLastRewardTime,
            block.timestamp,
            "Invitee's last reward time should be the current block timestamp"
        );
    }

    function testRewardInterval() public {
        console.log("Testing reward interval");
        console.log("First reward");
        uint256 initialUserBalance = blueToken.balanceOf(user);
        uint256 firstRewardValue = proofOfInteraction.calculateRewards(
            uint256(keccak256(abi.encodePacked(user, invitee)))
        );
        testRewardUsers(false);
        // // Check the invitee's balance
        uint256 inviteeBalance = blueToken.balanceOf(invitee);
        console.log("Invitee balance after reward:", inviteeBalance);
        assertEq(
            inviteeBalance,
            firstRewardValue,
            "Invitee received wrong amount of tokens"
        );

        // // Check the user's balance
        uint256 userBalance = blueToken.balanceOf(user);
        console.log("User balance after reward:", userBalance);
        assertEq(
            userBalance,
            initialUserBalance + firstRewardValue,
            "User should have received correct amount of tokens"
        );
        skip(28 days);
        console.log("Second reward - after 28 days");
        uint256 secondRewardValue = proofOfInteraction.calculateRewards(
            uint256(keccak256(abi.encodePacked(user, invitee)))
        );
        testRewardUsers(true);

        // Check the invitee's balance
        inviteeBalance = blueToken.balanceOf(invitee);
        console.log("Invitee balance after reward:", inviteeBalance);
        assertEq(
            inviteeBalance,
            firstRewardValue + secondRewardValue,
            "Invitee received wrong amount of tokens"
        );

        // Check the user's balance
        userBalance = blueToken.balanceOf(user);
        console.log("User balance after reward:", userBalance);
        assertEq(
            userBalance,
            initialUserBalance + firstRewardValue + secondRewardValue,
            "User should have received correct amount of tokens"
        );

        skip(1 days);
        console.log("Third reward - after 1 day");

        uint256 thirdRewardValue = proofOfInteraction.calculateRewards(
            uint256(keccak256(abi.encodePacked(user, invitee)))
        );
        testRewardUsers(true);

        // Check the invitee's balance
        inviteeBalance = blueToken.balanceOf(invitee);
        console.log("Invitee balance after reward:", inviteeBalance);
        assertEq(
            inviteeBalance,
            firstRewardValue + secondRewardValue + thirdRewardValue,
            "Invitee received wrong amount of tokens"
        );

        // Check the user's balance
        userBalance = blueToken.balanceOf(user);
        console.log("User balance after reward:", userBalance);
        assertEq(
            userBalance,
            initialUserBalance +
                firstRewardValue +
                secondRewardValue +
                thirdRewardValue,
            "User should have received correct amount of tokens"
        );

        skip(14 days);
        console.log("Fourth reward - after 14 days");
        uint256 fourthRewardValue = proofOfInteraction.calculateRewards(
            uint256(keccak256(abi.encodePacked(user, invitee)))
        );
        testRewardUsers(false);

        // Check the invitee's balance
        inviteeBalance = blueToken.balanceOf(invitee);
        console.log("Invitee balance after reward:", inviteeBalance);
        assertEq(
            inviteeBalance,
            firstRewardValue +
                secondRewardValue +
                thirdRewardValue +
                fourthRewardValue,
            "Invitee received wrong amount of tokens"
        );

        // Check the user's balance
        userBalance = blueToken.balanceOf(user);
        console.log("User balance after reward:", userBalance);
        assertEq(
            userBalance,
            initialUserBalance +
                firstRewardValue +
                secondRewardValue +
                thirdRewardValue +
                fourthRewardValue,
            "User should have received correct amount of tokens"
        );

        skip(28 days);
        console.log("Fifth reward - after 28 days");
        uint256 fifthRewardValue = proofOfInteraction.calculateRewards(
            uint256(keccak256(abi.encodePacked(user, invitee)))
        );
        testRewardUsers(false);

        // Check the invitee's balance
        inviteeBalance = blueToken.balanceOf(invitee);
        console.log("Invitee balance after reward:", inviteeBalance);
        assertEq(
            inviteeBalance,
            firstRewardValue +
                secondRewardValue +
                thirdRewardValue +
                fourthRewardValue +
                fifthRewardValue,
            "Invitee received wrong amount of tokens"
        );

        // Check the user's balance
        userBalance = blueToken.balanceOf(user);
        console.log("User balance after reward:", userBalance);
        assertEq(
            userBalance,
            initialUserBalance +
                firstRewardValue +
                secondRewardValue +
                thirdRewardValue +
                fourthRewardValue +
                fifthRewardValue,
            "User should have received correct amount of tokens"
        );
    }

    function testIntervalTooShort() public {
        testRewardUsers(false);
        console.log("Testing reward interval too short");
        vm.expectRevert();
        testRewardUsers(false);
    }
}
