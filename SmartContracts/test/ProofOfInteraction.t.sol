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
    uint256 public userId = 1;
    address public invitee = address(2);
    uint256 public inviteeId = 2;
    address public treasury = address(3);
    address public admin = address(4);

    function setUp() public {
        // Deploy the mock ERC20 token
        blueToken = new BlueToken("Blue Token", "BLUE", 18);

        // Deploy the ProofOfInteraction contract
        proofOfInteraction = new ProofOfInteraction(
            address(this), // Initial owner
            10e18, // Base reward rate
            3e18, // Min reward rate
            1e18, // Ice breaker fee
            1 days, // Minimum reward interval
            address(blueToken), // Address of the mock ERC20 token
            treasury, // Treasury address
            admin, // Admin address
            65, // Time weight
            35 // Interaction count weight
        );

        // Allocate some tokens to the user and the treasury
        blueToken.mint(treasury, 2000000e18);

        // Approve the ProofOfInteraction contract to spend tokens on behalf of the user
        vm.prank(user);
        blueToken.approve(address(proofOfInteraction), 200000e18);
        vm.prank(treasury);
        // Approve the ProofOfInteraction contract to spend tokens on behalf of the treasury
        blueToken.approve(address(proofOfInteraction), 200000e18);
    }

    function hashUserIds(
        uint256 _userA,
        uint256 _userB
    ) public pure returns (uint256) {
        (uint256 userId1, uint256 userId2) = _userA < _userB
            ? (_userA, _userB)
            : (_userB, _userA);
        uint256 hashedUserIds = uint256(
            keccak256(abi.encodePacked(userId1, userId2))
        );
        return hashedUserIds;
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
        vm.prank(admin);

        proofOfInteraction.rewardUsers(
            user,
            userId,
            invitee,
            inviteeId,
            block.timestamp
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
            userId,
            inviteeId
        );
        console.log("testRewardInterval ~ interactionCount:", interactionCount);
        uint256 initialUserBalance = blueToken.balanceOf(user);
        uint256 firstRewardValue = proofOfInteraction.calculateRewards(
            hashUserIds(userId, inviteeId)
        );
        console.log(
            "~ testRewardInterval ~ firstRewardValue:",
            firstRewardValue / 1e18,
            " tokens"
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
            userId,
            inviteeId
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
        interactionCount = proofOfInteraction.getInteractionCount(
            userId,
            inviteeId
        );
        console.log("Second reward - after 28 days");

        uint256 secondRewardValue = proofOfInteraction.calculateRewards(
            hashUserIds(userId, inviteeId)
        );
        console.log(
            "~ testRewardInterval ~ secondRewardValue:",
            secondRewardValue / 1e18,
            " tokens"
        );
        testRewardUsers(true);

        lastRewardTime = proofOfInteraction.getLastRewardTime(
            userId,
            inviteeId
        );
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
            hashUserIds(userId, inviteeId)
        );
        console.log(
            "~ testRewardInterval ~ thirdRewardValue:",
            thirdRewardValue / 1e18,
            " tokens"
        );
        testRewardUsers(true);

        lastRewardTime = proofOfInteraction.getLastRewardTime(
            userId,
            inviteeId
        );
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
            hashUserIds(userId, inviteeId)
        );
        console.log(
            "~ testRewardInterval ~ fourthRewardValue:",
            fourthRewardValue / 1e18,
            " tokens"
        );
        testRewardUsers(false);

        lastRewardTime = proofOfInteraction.getLastRewardTime(
            userId,
            inviteeId
        );
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
            hashUserIds(userId, inviteeId)
        );
        console.log(
            "~ testRewardInterval ~ fifthRewardValue:",
            fifthRewardValue / 1e18,
            "tokens"
        );
        testRewardUsers(false);

        lastRewardTime = proofOfInteraction.getLastRewardTime(
            userId,
            inviteeId
        );
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
            hashUserIds(userId, inviteeId)
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
            hashUserIds(userId, inviteeId)
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
        vm.expectRevert(0x310dd4fa); // onlyAdmin();
        proofOfInteraction.rewardUsers(
            user,
            userId,
            invitee,
            inviteeId,
            block.timestamp
        );
    }

    function testUnauthorizedSetAdminCall() public {
        vm.prank(address(156)); // random user
        vm.expectRevert();
        proofOfInteraction.setAdmin(address(0));
    }

    function testSetAdmin() public {
        address newAdmin = address(10); // new consumer address
        vm.prank(address(this));
        proofOfInteraction.setAdmin(newAdmin);
        assertEq(
            proofOfInteraction.getAdminAddress(),
            newAdmin,
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
