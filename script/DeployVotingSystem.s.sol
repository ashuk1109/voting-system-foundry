// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VotingSystem} from "../src/VotingSystem.sol";

contract DeployVotingSystem is Script {
    function run() external returns (VotingSystem) {
        vm.startBroadcast();
        VotingSystem votingSystem = new VotingSystem();
        vm.stopBroadcast();
        return votingSystem;
    }
}
