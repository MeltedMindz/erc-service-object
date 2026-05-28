# Ethereum Magicians Discussion Draft

Title: ERC: Tokenized Autonomous Services

## Summary

This proposal defines a minimal ERC-721/ERC-1155 compatible interface for tokenized autonomous services. It standardizes service operator discovery, revenue recipient discovery, service and payment manifest commitments, and EIP-712/ERC-1271 usage receipt verification.

The goal is not to create a new agent registry, smart account standard, payment protocol, or MCP protocol. The goal is to make a transferable service token legible to wallets, marketplaces, x402 servers, MCP clients, indexers, and smart accounts.

## Problem

Existing token standards can represent ownership of a service, but they do not tell clients who operates the service, where paid endpoints should route revenue, which payment manifest is current, or how a service usage receipt should be verified.

ERC-8004 addresses agent identity, validation, and reputation. ERC-7656 addresses generic linked services. x402 addresses HTTP-native payment negotiation. MCP addresses runtime tool/resource/prompt exchange. None define a minimal token-compatible service control plane.

## Proposed Surface

The core interface exposes:

- service account
- service operator and expiry
- revenue recipient
- service manifest URI/hash
- x402/payment manifest URI/hash/route nonce
- receipt issuer authorization
- EIP-712 receipt hash and verification
- optional receipt anchoring event

All dynamic endpoint, MCP, and x402 details remain offchain in hash-verified manifests.

## Feedback Requested

- Should the core support ERC-1155, or should ERC-1155 be an extension?
- Should revenue recipient reset on transfer, or should zero-address mean owner-following revenue?
- Should receipt anchoring be in the core interface or an optional extension?
- Is `serviceAccount` too close to ERC-6551, or is it useful as a generic operational account pointer?
- Should the receipt include `responseHash`, or should that remain in an offchain receipt manifest?

