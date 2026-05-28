// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.25;

import {IERCServiceObjectController} from "../../interfaces/IERCServiceObjectController.sol";

/// @title ExampleX402SettlementRecorder
/// @notice Example adapter that anchors an offchain x402 service receipt after settlement.
contract ExampleX402SettlementRecorder {
    function recordSettlement(
        IERCServiceObjectController service,
        IERCServiceObjectController.ServiceReceipt calldata receipt,
        bytes calldata signature,
        string calldata receiptURI
    ) external returns (bytes32 receiptHash) {
        return service.anchorServiceReceipt(receipt, signature, receiptURI);
    }
}
