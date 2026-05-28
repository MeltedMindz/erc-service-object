---
eip: <to be assigned>
title: Tokenized Autonomous Services
description: A token-compatible interface for autonomous service manifests, payment routes, and signed usage receipts.
author: MeltedMindz (@MeltedMindz)
status: Draft
type: Standards Track
category: ERC
created: 2026-05-28
requires: 165, 712, 721, 1155, 1271
---

## Abstract

This ERC defines a token-compatible interface for autonomous service objects. A service object is a transferable ERC-721 token or an ERC-1155 token ID with unambiguous service control. The interface exposes an optional service account, an operator, a revenue recipient, a service manifest commitment, a payment manifest commitment, and EIP-712 usage receipts verifiable by EOAs or ERC-1271 smart accounts.

This ERC does not define an agent registry, reputation system, validation system, HTTP payment protocol, MCP tool protocol, escrow protocol, or smart account module system.

## Motivation

Autonomous services increasingly combine token ownership, offchain execution, paid HTTP endpoints, MCP-style tool interfaces, and smart account infrastructure. Existing standards cover important adjacent surfaces but do not provide a minimal interoperable service object.

ERC-721 and ERC-1155 define token ownership but do not define who operates a service, where endpoint revenue should be paid, which manifests clients should trust, or how usage receipts are verified. ERC-6551 defines token-bound accounts but not service payment or receipt semantics. ERC-4337, ERC-7579, and ERC-6900 define smart account execution and modules but not service ownership semantics. ERC-8004 defines agent identity, validation, and reputation but treats payment as orthogonal. ERC-7656 defines generalized linked services but not paid autonomous-service roles, payment routes, or receipts.

This ERC fills that narrow gap by defining a small service control plane that wallets, marketplaces, indexers, x402 servers, MCP clients, smart accounts, and agent registries can read without depending on a centralized registry or payment rail.

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHOULD", "SHOULD NOT", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

### Definitions

`serviceId` is the token ID identifying a service object.

`service owner` is the ERC-721 owner of `serviceId`, or the controller of an ERC-1155 `serviceId` under the implementing contract's service-control rules.

`service account` is an optional operational account associated with `serviceId`. It MAY be an ERC-6551 token-bound account, ERC-4337 smart account, Safe, EOA, or other account.

`operator` is an address authorized to operate the service, update operational service metadata, and issue receipts according to the implementation's authorization rules.

`revenue recipient` is the address or contract that service payment manifests identify as the recipient or router for paid service endpoints.

`service manifest` is an offchain document describing the service, endpoints, MCP metadata, capabilities, and provenance.

`payment manifest` is an offchain document describing authorized payment routes, including x402-compatible route metadata when used.

`route nonce` is a monotonic integer that invalidates stale payment manifests and receipts after payment-route changes.

`issuer epoch` is a monotonic integer that invalidates stale receipt signatures after receipt signer authorization changes.

### Token Compatibility

A compliant implementation MUST implement ERC-165.

A compliant implementation MUST implement ERC-721 or ERC-1155. If ERC-1155 is used, the implementation MUST define an unambiguous controller for each service ID. Multi-holder ownership of a service ID is out of scope unless an implementation defines a deterministic controller.

An ERC-721 implementation SHOULD expose `tokenURI(serviceId)` that resolves to ordinary NFT metadata. That metadata SHOULD include pointers to the service and payment manifests. ERC-721 implementations SHOULD emit ERC-4906 metadata update events when service display metadata changes. ERC-1155 implementations SHOULD emit `URI` events according to ERC-1155 metadata rules.

### Core Interface

The ERC-165 interface ID for `IERCServiceObject` is `0x4850f8e0`.

