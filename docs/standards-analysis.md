# Competitive And Existing Standards Analysis

## Compatibility Matrix

| Standard | Scope | Relationship to this ERC |
| --- | --- | --- |
| ERC-165 | Interface discovery. | Required for service interface detection. |
| ERC-173 | Contract-level ownership. | Useful for admin contracts, but token ownership is canonical for services. |
| ERC-721 | Non-fungible token ownership and marketplace compatibility. | Preferred base for one service = one token. |
| ERC-1155 | Multi-token ownership. | Compatible when a service ID has unambiguous control, preferably singleton supply. |
| ERC-6551 | Token-bound accounts for NFTs. | Optional operational account layer. This ERC does not redefine token-bound accounts. |
| ERC-4337 | Account abstraction using UserOperations. | Optional account execution layer. This ERC does not define account abstraction. |
| ERC-7579 | Minimal modular smart accounts. | Optional compatibility for service accounts. |
| ERC-6900 | Modular smart contract accounts and plugins. | Optional compatibility for service accounts; service manifests must not collide with account plugin manifests. |
| ERC-7656 | Generalized contract-linked services. | Prior art and collision risk. This ERC is narrower: paid service roles, payment manifests, and receipts. |
| ERC-8004 | Trustless agent identity, reputation, and validation registries. | Complementary. This ERC is not an agent registry. |
| ERC-8122 | Minimal agent registry. | Complementary registry/discovery work, not a service control surface. |
| ERC-8126 | AI agent verification. | Optional validation layer for service manifests or operators. |
| ERC-8183 | Agentic commerce escrow jobs. | Complementary transactional escrow flow, not a standing service object. |
| ERC-8196 | AI agent authenticated wallet. | Optional execution/policy layer for service accounts. |
| ERC-7641 | Revenue-sharing ERC-20. | Possible revenue recipient/router implementation, not core service semantics. |
| ERC-8048 | Onchain metadata for token registries. | Optional metadata extension. This ERC keeps core hashes and URIs minimal. |
| EIP-712 | Typed structured data signing. | Required for portable usage receipts. |
| ERC-1271 | Contract signature validation. | Required for smart account and Safe-compatible receipt issuers. |
| x402 | HTTP-native payment protocol. | Payment rail. This ERC anchors service-specific x402 manifests but does not settle payments. |
| MCP | Client-server tool/resource/prompt protocol. | Runtime service protocol. This ERC anchors MCP metadata but does not execute MCP. |

## Actual Protocol Gap

The gap is not "agent identity." ERC-8004 and ERC-8122 address agent registries. The gap is also not "smart accounts." ERC-4337, ERC-7579, ERC-6900, and ERC-6551 cover accounts and modules.

The missing primitive is a minimal, token-compatible control plane for paid services:

- who owns the service identity
- who operates it
- where revenue routes
- which service and payment manifests clients should trust
- how a usage receipt binds to that service identity

## Collision Avoidance

This ERC should explicitly avoid:

- registering agents globally
- defining reputation or validation scores
- defining escrow job lifecycle
- defining AI agent wallet policies
- defining token-bound account deployment
- defining x402 schemes, facilitators, or settlement
- defining MCP runtime behavior

## Sources Used

- ERC-165: https://eips.ethereum.org/EIPS/eip-165
- ERC-721: https://eips.ethereum.org/EIPS/eip-721
- ERC-1155: https://eips.ethereum.org/EIPS/eip-1155
- ERC-6551: https://eips.ethereum.org/EIPS/eip-6551
- ERC-4337: https://eips.ethereum.org/EIPS/eip-4337
- ERC-7579: https://eips.ethereum.org/EIPS/eip-7579
- ERC-6900: https://eips.ethereum.org/EIPS/eip-6900
- ERC-7656: https://eips.ethereum.org/EIPS/eip-7656
- ERC-8004: https://eips.ethereum.org/EIPS/eip-8004
- ERC-8122: https://eips.ethereum.org/EIPS/eip-8122
- ERC-8183: https://eips.ethereum.org/EIPS/eip-8183
- x402: https://github.com/x402-foundation/x402
- MCP: https://modelcontextprotocol.io/specification/2025-11-25
- EIP-1: https://eips.ethereum.org/EIPS/eip-1

