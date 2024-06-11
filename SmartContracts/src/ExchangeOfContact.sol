// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ExchangeOfContact
 * @author Joshuajee
 * @notice A contract that rewards users for Exchange of Contact
 */
contract ExchangeOfContact is Ownable, ReentrancyGuard {

    /*                   */
    /*  STATE VARIABLES  */
    /*                   */
    IERC20 public immutable i_blueToken;

    mapping(bytes32 => bool) public contactExchange;


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
    error SameAddressError();

    constructor(address initialOwner, IERC20 _blueToken) Ownable(initialOwner) {
        i_blueToken = _blueToken;
    }



    function hashAddresses(address _userA, address _userB) internal pure returns(bytes32 result) {
        if (_userA == _userB) {
            revert SameAddressError();
        }

        if (_userA > _userB) {
            result = keccak256(abi.encodePacked(_userA, _userB));
        } else {
            result = keccak256(abi.encodePacked(_userB, _userA));
        }
    }



}