```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.25;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERCServiceObject is IERC165 {
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

    event ServiceAccountUpdated(uint256 indexed serviceId, address indexed account);
    event ServiceOperatorUpdated(uint256 indexed serviceId, address indexed operator, uint64 expiresAt);
    event ServiceRevenueRecipientUpdated(uint256 indexed serviceId, address indexed recipient, uint64 routeNonce);
    event ServiceManifestUpdated(uint256 indexed serviceId, string uri, bytes32 indexed manifestHash);
    event ServicePaymentManifestUpdated(
        uint256 indexed serviceId,
        string uri,
        bytes32 indexed manifestHash,
        uint64 routeNonce
    );
    event ServiceReceiptIssuerUpdated(
        uint256 indexed serviceId,
        address indexed issuer,
        bool approved,
        uint64 issuerEpoch
    );
    event ServiceReceiptAnchored(
        uint256 indexed serviceId,
        bytes32 indexed receiptHash,
        address indexed issuer,
        address payer,
        bytes32 paymentHash,
        bytes32 requestHash,
        string receiptURI
    );

    function serviceAccount(uint256 serviceId) external view returns (address);

    function serviceOperator(uint256 serviceId)
        external
        view
        returns (address operator, uint64 expiresAt);

    function serviceRevenueRecipient(uint256 serviceId) external view returns (address);

    function serviceManifest(uint256 serviceId)
        external
        view
        returns (string memory uri, bytes32 manifestHash);

    function servicePaymentManifest(uint256 serviceId)
        external
        view
        returns (string memory uri, bytes32 manifestHash, uint64 routeNonce);

    function isAuthorizedReceiptIssuer(uint256 serviceId, address issuer) external view returns (bool);

    function hashServiceReceipt(ServiceReceipt calldata receipt) external view returns (bytes32);

    function verifyServiceReceipt(ServiceReceipt calldata receipt, bytes calldata signature)
        external
        view
        returns (bool);
}
```

### Controller Extension

Mutation functions are separated from the read-only interface so wrapped assets, registries, or immutable implementations can expose discovery without adopting a specific admin ABI.

The ERC-165 interface ID for `IERCServiceObjectController` is `0xf2e87b1d`.

```solidity
interface IERCServiceObjectController is IERCServiceObject {
    function setServiceAccount(uint256 serviceId, address account) external;
    function setServiceOperator(uint256 serviceId, address operator, uint64 expiresAt) external;
    function setServiceRevenueRecipient(uint256 serviceId, address recipient) external;
    function setServiceManifest(uint256 serviceId, string calldata uri, bytes32 manifestHash) external;
    function setServicePaymentManifest(uint256 serviceId, string calldata uri, bytes32 manifestHash) external;
    function setServiceReceiptIssuer(uint256 serviceId, address issuer, bool approved) external;

    function anchorServiceReceipt(
        ServiceReceipt calldata receipt,
        bytes calldata signature,
        string calldata receiptURI
    ) external returns (bytes32 receiptHash);
}
```

Implementations that expose the controller extension MUST restrict mutation functions to the service owner or authorized service authority. ERC-721 `approve` or `setApprovalForAll` MUST NOT by itself grant service operator, payment route, revenue recipient, or receipt issuer authority.

### Manifest Hashes

Manifest hashes MUST be `keccak256` over the exact UTF-8 bytes returned from the manifest URI. Implementations MAY publish canonical JSON to improve reproducibility, but consumers MUST verify exact bytes.

The service manifest SHOULD identify the service with:

- chain ID
- token standard
- token contract
- token ID
- service manifest schema version
- optional MCP server metadata
- optional capability manifest URI/hash
- optional provenance URI/hash
- optional payment manifest URI/hash

The payment manifest SHOULD identify:

- service chain, contract, and token ID
- route nonce
- allowed origins
- accepted payment rails, including `(scheme, network, asset, payTo)` when x402 is used
- optional facilitator metadata
- resource patterns
- receipt requirements

Payment manifests MAY use x402. If x402 is used, live x402 `PAYMENT-REQUIRED` responses remain the authoritative quotes, and clients SHOULD verify that the offered payment route is allowed by the current payment manifest.

### Receipts

Receipts MUST be hashed using EIP-712 typed structured data. Receipt verification MUST support EOAs and ERC-1271 contract signatures.

The EIP-712 receipt type is:

```text
ServiceReceipt(
  address serviceContract,
  uint256 serviceId,
  address payer,
  address issuer,
  address revenueRecipient,
  bytes32 requestHash,
  bytes32 responseHash,
  bytes32 paymentHash,
  bytes32 paymentManifestHash,
  bytes32 receiptURIHash,
  uint64 routeNonce,
  uint64 issuerEpoch,
  uint64 issuedAt
)
```

`serviceContract` MUST be the verifying service contract.

`paymentManifestHash` MUST match the current payment manifest hash for the service at the time the receipt is considered valid.

`routeNonce` MUST match the current route nonce when verified against current state.

`issuerEpoch` MUST match the current issuer epoch when verified against current state.

`receiptURIHash` MUST equal `keccak256(bytes(receiptURI))` if the receipt is anchored with a URI.

`paymentHash` SHOULD commit to the x402 payment payload, settlement reference, or other payment proof used by the implementation.

`requestHash` and `responseHash` SHOULD commit to request and response material without revealing private user data.

