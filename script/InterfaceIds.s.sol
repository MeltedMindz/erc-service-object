// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.25;

import {Script, console2} from "forge-std/Script.sol";
import {IERCServiceObject} from "../interfaces/IERCServiceObject.sol";
import {IERCServiceObjectController} from "../interfaces/IERCServiceObjectController.sol";

contract InterfaceIds is Script {
    function run() external pure {
        console2.logBytes4(type(IERCServiceObject).interfaceId);
        console2.logBytes4(type(IERCServiceObjectController).interfaceId);
    }
}
