# Executive Summary

## Problem Statement

Ethereum has token standards for ownership, account standards for execution, and emerging agent standards for discovery and trust. It does not yet have a minimal interoperable surface that lets wallets, marketplaces, x402 servers, MCP clients, indexers, and smart accounts answer one practical question:

> For this transferable service token, who may operate it, where should revenue be paid, which manifests are authoritative, and how can usage receipts be verified?

## Proposed Standard

The proposed ERC, **Tokenized Autonomous Services**, is a token extension for ownable paid service instances. A compliant service object implements ERC-165 plus either ERC-721 or ERC-1155 ownership semantics. The core interface exposes:

- `serviceAccount(serviceId)`
- `serviceOperator(serviceId)`
- `serviceRevenueRecipient(serviceId)`
- `serviceManifest(serviceId)`
- `servicePaymentManifest(serviceId)`
- receipt issuer discovery and EIP-712 receipt verification

The reference implementation is an ERC-721 service token in [src/TokenizedAutonomousService.sol](../src/TokenizedAutonomousService.sol).

## Why Existing Standards Are Insufficient

ERC-721 and ERC-1155 provide transferable token ownership, but no standard service operator, revenue recipient, service manifest, payment manifest, or receipt semantics.

ERC-6551 provides token-bound accounts, but not service endpoint, payment, or receipt semantics.

ERC-4337, ERC-7579, and ERC-6900 standardize smart account execution and modules, but not service ownership or paid endpoint provenance.

ERC-8004 standardizes trustless agent identity, reputation, and validation. It does not define separable service ownership, operator delegation, x402 payment manifests, revenue routing, or usage receipt verification.

ERC-7656 standardizes generic contract-linked services. It does not define paid autonomous-service roles, x402-native payment manifests, or receipt semantics.

x402 standardizes HTTP-native payment negotiation and settlement. It does not bind payment offers to a transferable Ethereum service identity.

MCP standardizes runtime tool/resource/prompt exchange. It does not bind an MCP server to an Ethereum service token.

## ERC Naming Proposals

Canonical name: **Tokenized Autonomous Services**

Short name: **Service Object**

Interface family: `IERCServiceObject`

Ticker-style identifier: `TAS`

Possible numbering concept: use an assigned ERC number only after EIP editor review. The proposal should not self-assign a number, but it belongs near the current agent/service ERC discussion cluster and should be submitted as `eip: TBD`.

## Minimal Viable Surface

MUST be onchain:

- token identity and ownership through ERC-721 or ERC-1155
- ERC-165 interface detection
- operator, revenue recipient, and optional service account
- service manifest URI and hash
- payment manifest URI, hash, and route nonce
- events for all role and manifest changes
- EIP-712 receipt hash and ERC-1271-compatible signature verification

SHOULD remain offchain:

- MCP tool schemas and runtime capability discovery
- endpoint URLs beyond hashed manifests
- x402 `PAYMENT-REQUIRED`, `PAYMENT-SIGNATURE`, and `PAYMENT-RESPONSE`
- detailed pricing, metering, refunds, SLAs, transcripts, and model outputs
- reputation and validation aggregation

## Why This Matters

This is the missing interoperability layer between token ownership, agent/service infrastructure, HTTP-native payments, and verifiable service usage. It lets a marketplace sell a service token, a wallet inspect the service route, an x402 server prove it is the authorized paid endpoint, and an indexer track receipts without forcing all parties into a single registry or payment rail.