`verifyServiceReceipt` MUST return `false` when the issuer is not authorized for the service.

`anchorServiceReceipt` is OPTIONAL. Implementations MAY issue receipts entirely offchain. If an implementation consumes a receipt for an onchain effect, it MUST prevent replay of the consumed receipt hash.

### Transfer Semantics

On transfer of a service token, implementations SHOULD invalidate stale operator, service account, receipt issuer, and payment route authorizations unless those rights are explicitly represented as transferable encumbrances. Implementations SHOULD increment a route nonce or authority epoch when payment routes or signer authority changes.

The reference implementation clears operator, service account, and payment manifest, resets revenue recipient to the new owner, increments route nonce, and increments issuer epoch on transfer.

### Offchain Boundaries

This ERC MUST NOT require:

- a specific AI provider
- a centralized registry
- a single MCP implementation
- a specific x402 facilitator
- a specific payment asset
- a specific chain
- expensive onchain service execution
- trust in offchain operators

MCP tool execution, dynamic pricing, service metering, refunds, subscriptions, SLAs, transcripts, model outputs, validation, and reputation SHOULD remain outside this ERC.

## Rationale

ERC-721 and ERC-1155 are reused for ownership because wallets and marketplaces already understand them. This ERC avoids redefining ownership.

Operator rights are separate from token approvals because marketplace approvals should not be able to mutate endpoints, payment routes, receipt signers, or revenue recipients.

The standard uses URI/hash commitments rather than onchain endpoint arrays because service metadata, MCP capabilities, and payment offers are dynamic and can be large.

The service manifest and payment manifest are separate because operational endpoint metadata changes for different reasons than revenue routing and payment authorization.

The `routeNonce` invalidates stale payment routes and receipts after revenue recipient or payment manifest changes.

The `issuerEpoch` invalidates stale receipt signatures after receipt signer changes.

Receipts use EIP-712 and ERC-1271 to support EOAs, Safe accounts, token-bound accounts, ERC-4337 accounts, and other smart accounts.

x402 and MCP are treated as manifest profiles rather than hard dependencies. This keeps the ERC payment-rail and transport agnostic while still supporting x402-native paid endpoints and MCP-native service capabilities.

## Backwards Compatibility

This ERC is opt-in and does not change ERC-721, ERC-1155, ERC-6551, ERC-8004, ERC-7656, x402, or MCP.

Existing ERC-721 or ERC-1155 services can add this interface, wrap an existing service asset, or publish manifests that reference existing ERC-8004, MCP, x402, or provenance metadata.

Wallets and marketplaces that do not understand this ERC will still see a normal ERC-721 or ERC-1155 token when the implementation follows the base token standard.

## Reference Implementation

Reference files:

- `interfaces/IERCServiceObject.sol`
- `interfaces/IERCServiceObjectController.sol`
- `src/TokenizedAutonomousService.sol`
- `src/examples/ExampleX402SettlementRecorder.sol`
- `test/TokenizedAutonomousService.t.sol`

The reference implementation is an ERC-721 service token with service role management, manifest commitments, payment route nonces, issuer epochs, EIP-712 receipt verification, ERC-1271 support through `SignatureChecker`, `tokenURI` integration, ERC-4906 metadata update support, and optional receipt anchoring.

## Security Considerations

This ERC cannot prove that an offchain service is honest, available, safe, or correct. A valid receipt proves signature and route consistency, not service quality.

Manifest URIs are untrusted until their exact bytes hash to the onchain manifest hash. Clients must sanitize display metadata and treat HTML, SVG, Markdown, tool descriptions, and endpoint metadata as hostile input.

Payment offers must be verified against the current payment manifest and revenue recipient. x402 facilitators are payment helpers, not service identity authorities.

Receipts should not include private request or response bodies directly. Use hashes or privacy-preserving commitments.

ERC-1271 signatures may be state-dependent. Historical receipt verification may require event logs or archived state at the issuance block.

Receipt anchoring with a URI should bind the URI or URI hash into the signed receipt to prevent front-running with misleading receipt locations.

Onchain receipt consumption must prevent replay. Event-only anchoring is not sufficient for claim, refund, accounting, or reputation mechanisms that change state.

Service token transfers can transfer control over token-bound accounts and operational assets. Marketplaces should inspect service account state, modules, operator, revenue recipient, payment manifest, and route nonce before sale.

Upgradeable implementations can change trust assumptions. Implementations should use immutable contracts or timelocked upgrades where possible and should emit standard upgrade events.

## Copyright

Copyright and related rights waived via [CC0](../LICENSE).
