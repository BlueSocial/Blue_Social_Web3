// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "@forge-std/Script.sol";
import {BlueSocialConsumer} from "../src/BlueSocialConsumer.sol";
import {BlueToken} from "test/mocks/BlueToken.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address initialOwner;
        uint256 _rewardRate;
        uint256 _iceBreakerFee;
        uint256 _minimumRewardInterval;
        address _blueToken;
        address _treasury;
        address _consumerContract;
        uint64 _chainlinkSubId;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaBaseConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaBaseConfig()
        public
        pure
        returns (NetworkConfig memory sepoliaNetworkConfig)
    {
        sepoliaNetworkConfig = NetworkConfig({
            initialOwner: 0x0000000000000000000000000000000000000000,
            _rewardRate: 10e18,
            _iceBreakerFee: 1e18,
            _minimumRewardInterval: 1 days,
            _blueToken: 0x0000000000000000000000000000000000000000,
            _treasury: 0x0000000000000000000000000000000000000000,
            _consumerContract: 0x0000000000000000000000000000000000000000,
            _chainlinkSubId: 0
        });
    }

    function getOrCreateAnvilEthConfig()
        public
        returns (NetworkConfig memory anvilNetworkConfig)
    {
        // Check to see if we set an active network config
        if (activeNetworkConfig.initialOwner != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        // deploy a ERC20 token and set the initial owner
        // take the address of the deployed token and set it as the blueToken
        BlueToken blueToken = new BlueToken("Blue Token", "BLUE", 18);
        blueToken.mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 1000e18);

        BlueSocialConsumer consumerContract = new BlueSocialConsumer();
        vm.stopBroadcast();

        anvilNetworkConfig = NetworkConfig({
            initialOwner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            _rewardRate: 10e18,
            _iceBreakerFee: 1e18,
            _minimumRewardInterval: 1 minutes,
            _blueToken: address(blueToken),
            _treasury: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            _consumerContract: address(consumerContract),
            _chainlinkSubId: 64
        });
    }
}
