// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {TokenizedAutonomousService} from "../src/TokenizedAutonomousService.sol";

contract Deploy is Script {
    function run() external returns (TokenizedAutonomousService service) {
        vm.startBroadcast();
        service = new TokenizedAutonomousService();
        vm.stopBroadcast();
    }
}
