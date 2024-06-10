// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BlueSocialConsumer} from "./BlueSocialConsumer.sol";

/**
 * @title ProofOfInteraction
 * @author Hone1er
 * @notice A contract that rewards users for Proof of Interaction
 */
contract ProofOfInteraction is Ownable, ReentrancyGuard {
    /*                    */
    /*  TYPE DEFINITIONS  */
    /*                    */
    struct Interaction {
        uint256 interactionCount;
        uint256 lastRewardTime;
    }

    struct InteractionParticipants {
        address userA;
        address userB;
    }
    /*                   */
    /*  STATE VARIABLES  */
    /*                   */

    IERC20 immutable i_blueToken;
    address private s_treasury;
    address private s_blueSocialConsumer;
    uint64 private s_chainlinkSubscriptionId;

    uint256 public baseRewardRate;
    uint256 public iceBreakerFee;
    uint256 public minimumRewardInterval;

    mapping(uint256 hashedAddresses => Interaction interaction)
        public userInteractions;
    mapping(bytes32 => InteractionParticipants) private requests;

    /*        */
    /* EVENTS */
    /*        */
    event TipSent(
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );
    event RewardUser(address indexed user, uint256 reward);
    event BalanceWithdrawn(address indexed owner, uint256 amount);
    event IceBreakerSent(address indexed user, address indexed invitee);

    /*          */
    /*  ERRORS  */
    /*          */
    error RewardTransferFailedError();
    error RewardIntervalError();
    error IceBreakerFeeError();
    error OnlyConsumerError();
    error InteractionError();
    error TipUserError();

    /*             */
    /*  MODIFIERS  */
    /*             */
    modifier onlyAfterRewardInterval(address _userA, address _userB) {
        uint256 hashedAddresses = hashAddresses(_userA, _userB);
        if (
            block.timestamp - userInteractions[hashedAddresses].lastRewardTime <
            minimumRewardInterval
        ) {
            revert RewardIntervalError();
        }
        _;
    }

    modifier onlyConsumer() {
        if (msg.sender != s_blueSocialConsumer) {
            revert OnlyConsumerError();
        }
        _;
    }

    /*             */
    /*  FUNCTIONS  */
    /*             */

    /**
     *
     * @param initialOwner address of the owner of the contract
     * @param _baseRewardRate reward rate for the users
     * @param _iceBreakerFee fee to send an ice breaker
     * @param _minimumRewardInterval minimum time interval between rewards
     * @param _blueToken address of the BLUE token
     * @param _treasury address of the treasury
     * @param _blueSocialConsumer address of the BlueSocialConsumer contract
     * @param _chainlinkSubscriptionId chainlink subscription id
     * @dev Constructor for the ProofOfInteraction contract
     */
    constructor(
        address initialOwner,
        uint256 _baseRewardRate,
        uint256 _iceBreakerFee,
        uint256 _minimumRewardInterval,
        address _blueToken,
        address _treasury,
        address _blueSocialConsumer,
        uint64 _chainlinkSubscriptionId
    ) Ownable(initialOwner) {
        iceBreakerFee = _iceBreakerFee;
        baseRewardRate = _baseRewardRate;
        minimumRewardInterval = _minimumRewardInterval;
        i_blueToken = IERC20(_blueToken);
        s_treasury = _treasury;
        s_blueSocialConsumer = _blueSocialConsumer;
        s_chainlinkSubscriptionId = _chainlinkSubscriptionId;
    }

    /**
     *
     * @param _invitee address of the user to send the ice breaker to
     * @dev Sends an ice breaker fee to the treasury and emits an event
     */
    function sendIceBreaker(address _invitee) external nonReentrant {
        require(
            i_blueToken.balanceOf(msg.sender) >= iceBreakerFee,
            "Insufficient balance"
        );

        bool success = i_blueToken.transferFrom(
            msg.sender,
            s_treasury,
            iceBreakerFee
        );
        require(success, "Transfer failed");

        emit IceBreakerSent(msg.sender, _invitee);
    }

    /**
     *
     * @param _userA address of the first user in the interaction
     * @param _userB address of the second user in the interaction
     * @param _callData chainlink request data
     * @dev Calls the BlueSocialConsumer contract to send a chainlink request
     */
    function callConsumer(
        address _userA,
        address _userB,
        string[] calldata _callData
    ) public {
        if (_userA == _userB) {
            revert InteractionError();
        }

        bytes32 requestId = BlueSocialConsumer(s_blueSocialConsumer)
            .sendRequest(s_chainlinkSubscriptionId, _callData);

        InteractionParticipants
            memory interactionParticipants = InteractionParticipants(
                _userA,
                _userB
            );

        requests[requestId] = interactionParticipants;
    }

    /**
     * @param _callData requestId from chainlink
     * @dev Rewards multiple users with the reward rate
     *
     */
    function rewardUsers(bytes32 _callData) external nonReentrant onlyConsumer {
        InteractionParticipants memory interactionParticipants = requests[
            _callData
        ];
        uint256 hashedAddresses = hashAddresses(
            interactionParticipants.userA,
            interactionParticipants.userB
        );

        userInteractions[hashedAddresses].lastRewardTime = block.timestamp;
        uint256 rewardValue = calculateRewards(
            interactionParticipants.userA,
            interactionParticipants.userB
        );

        incrementInteractionCount(
            interactionParticipants.userA,
            interactionParticipants.userB
        );

        rewardUser(
            interactionParticipants.userA,
            interactionParticipants.userB,
            rewardValue
        );

        rewardUser(
            interactionParticipants.userB,
            interactionParticipants.userA,
            rewardValue
        );
    }

    /**
     *
     * @param _userA address of the user to reward
     * @param _userB address of the other user in the interaction
     * @param _rewardValue reward value to send to the user
     * @dev Rewards a user with the reward rate
     *
     * @notice This function is only callable by the owner and after the reward interval has passed since the last reward
     */
    function rewardUser(
        address _userA,
        address _userB,
        uint256 _rewardValue
    ) internal onlyAfterRewardInterval(_userA, _userB) {
        bool success = i_blueToken.transferFrom(
            s_treasury,
            _userA,
            _rewardValue
        );
        if (!success) {
            revert RewardTransferFailedError();
        }

        emit RewardUser(_userA, _rewardValue);
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
        emit TipSent(msg.sender, _user, _amount);
    }

    /**
     * @param _userA address of the first user
     * @param _userB address of the second user
     * @return hashed addresses
     */
    function hashAddresses(
        address _userA,
        address _userB
    ) public pure returns (uint256) {
        (address addr1, address addr2) = _userA < _userB
            ? (_userA, _userB)
            : (_userB, _userA);
        uint256 hashedAddresses = uint256(
            keccak256(abi.encodePacked(addr1, addr2))
        );
        return hashedAddresses;
    }

    /**
     * @param _userA address of the first user
     * @param _userB address of the second user
     * @dev Increments the interaction count between two users
     */
    function incrementInteractionCount(address _userA, address _userB) public {
        // sort the addresses to avoid duplicate counts
        // Ensure the addresses are sorted to avoid duplicates
        uint256 hashedAddresses = hashAddresses(_userA, _userB);
        userInteractions[hashedAddresses].interactionCount++;
    }

    /**
     *
     * @param _userA address of the first user
     * @param _userB address of the second user
     * @return reward value for the users
     */
    function calculateRewards(
        address _userA,
        address _userB
    ) public view returns (uint256) {
        uint256 hashedAddresses = hashAddresses(_userA, _userB);
        uint256 interactionCount = userInteractions[hashedAddresses]
            .interactionCount;
        if (interactionCount == 0) {
            return baseRewardRate;
        }
        return baseRewardRate / (1 + interactionCount);
    }

    /**
     *
     * @param _userA address of the user to get the last reward time for
     * @param _userB address of the other user in the interaction
     * @return last reward time for the user
     */
    function getLastRewardTime(
        address _userA,
        address _userB
    ) public view returns (uint256) {
        return userInteractions[hashAddresses(_userA, _userB)].lastRewardTime;
    }

    /**
     *
     * @return ice breaker fee
     */
    function getIceBreakerFee() public view returns (uint256) {
        return iceBreakerFee;
    }

    /**
     * @param _consumer address of the consumer contract
     * @dev set the consumer contract address
     */
    function setConsumer(address _consumer) public onlyOwner {
        s_blueSocialConsumer = _consumer;
    }

    /**
     *
     * @param _subscriptionId new subscription id
     * @dev set the chainlink subscription id
     */
    function setChainlinkSubscriptionId(
        uint64 _subscriptionId
    ) public onlyOwner {
        s_chainlinkSubscriptionId = _subscriptionId;
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
        payable(owner()).transfer(address(this).balance);
        emit BalanceWithdrawn(owner(), address(this).balance);
    }
}
