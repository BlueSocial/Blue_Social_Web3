// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title ProofOfInteraction
 * @author Hone1er
 * @notice A contract that rewards users for Proof of Interaction
 */
contract ProofOfInteraction is Ownable, ReentrancyGuard {
    ///////////////////////////////////////////////////////////
    /*                    */
    /*  ADDING LIBRARIES  */
    /*                    */
    ///////////////////////////////////////////////////////////

    using SafeERC20 for IERC20;

    ///////////////////////////////////////////////////////////
    /*                    */
    /*  TYPE DEFINITIONS  */
    /*                    */
    ///////////////////////////////////////////////////////////
    struct Interaction {
        uint128 interactionCount; // uint128 to pack the struct into 32 bytes
        uint128 lastRewardTime;
    }

    ///////////////////////////////////////////////////////////
    /*                   */
    /*  STATE VARIABLES  */
    /*                   */
    ///////////////////////////////////////////////////////////

    IERC20 immutable i_blueToken;
    address private s_treasury;
    address private s_blueSocialAdmin;
    uint256 private s_timeWeight;
    uint256 private s_interactionCountWeight;

    uint256 public baseRewardRate;
    uint256 public minReward;
    uint256 public iceBreakerFee;
    uint256 public minimumRewardInterval;

    mapping(uint256 hashedUserIds => Interaction) public userInteractions;
    ///////////////////////////////////////////////////////////
    /*        */
    /* EVENTS */
    /*        */
    ///////////////////////////////////////////////////////////

    event TipSent(
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );
    event RewardUser(address indexed user, uint256 reward);
    event BalanceWithdrawn(address indexed owner, uint256 amount);
    event IceBreakerSent(address indexed user, address indexed invitee);

    ///////////////////////////////////////////////////////////
    /*          */
    /*  ERRORS  */
    /*          */
    ///////////////////////////////////////////////////////////

    error RewardTransferFailedError();
    error RewardIntervalError();
    error IceBreakerFeeError();
    error OnlyAdminError();
    error InteractionError();
    error TipUserError();
    error WithdrawalError();

    ///////////////////////////////////////////////////////////
    /*             */
    /*  MODIFIERS  */
    /*             */
    ///////////////////////////////////////////////////////////

    modifier onlyAfterRewardInterval(uint256 _userA, uint256 _userB) {
        uint256 hashedUserIds = hashUserIds(_userA, _userB);
        if (
            block.timestamp - userInteractions[hashedUserIds].lastRewardTime <
            minimumRewardInterval &&
            userInteractions[hashedUserIds].interactionCount > 0
        ) {
            revert RewardIntervalError();
        }
        _;
    }

    modifier onlyAdmin() {
        if (msg.sender != s_blueSocialAdmin) {
            revert OnlyAdminError();
        }
        _;
    }

    ///////////////////////////////////////////////////////////
    /*             */
    /*  FUNCTIONS  */
    /*             */
    ///////////////////////////////////////////////////////////

    /**
     *
     * @param initialOwner address of the owner of the contract
     * @param _baseRewardRate reward rate for the users
     * @param _minReward minimum reward value
     * @param _iceBreakerFee fee to send an ice breaker
     * @param _minimumRewardInterval minimum time interval between rewards
     * @param _blueToken address of the BLUE token
     * @param _treasury address of the treasury
     * @param _admin address of the Admin contract
     * @param _timeWeight weight for the time-based reward
     * @param _interactionCountWeight weight for the interaction count-based reward
     * @dev Constructor for the ProofOfInteraction contract
     */
    constructor(
        address initialOwner,
        uint256 _baseRewardRate,
        uint256 _minReward,
        uint256 _iceBreakerFee,
        uint256 _minimumRewardInterval,
        address _blueToken,
        address _treasury,
        address _admin,
        uint256 _timeWeight,
        uint256 _interactionCountWeight
    ) Ownable(initialOwner) {
        iceBreakerFee = _iceBreakerFee;
        baseRewardRate = _baseRewardRate;
        minReward = _minReward;
        minimumRewardInterval = _minimumRewardInterval;
        i_blueToken = IERC20(_blueToken);
        s_treasury = _treasury;
        s_blueSocialAdmin = _admin;
        s_timeWeight = _timeWeight;
        s_interactionCountWeight = _interactionCountWeight;
    }

    /**
     *
     * @param _invitee address of the user to send the ice breaker to
     * @dev Sends an ice breaker fee to the treasury and emits an event
     */
    function sendIceBreaker(address _invitee) public nonReentrant {
        i_blueToken.safeTransferFrom(msg.sender, s_treasury, iceBreakerFee);
        emit IceBreakerSent(msg.sender, _invitee);
    }

    /**
     * @param _senderAddress address of the sender
     * @param _senderId user id of the sender
     * @param _receiverAddress address of the receiver
     * @param _receiverId user id of the receiver
     * @param _timestamp timestamp of the interaction
     * @dev Rewards multiple users with the calculated reward rate
     *
     */
    function rewardUsers(
        address _senderAddress,
        uint256 _senderId,
        address _receiverAddress,
        uint256 _receiverId,
        uint256 _timestamp
    )
        public
        nonReentrant
        onlyAdmin
        onlyAfterRewardInterval(_senderId, _receiverId)
    {
        uint256 hashedUserIds = hashUserIds(_senderId, _receiverId);
        uint256 rewardValue = calculateRewards(hashedUserIds);

        userInteractions[hashedUserIds].lastRewardTime = uint128(_timestamp);
        incrementInteractionCount(hashedUserIds);

        rewardUser(_senderAddress, rewardValue);
        rewardUser(_receiverAddress, rewardValue);
    }

    /**
     *
     * @param _userA address of the user to reward
     * @param _rewardValue reward value to send to the user
     * @dev Rewards a user with the reward rate
     *
     * @notice This function is only callable by the owner and after the reward interval has passed since the last reward
     */

    function rewardUser(address _userA, uint256 _rewardValue) internal {
        i_blueToken.safeTransferFrom(s_treasury, _userA, _rewardValue);
        emit RewardUser(_userA, _rewardValue);
    }

    /**
     *
     * @param _user address of the user to tip
     * @param _amount amount to tip the user in BLUE tokens
     * @dev Tips a user with the specified amount of BLUE tokens
     */
    function tipUser(address _user, uint256 _amount) external nonReentrant {
        i_blueToken.safeTransferFrom(msg.sender, _user, _amount);
        emit TipSent(msg.sender, _user, _amount);
    }

    /**
     * @param _userA user ID of the first user
     * @param _userB user ID of the second user
     * @return hashed user IDs
     */
    function hashUserIds(
        uint256 _userA,
        uint256 _userB
    ) internal pure returns (uint256) {
        (uint256 userId1, uint256 userId2) = _userA < _userB
            ? (_userA, _userB)
            : (_userB, _userA);
        uint256 hashedUserIds = uint256(
            keccak256(abi.encodePacked(userId1, userId2))
        );
        return hashedUserIds;
    }

    /**
     * @param _hashedUserIds hashed addresses of the users in the interaction
     * @dev Increments the interaction count between two users
     */

    function incrementInteractionCount(uint256 _hashedUserIds) internal {
        // sort the addresses to avoid duplicate counts
        // Ensure the addresses are sorted to avoid duplicates
        userInteractions[_hashedUserIds].interactionCount++;
    }

    /**
     *
     * @param _interactionCount number of interactions between two users
     * @return reward value based on the interaction count
     * @dev Helper function to calculate the interaction-based reward
     */
    function interactionReward(
        uint256 _interactionCount
    ) internal view returns (uint256) {
        if (_interactionCount >= 50) {
            return minReward; // Minimum reward after 50 interactions
        }
        uint256 reward = baseRewardRate -
            ((_interactionCount * (baseRewardRate - minimumRewardInterval)) /
                50); // Asymptotic decrease from baseRewardRate to minReward

        if (reward < minReward) {
            return minReward;
        }
        return reward;
    }

    /**
     *
     * @param _daysSinceLastInteraction number of days since the last interaction
     * @return reward value based on the time since the last interaction
     * @dev Helper function to calculate the time-based reward
     */
    function timeReward(
        uint256 _daysSinceLastInteraction
    ) internal view returns (uint256) {
        if (_daysSinceLastInteraction >= 28) {
            return baseRewardRate; // Maximum reward after 28 days
        }
        return
            minReward +
            ((_daysSinceLastInteraction * (baseRewardRate - minReward)) / 28); // Linear increase from minReward to baseRewardRate
    }

    /**
     *
     * @param _reward reward value to add randomization to
     * @return randomized reward value
     * @dev Helper function to add randomization to the reward
     */
    function addRandomization(uint256 _reward) internal view returns (uint256) {
        uint256 randomFactor = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
        ) % 40; // 0 to 39
        int256 randomAdjustment = int256(randomFactor) - 20; // -20 to +19
        int256 randomizedReward = int256(_reward) +
            (randomAdjustment * int256(_reward)) /
            100; // +/- 20%
        if (randomizedReward < int(minReward) && minReward > 0) {
            return minReward - 1e18;
        }
        if (randomizedReward > int(baseRewardRate)) {
            return baseRewardRate + 3e18;
        }
        return uint256(randomizedReward);
    }

    /**
     *
     * @param _hashedUserIds hashed user IDs of the users in the interaction
     * @return reward value for the interaction
     * @dev Calculates the reward value for the interaction between two users
     */
    function calculateRewards(
        uint256 _hashedUserIds
    ) public view returns (uint256) {
        Interaction memory userInteraction = userInteractions[_hashedUserIds];
        uint256 interactionCount = userInteraction.interactionCount;
        uint256 daysSinceLastInteraction = (block.timestamp -
            userInteraction.lastRewardTime) / 1 days;

        uint256 interactionRewardValue;
        uint256 timeRewardValue;
        if (interactionCount == 0) {
            timeRewardValue = baseRewardRate;
            interactionRewardValue = baseRewardRate;
        } else {
            interactionRewardValue = interactionReward(interactionCount);
            timeRewardValue = timeReward(daysSinceLastInteraction);
        }

        // Combine the rewards with weights (35% interactions, 65% time)
        uint256 combinedReward = ((interactionRewardValue *
            s_interactionCountWeight) + (timeRewardValue * s_timeWeight)) / 100;

        // Add randomization
        uint256 finalReward = addRandomization(combinedReward);

        return finalReward;
    }

    ///////////////////////////////////////////////////////////
    /*           */
    /*  GETTERS  */
    /*           */
    ///////////////////////////////////////////////////////////
    /**
     *
     * @param _userA user ID of the user to get the last reward time for
     * @param _userB user ID of the other user in the interaction
     * @return last reward time for the user
     */
    function getLastRewardTime(
        uint256 _userA,
        uint256 _userB
    ) public view returns (uint256) {
        return userInteractions[hashUserIds(_userA, _userB)].lastRewardTime;
    }

    /**
     *
     * @param _userA user ID of the first user
     * @param _userB user ID of the second user
     * @return interaction count between the two users
     */
    function getInteractionCount(
        uint256 _userA,
        uint256 _userB
    ) public view returns (uint256) {
        return userInteractions[hashUserIds(_userA, _userB)].interactionCount;
    }

    /**
     * @return the minimum reward
     */
    function getMinReward() public view returns (uint256) {
        return minReward;
    }

    /**
     * @return the admin address
     */
    function getAdminAddress() public view returns (address) {
        return s_blueSocialAdmin;
    }

    /**
     * @return the base reward rate
     */
    function getBaseRewardRate() public view returns (uint256) {
        return baseRewardRate;
    }

    /**
     * @return the minimum reward interval
     */
    function getMinimumRewardInterval() public view returns (uint256) {
        return minimumRewardInterval;
    }

    /**
     *
     * @return ice breaker fee
     */
    function getIceBreakerFee() public view returns (uint256) {
        return iceBreakerFee;
    }

    ///////////////////////////////////////////////////////////
    /*           */
    /*  SETTERS  */
    /*           */
    ///////////////////////////////////////////////////////////

    /**
     * @param _admin address of the Admin contract
     * @dev set the Admin contract address
     */
    function setAdmin(address _admin) public onlyOwner {
        s_blueSocialAdmin = _admin;
    }

    /**
     *
     * @param _timeWeight new time weight
     */
    function setTimeWeight(uint256 _timeWeight) public onlyOwner {
        s_timeWeight = _timeWeight;
    }

    /**
     *
     * @param _interactionCountWeight new interaction count weight
     * @dev Sets the interaction count weight
     */
    function setInteractionCountWeight(
        uint256 _interactionCountWeight
    ) public onlyOwner {
        s_interactionCountWeight = _interactionCountWeight;
    }

    /**
     *
     * @param _iceBreakerFee new ice breaker fee
     * @dev Sets the ice breaker fee
     */
    function setIceBreakerFee(uint256 _iceBreakerFee) public onlyOwner {
        iceBreakerFee = _iceBreakerFee;
    }

    /**
     *
     * @param _baseRewardRate new reward rate
     * @dev Sets the reward rate
     */
    function setBaseRewardRate(uint256 _baseRewardRate) public onlyOwner {
        baseRewardRate = _baseRewardRate;
    }

    /**
     *
     * @param _minReward new minimum reward
     * @dev Sets the minimum reward
     */
    function setMinReward(uint256 _minReward) public onlyOwner {
        minReward = _minReward;
    }

    /**
     *
     * @param _minimumRewardInterval new minimum reward interval
     * @dev Sets the minimum reward interval
     */
    function setMinimumRewardInterval(
        uint256 _minimumRewardInterval
    ) public onlyOwner {
        minimumRewardInterval = _minimumRewardInterval;
    }

    /**
     * @param _treasury address of the treasury
     * @dev set the treasury address
     */
    function setTreasury(address _treasury) public onlyOwner {
        s_treasury = _treasury;
    }

    /**
     * @dev Withdraws the contract balance to the owner
     */
    function withdraw() public nonReentrant onlyOwner {
        uint256 balance = address(this).balance;
        address receiver = owner();
        (bool success, ) = payable(receiver).call{value: balance}("0x");
        if (!success) revert WithdrawalError();
        emit BalanceWithdrawn(receiver, balance);
    }
}
