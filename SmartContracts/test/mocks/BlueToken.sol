// SPDX-License-Identifier: MIT

import {MockERC20} from "forge-std/mocks/MockERC20.sol";

pragma solidity ^0.8.25;

contract BlueToken is MockERC20 {
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        initialize(_name, _symbol, _decimals);
    }

    function mint(address _to, uint256 _value) public virtual {
        _mint(_to, _value);
    }

    function burn(address _from, uint256 _value) public virtual {
        _burn(_from, _value);
    }
}
