// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ExchangeOfContact} from "../src/ExchangeOfContact.sol";
import {console} from "forge-std/console.sol";
import {BlueToken} from "../test/mocks/BlueToken.sol";
import {Test} from "forge-std/Test.sol";

contract ExchangeOfContactTest is Test {
    address public user = address(0x1);
    address public contact = address(0x2);
    uint256 public userId = 1;
    uint256 public contactId = 2;
    address public treasury = address(0x4);

    address public admin = address(0x3);

    BlueToken public blueToken;

    ExchangeOfContact exchangeOfContact;

    function setUp() public {
        blueToken = new BlueToken("BlueToken", "BLUE", 18);
        exchangeOfContact = new ExchangeOfContact(
            address(this),
            address(blueToken),
            10e18,
            treasury,
            admin
        );

        blueToken.mint(treasury, 2500000e18);
        vm.prank(treasury);
        blueToken.approve(address(exchangeOfContact), 2500000e18);
    }

    function testExchangeOfContact() public {
        uint256 userInitialBalance = blueToken.balanceOf(user);
        uint256 contactInitialBalance = blueToken.balanceOf(contact);

        vm.prank(admin);
        exchangeOfContact.exchangeContact(user, userId, contact, contactId);

        assertEq(
            blueToken.balanceOf(user),
            userInitialBalance + 10e18,
            "User balance should increase by 10e18"
        );

        assertEq(
            blueToken.balanceOf(contact),
            contactInitialBalance + 10e18,
            "Contact balance should increase by 10e18"
        );
    }

    function testUnauthorizedExchangeOfContact() public {
        vm.prank(user);
        vm.expectRevert();
        exchangeOfContact.exchangeContact(user, userId, contact, contactId);
    }

    function testSameUserExchangeOfContact() public {
        vm.prank(admin);
        vm.expectRevert();
        exchangeOfContact.exchangeContact(user, userId, user, userId);
    }

    function testContactAlreadyExchanged() public {
        vm.prank(admin);
        exchangeOfContact.exchangeContact(user, userId, contact, contactId);
        vm.expectRevert();
        exchangeOfContact.exchangeContact(user, userId, contact, contactId);
    }

    function testExchangeContactTreasuryBalance() public {
        uint256 treasuryInitialBalance = blueToken.balanceOf(treasury);

        vm.prank(admin);
        exchangeOfContact.exchangeContact(user, userId, contact, contactId);

        assertEq(
            blueToken.balanceOf(treasury),
            treasuryInitialBalance - (exchangeOfContact.getRewardValue() * 2), // rewards are given to both user and contact
            "Treasury balance should decrease by 10e18"
        );
    }

    function testContactHasNoAddress() public {
        vm.prank(admin);
        exchangeOfContact.exchangeContact(user, userId, treasury, contactId);

        assertEq(
            blueToken.balanceOf(treasury),
            2500000e18 - exchangeOfContact.getRewardValue(),
            "Treasury balance should decrease by 10e18"
        );
    }
}
