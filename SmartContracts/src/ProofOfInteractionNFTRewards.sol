// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IInteractionNFT {
    function getInteractionCount(
        address user1,
        address user2
    ) external view returns (uint256);
}

/**
 * @title ProofOfInteraction
 * @author Hone1er
 * @notice A contract that rewards users for Proof of Interaction
 */
contract ProofOfInteraction is Ownable, ReentrancyGuard {
    /*                    */
    /*  TYPE DEFINITIONS  */
    /*                    */
    struct User {
        uint256 totalRewards;
        uint256 lastRewardTime;
    }

    /*                   */
    /*  STATE VARIABLES  */
    /*                   */
    IERC20 immutable i_blueToken;
    IInteractionNFT immutable i_interactionNFT;

    uint256 public baseRewardRate;
    uint256 public iceBreakerFee;
    uint256 public minimumRewardInterval;

    mapping(address => User) public userRewards;

    /*        */
    /* EVENTS */
    /*        */
    event TipSent(address indexed user, uint256 amount);
    event RewardUser(address indexed user, uint256 reward);
    event BalanceWithdrawn(address indexed owner, uint256 amount);
    event IceBreakerSent(address indexed user, address indexed invitee);

    /*          */
    /*  ERRORS  */
    /*          */
    error RewardTransferFailedError();
    error RewardIntervalError();
    error IceBreakerFeeError();
    error TipUserError();

    /*             */
    /*  MODIFIERS  */
    /*             */
    modifier onlyAfterRewardInterval(address user) {
        if (
            block.timestamp - userRewards[user].lastRewardTime <
            minimumRewardInterval
        ) {
            revert RewardIntervalError();
        }
        _;
    }

    /*             */
    /*  FUNCTIONS  */
    /*             */
    constructor(
        address initialOwner,
        uint256 _baseRewardRate,
        uint256 _iceBreakerFee,
        uint256 _minimumRewardInterval,
        address _interactionNFT,
        address _blueToken
    ) Ownable(initialOwner) {
        iceBreakerFee = _iceBreakerFee;
        baseRewardRate = _baseRewardRate;
        minimumRewardInterval = _minimumRewardInterval;
        i_interactionNFT = IInteractionNFT(_interactionNFT);
        i_blueToken = IERC20(_blueToken);
    }

    /**
     *
     * @param _invitee address of the user to send the ice breaker to
     * @dev Sends an ice breaker fee to the treasury and emits an event
     */
    function sendIceBreaker(address _invitee) external nonReentrant {
        bool success = i_blueToken.transferFrom(
            msg.sender,
            address(this),
            iceBreakerFee
        );
        if (!success) {
            revert IceBreakerFeeError();
        }
        emit IceBreakerSent(msg.sender, _invitee);
    }

    /**
     * @param  _userA address of first user to reward
     * @param  _userB address of second user to reward
     * @dev Rewards multiple users with the calculated reward rate
     *
     */
    function rewardUsers(
        address _userA,
        address _userB
    ) external onlyOwner nonReentrant {
        uint256 interactionCount = i_interactionNFT.getInteractionCount(
            _userA,
            _userB
        );
        uint256 reward = calculateReward(interactionCount);
        rewardUser(_userA, reward);
        rewardUser(_userB, reward);
    }

    /**
     *
     * @param _user address of the user to reward
     * @dev Rewards a user with the reward rate
     *
     * @notice This function is only callable by the owner and after the reward interval has passed since the last reward
     */
    function rewardUser(
        address _user,
        uint256 _reward
    ) internal onlyAfterRewardInterval(_user) {
        bool success = i_blueToken.transferFrom(address(this), _user, _reward);
        if (!success) {
            revert RewardTransferFailedError();
        }
        emit RewardUser(_user, _reward);
    }

    /**
     * @param _interactionCount count of interactions between two users
     * @return calculated reward based on diminishing returns
     * @dev Calculates the reward based on the interaction count
     */
    function calculateReward(
        uint256 _interactionCount
    ) public view returns (uint256) {
        return baseRewardRate / (1 + _interactionCount);
    }

    /**
     *
     * @param _user address of the user to tip
     * @param _amount amount to tip the user in BLUE tokens
     * @dev Tips a user with the specified amount of BLUE tokens
     */
    function tipUser(address _user, uint256 _amount) external nonReentrant {
        bool success = i_blueToken.transferFrom(msg.sender, _user, _amount);
        if (!success) {
            revert TipUserError();
        }
        emit TipSent(_user, _amount);
    }

    /**
     *
     * @param _user address of the user to get rewards for
     * @return total rewards for the user
     */
    function getUserRewards(address _user) public view returns (uint256) {
        return userRewards[_user].totalRewards;
    }

    /**
     *
     * @param _user address of the user to get the last reward time for
     * @return last reward time for the user
     */
    function getUserLastRewardTime(
        address _user
    ) public view returns (uint256) {
        return userRewards[_user].lastRewardTime;
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
     * @param _minimumRewardInterval new minimum reward interval
     * @dev Sets the minimum reward interval
     */
    function setMinimumRewardInterval(
        uint256 _minimumRewardInterval
    ) public onlyOwner {
        minimumRewardInterval = _minimumRewardInterval;
    }

    /**
     * @dev Withdraws the contract balance to the owner
     */
    function withdraw() public nonReentrant onlyOwner {
        payable(owner()).transfer(address(this).balance);
        emit BalanceWithdrawn(owner(), address(this).balance);
    }
}
