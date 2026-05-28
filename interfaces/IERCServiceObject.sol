// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.25;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title ERC Service Object Interface
/// @notice Minimal discovery, payment-manifest, and receipt surface for tokenized autonomous services.
interface IERCServiceObject is IERC165 {
    /// @notice EIP-712 typed receipt bound to a service token and current payment route.
    struct ServiceReceipt {
        address serviceContract;
        uint256 serviceId;
        address payer;
        address issuer;
        address revenueRecipient;
        bytes32 requestHash;
        bytes32 responseHash;
        bytes32 paymentHash;
        bytes32 paymentManifestHash;
        bytes32 receiptURIHash;
        uint64 routeNonce;
        uint64 issuerEpoch;
        uint64 issuedAt;
    }

    /// @notice Emitted when the service operational account changes.
    event ServiceAccountUpdated(uint256 indexed serviceId, address indexed account);

    /// @notice Emitted when the service operator changes.
    event ServiceOperatorUpdated(uint256 indexed serviceId, address indexed operator, uint64 expiresAt);

    /// @notice Emitted when the revenue recipient changes.
    event ServiceRevenueRecipientUpdated(
        uint256 indexed serviceId, address indexed recipient, uint64 routeNonce
    );

    /// @notice Emitted when the service descriptor manifest changes.
    event ServiceManifestUpdated(uint256 indexed serviceId, string uri, bytes32 indexed manifestHash);

    /// @notice Emitted when the x402/payment manifest changes.
    event ServicePaymentManifestUpdated(
        uint256 indexed serviceId, string uri, bytes32 indexed manifestHash, uint64 routeNonce
    );

    /// @notice Emitted when an additional receipt issuer is approved or revoked.
    event ServiceReceiptIssuerUpdated(
        uint256 indexed serviceId, address indexed issuer, bool approved, uint64 issuerEpoch
    );

    /// @notice Emitted when a usage receipt is anchored onchain.
    event ServiceReceiptAnchored(
        uint256 indexed serviceId,
        bytes32 indexed receiptHash,
        address indexed issuer,
        address payer,
        bytes32 paymentHash,
        bytes32 requestHash,
        string receiptURI
    );

    /// @notice Returns the smart account or operational account associated with `serviceId`.
    function serviceAccount(uint256 serviceId) external view returns (address);

    /// @notice Returns the active operator and its expiry. A zero expiry means no time limit.
    function serviceOperator(uint256 serviceId) external view returns (address operator, uint64 expiresAt);

    /// @notice Returns the recipient or router that paid service endpoints should use.
    function serviceRevenueRecipient(uint256 serviceId) external view returns (address);

    /// @notice Returns the current service manifest URI and hash.
    function serviceManifest(uint256 serviceId) external view returns (string memory uri, bytes32 manifestHash);

    /// @notice Returns the current payment manifest URI, hash, and route nonce.
    function servicePaymentManifest(uint256 serviceId)
        external
        view
        returns (string memory uri, bytes32 manifestHash, uint64 routeNonce);

    /// @notice Returns true when `issuer` may sign receipts for `serviceId`.
    function isAuthorizedReceiptIssuer(uint256 serviceId, address issuer) external view returns (bool);

    /// @notice Returns the EIP-712 digest for a service receipt.
    function hashServiceReceipt(ServiceReceipt calldata receipt) external view returns (bytes32);

    /// @notice Verifies an EOA or ERC-1271 signature for a service receipt.
    function verifyServiceReceipt(ServiceReceipt calldata receipt, bytes calldata signature)
        external
        view
        returns (bool);
}
