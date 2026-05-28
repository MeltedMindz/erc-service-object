// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.25;

import {IERCServiceObject} from "./IERCServiceObject.sol";

/// @title ERC Service Object Controller Interface
/// @notice Optional mutating interface for implementations that expose standardized service administration.
interface IERCServiceObjectController is IERCServiceObject {
    /// @notice Sets the smart account or operational account associated with `serviceId`.
    function setServiceAccount(uint256 serviceId, address account) external;

    /// @notice Sets the operator allowed to update service operation metadata and sign receipts.
    function setServiceOperator(uint256 serviceId, address operator, uint64 expiresAt) external;

    /// @notice Sets the recipient or router for service revenue and invalidates old payment routes.
    function setServiceRevenueRecipient(uint256 serviceId, address recipient) external;

    /// @notice Sets the service descriptor manifest.
    function setServiceManifest(uint256 serviceId, string calldata uri, bytes32 manifestHash) external;

    /// @notice Sets the x402/payment manifest and invalidates old payment routes.
    function setServicePaymentManifest(uint256 serviceId, string calldata uri, bytes32 manifestHash) external;

    /// @notice Adds or removes an additional receipt issuer.
    function setServiceReceiptIssuer(uint256 serviceId, address issuer, bool approved) external;

    /// @notice Anchors a signed usage receipt onchain.
    function anchorServiceReceipt(
        ServiceReceipt calldata receipt,
        bytes calldata signature,
        string calldata receiptURI
    ) external returns (bytes32 receiptHash);
}

