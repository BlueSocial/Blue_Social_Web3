// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title ExchangeOfContact
 * @author Hone1er
 * @notice A contract that rewards users for Exchange of Contact
 */
contract ExchangeOfContact is Ownable, ReentrancyGuard {
    /*                   */
    /*  STATE VARIABLES  */
    /*                   */
    using SafeERC20 for IERC20;
    IERC20 public immutable i_blueToken;
    address public treasury;
    address public admin;
    uint256 public rewardValue;

    mapping(uint256 hashedUserIds => bool) public contactExchange;

    /*        */
    /* EVENTS */
    /*        */
    event ContactExchange(
        address indexed user,
        address contact,
        uint256 reward
    );

    /*          */
    /*  ERRORS  */
    /*          */
    error SameUserError();
    error ContactAlreadyExchanged();

    /*          */
    /*  MODIFIERS  */
    /*          */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(
        address initialOwner,
        address _blueToken,
        uint256 _rewardValue,
        address _treasury,
        address _admin
    ) Ownable(initialOwner) {
        i_blueToken = IERC20(_blueToken);
        rewardValue = _rewardValue;
        treasury = _treasury;
        admin = _admin;
    }

    function hashUserIds(
        uint256 _userA,
        uint256 _userB
    ) internal pure returns (uint256 result) {
        if (_userA == _userB) {
            revert SameUserError();
        }
        if (_userA > _userB) {
            result = uint256(keccak256(abi.encodePacked(_userA, _userB)));
        } else {
            result = uint256(keccak256(abi.encodePacked(_userB, _userA)));
        }
        return result;
    }

    /**
     *
     * @param _userAddress address of the user
     * @param _userId ID of the user
     * @param _contactAddress address of the contact
     * @param _contactId ID of the contact
     * @notice Reward for exchanging contact with another user
     * @dev This function is only callable by the admin. If contactAddress does not exist use treasury address
     */
    function exchangeContact(
        address _userAddress,
        uint256 _userId,
        address _contactAddress,
        uint256 _contactId
    ) external nonReentrant onlyAdmin {
        uint256 hashedUserIds = hashUserIds(_userId, _contactId);
        if (contactExchange[hashedUserIds]) {
            revert ContactAlreadyExchanged();
        }

        contactExchange[hashedUserIds] = true;

        sendContactReward(_userAddress);
        sendContactReward(_contactAddress);

        emit ContactExchange(_userAddress, _contactAddress, rewardValue);
    }

    function sendContactReward(address _userAddress) internal {
        if (_userAddress == treasury) {
            return;
        }
        i_blueToken.safeTransferFrom(treasury, _userAddress, rewardValue);
    }

    function getRewardValue() public view returns (uint256) {
        return rewardValue;
    }

    function getHasExchangedContact(
        uint256 _hashedUserIds
    ) public view returns (bool) {
        return contactExchange[_hashedUserIds];
    }

    function setAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function setTreasury(address _treasury) public onlyOwner {
        treasury = _treasury;
    }

    function setRewardValue(uint256 _rewardValue) public onlyOwner {
        rewardValue = _rewardValue;
    }
}
