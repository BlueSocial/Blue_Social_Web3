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
            10e18, // Base reward rate
            3e18, // Min reward rate
            1e18, // Ice breaker fee
            1 days, // Minimum reward interval
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
        blueToken.mint(treasury, 2000000e18);

        // Approve the ProofOfInteraction contract to spend tokens on behalf of the user
        vm.prank(user);
        blueToken.approve(address(proofOfInteraction), 200000e18);
        vm.prank(treasury);
        // Approve the ProofOfInteraction contract to spend tokens on behalf of the treasury
        blueToken.approve(address(proofOfInteraction), 200000e18);
    }

    function testSendIceBreaker() public {
        // Send an ice breaker request
        blueToken.mint(user, 1000e18);
        uint256 initialUserBalance = blueToken.balanceOf(user);
        uint256 initialTreasuryBalance = blueToken.balanceOf(treasury);
        vm.prank(user);
        proofOfInteraction.sendIceBreaker(invitee);

        // Check the user's balance
        uint256 userBalance = blueToken.balanceOf(user);
        console.log("User balance after ice breaker:", userBalance);
        assertEq(
            userBalance,
            initialUserBalance - 1e18,
            "User should have spent 1 token"
        );

        // Check the treasury's balance
        uint256 treasuryBalance = blueToken.balanceOf(treasury);
        console.log("Treasury balance after ice breaker:", treasuryBalance);
        assertEq(
            treasuryBalance,
            initialTreasuryBalance + 1e18,
            "Treasury should have received 1 token"
        );
    }

    function testInsufficientBalanceIceBreaker() public {
        vm.prank(user);
        vm.expectRevert(); // InsufficientBalance()
        proofOfInteraction.sendIceBreaker(invitee);
    }

    function testTipUser() public {
        blueToken.mint(user, 1000e18);
        uint256 initialUserBalance = blueToken.balanceOf(user);

        vm.prank(user);
        proofOfInteraction.tipUser(invitee, 10e18);

        // Check the user's balance
        uint256 userBalance = blueToken.balanceOf(user);
        console.log("User balance after tip:", userBalance);
        assertEq(
            userBalance,
            initialUserBalance - 10e18,
            "User should have spent 10 token"
        );

        // Check the treasury's balance
        uint256 inviteeBalance = blueToken.balanceOf(invitee);
        console.log("Invitee balance after tip:", inviteeBalance);
        assertEq(
            inviteeBalance,
            10e18,
            "Invitee should have received 10 token"
        );
    }

    function testInsufficientBalanceTipUser() public {
        vm.prank(user);
        vm.expectRevert(); // InsufficientBalance()
        proofOfInteraction.tipUser(invitee, 10e18);
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
    }

    /**
     * @notice Test the reward interval and the reward calculation. The min reward interval is set to 1 day.
     * The user and invitee will interact multiple times and the reward will be calculated based on the reward interval and interaction count.
     */
    function testRewardInterval() public {
        console.log("Testing reward interval");
        console.log("First reward");
        uint256 interactionCount = proofOfInteraction.getInteractionCount(
            user,
            invitee
        );
        console.log("testRewardInterval ~ interactionCount:", interactionCount);
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

        uint256 lastRewardTime = proofOfInteraction.getLastRewardTime(
            user,
            invitee
        );
        assertEq(
            lastRewardTime,
            block.timestamp,
            "Last reward time should be updated"
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

        lastRewardTime = proofOfInteraction.getLastRewardTime(user, invitee);
        assertEq(
            lastRewardTime,
            block.timestamp,
            "Last reward time should be updated"
        );

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

        skip(2 days);
        console.log("Third reward - after 1 day");

        uint256 thirdRewardValue = proofOfInteraction.calculateRewards(
            uint256(keccak256(abi.encodePacked(user, invitee)))
        );
        testRewardUsers(true);

        lastRewardTime = proofOfInteraction.getLastRewardTime(user, invitee);
        assertEq(
            lastRewardTime,
            block.timestamp,
            "Last reward time should be updated"
        );

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

        lastRewardTime = proofOfInteraction.getLastRewardTime(user, invitee);
        assertEq(
            lastRewardTime,
            block.timestamp,
            "Last reward time should be updated"
        );

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

        lastRewardTime = proofOfInteraction.getLastRewardTime(user, invitee);
        assertEq(
            lastRewardTime,
            block.timestamp,
            "Last reward time should be updated"
        );

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

    /**
     * @notice Test the reward interval and the reward calculation. The min reward interval is set to 1 day. The first reward and second rewards should execute successfully. The third reward should fail because the reward interval is too short.
     */
    function testIntervalTooShort() public {
        uint256 userInitialBalance = blueToken.balanceOf(user);
        uint256 inviteeInitialBalance = blueToken.balanceOf(invitee);
        uint256 firstRewardValue = proofOfInteraction.calculateRewards(
            uint256(keccak256(abi.encodePacked(user, invitee)))
        );
        testRewardUsers(false);

        assertEq(
            blueToken.balanceOf(user),
            userInitialBalance + firstRewardValue,
            "User should have received correct amount of tokens"
        );

        assertEq(
            blueToken.balanceOf(invitee),
            inviteeInitialBalance + firstRewardValue,
            "Invitee should have received correct amount of tokens"
        );

        console.log("Testing reward interval too short");
        skip(1 days);
        uint256 secondRewardValue = proofOfInteraction.calculateRewards(
            uint256(keccak256(abi.encodePacked(user, invitee)))
        );
        testRewardUsers(true);

        assertEq(
            blueToken.balanceOf(user),
            userInitialBalance + firstRewardValue + secondRewardValue,
            "User should have received correct amount of tokens"
        );

        assertEq(
            blueToken.balanceOf(invitee),
            inviteeInitialBalance + firstRewardValue + secondRewardValue,
            "Invitee should have received correct amount of tokens"
        );

        skip(300 minutes);
        vm.expectRevert(0x90ce7105); // RewardIntervalError()
        testRewardUsers(false);

        assertEq(
            blueToken.balanceOf(user),
            userInitialBalance + firstRewardValue + secondRewardValue,
            "User should have received correct amount of tokens"
        );

        assertEq(
            blueToken.balanceOf(invitee),
            inviteeInitialBalance + firstRewardValue + secondRewardValue,
            "Invitee should have received correct amount of tokens"
        );
    }

    function testUnauthorizedRewardUsersCall() public {
        vm.prank(user);
        vm.expectRevert(0x4c341eef); // onlyConsumer();
        proofOfInteraction.rewardUsers(bytes32(0));
    }

    function testUnauthorizedSetConsumerCall() public {
        vm.prank(address(156)); // random user
        vm.expectRevert();
        proofOfInteraction.setConsumer(address(0));
    }

    function testSetConsumer() public {
        address newConsumer = address(10); // new consumer address
        vm.prank(address(this));
        proofOfInteraction.setConsumer(newConsumer);
        assertEq(
            proofOfInteraction.getConsumerAddress(),
            newConsumer,
            "Consumer not set"
        );
    }

    function testUnauthorizedSetRewardRateCall() public {
        vm.prank(address(156)); // random user
        vm.expectRevert();
        proofOfInteraction.setBaseRewardRate(10e18);
    }

    function testSetRewardRate() public {
        uint256 newRewardRate = 20e18;
        vm.prank(address(this));
        proofOfInteraction.setBaseRewardRate(newRewardRate);
        assertEq(
            proofOfInteraction.getBaseRewardRate(),
            newRewardRate,
            "Reward rate not set"
        );
    }
}
