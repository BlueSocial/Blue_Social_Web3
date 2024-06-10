// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ProofOfInteraction} from "../src/ProofOfInteraction.sol";
import {BlueSocialConsumer} from "../src/BlueSocialConsumer.sol";
import {BlueToken} from "test/mocks/BlueToken.sol";

contract ProofOfInteractionTest is Test {
    ProofOfInteraction public proofOfInteraction;
    BlueSocialConsumer public consumerContract;
    BlueToken public blueToken;
    address public user = address(1);
    address public invitee = address(2);
    address public treasury = address(3);
    uint64 public chainlinkSubId;

    function setUp() public {
        // Deploy the mock ERC20 token
        blueToken = new BlueToken("Blue Token", "BLUE", 18);
        consumerContract = new BlueSocialConsumer();
        chainlinkSubId = 64;

        // Deploy the ProofOfInteraction contract
        proofOfInteraction = new ProofOfInteraction(
            address(this), // Initial owner
            10e18, // Reward rate
            1e18, // Ice breaker fee
            1 seconds, // Minimum reward interval
            address(blueToken), // Address of the mock ERC20 token
            treasury, // treasury address
            address(consumerContract), // Address of the consumer contract
            chainlinkSubId // Chainlink subscription ID
        );

        // Allocate some tokens to the user and the treasury
        blueToken.mint(user, 1000e18);
        blueToken.mint(treasury, 200000e18);

        // Approve the ProofOfInteraction contract to spend tokens on behalf of the user
        vm.prank(user);
        blueToken.approve(address(proofOfInteraction), 200000e18);
        vm.stopPrank();

        // Approve the ProofOfInteraction contract to spend tokens on behalf of the treasury
        vm.prank(treasury);
        blueToken.approve(address(proofOfInteraction), 200000e18);
        vm.stopPrank();
    }

    function testTipUser() public {
        // Simulate the user tipping the invitee
        vm.prank(user);
        proofOfInteraction.tipUser(invitee, 10e18);

        // Check the invitee's balance
        uint256 inviteeBalance = blueToken.balanceOf(invitee);
        assertEq(
            inviteeBalance,
            10e18,
            "Invitee should have received 10 tokens"
        );

        // Check the user's balance
        uint256 userBalance = blueToken.balanceOf(user);
        assertEq(userBalance, 990e18, "User should have 990 tokens left");

        console.log("User's balance:", userBalance);
        console.log("Invitee's balance:", inviteeBalance);
    }

    function testSendIceBreaker() public {
        // Simulate the user sending an ice breaker to the invitee
        uint256 iceBreakerFee = proofOfInteraction.iceBreakerFee();

        uint256 userInitialBalance = blueToken.balanceOf(user);
        uint256 treasuryInitialBalance = blueToken.balanceOf(treasury);

        blueToken.approve(address(proofOfInteraction), 1000e18);

        vm.prank(user);
        proofOfInteraction.sendIceBreaker(invitee);

        // Check the treasury's balance
        uint256 treasuryBalance = blueToken.balanceOf(treasury);
        assertEq(
            treasuryBalance,
            treasuryInitialBalance + 1e18,
            "Treasury should have received 1 token"
        );

        // Check the user's balance
        uint256 userBalance = blueToken.balanceOf(user);
        assertEq(
            userBalance,
            userInitialBalance - iceBreakerFee,
            "User should have correct balance after sending ice breaker"
        );

        console.log("User's balance:", userBalance);
        console.log("Treasury's balance:", treasuryBalance);
    }

    function testRewardUsers(string[] memory _callData) public {
        // Simulate the owner calling the rewardUsers function
        vm.prank(address(this));
        uint256 rewardValue = proofOfInteraction.calculateRewards(
            user,
            invitee
        );
        uint256 initialUserBalance = blueToken.balanceOf(user);

        proofOfInteraction.callConsumer(user, invitee, _callData);

        console.log("testRewardUsers ~ rewardValue:", rewardValue);

        // Check the invitee's balance
        uint256 inviteeBalance = blueToken.balanceOf(invitee);
        console.log(" ~ testRewardUsers ~ inviteeBalance:", inviteeBalance);
        assertEq(
            inviteeBalance,
            rewardValue,
            "Invitee received wrong amount of tokens"
        );

        // Check the user's balance
        uint256 userBalance = blueToken.balanceOf(user);
        assertEq(
            userBalance,
            initialUserBalance + rewardValue,
            "User should have received 10 tokens"
        );

        console.log("User's balance:", userBalance);
        console.log("Invitee's balance:", inviteeBalance);

        uint256 userLastRewardTime = proofOfInteraction.getLastRewardTime(
            user,
            invitee
        );
        uint256 inviteeLastRewardTime = proofOfInteraction.getLastRewardTime(
            invitee,
            user
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
}
