// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {ProofOfInteraction} from "../src/ProofOfInteraction.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

// import {AddConsumer, CreateSubscription, FundSubscription} from "./Interactions.s.sol";

contract DeployPOIRewards is Script {
    function run() external returns (ProofOfInteraction, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig(); // This comes with our mocks!

        (
            address initialOwner,
            uint256 _rewardRate,
            uint256 _iceBreakerFee,
            uint256 _minimumRewardInterval,
            address _blueToken,
            address _treasury,
            address _consumerContract,
            uint64 _chainlinkSubId
        ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        ProofOfInteraction proofOfInteraction = new ProofOfInteraction(
            initialOwner,
            _rewardRate,
            _iceBreakerFee,
            _minimumRewardInterval,
            _blueToken,
            _treasury,
            _consumerContract,
            _chainlinkSubId
        );
        vm.stopBroadcast();

        // We already have a broadcast in here

        return (proofOfInteraction, helperConfig);
    }
}
