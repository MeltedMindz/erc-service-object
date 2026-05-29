# ERC Service Objects

[![Foundry](https://img.shields.io/badge/built%20with-Foundry-111111.svg)](https://book.getfoundry.sh/)
[![CI](https://github.com/MeltedMindz/erc-service-object/actions/workflows/ci.yml/badge.svg)](https://github.com/MeltedMindz/erc-service-object/actions/workflows/ci.yml)
[![Solidity](https://img.shields.io/badge/solidity-0.8.25-363636.svg)](https://soliditylang.org/)
[![License: CC0-1.0](https://img.shields.io/badge/license-CC0--1.0-lightgrey.svg)](LICENSE)

This repository contains an Ethereum ERC candidate package for **Service Objects**: an ERC-721 extension for service manifests, service operators, and payment routes.

The current recommended submission shape is deliberately small:

- `serviceManifest(tokenId) -> (uri, manifestHash)`
- `serviceOperator(tokenId) -> (operator, expiresAt)`
- `servicePaymentRoute(tokenId) -> (revenueRecipient, paymentURI, paymentManifestHash, routeNonce)`

The repository also includes supporting research and a richer reference implementation with optional receipt and service-account ideas. Those are not recommended as mandatory base ERC scope.

## What This ERC Does Not Do

This ERC does not define service discovery, reputation, validation, payment settlement, endpoint execution, smart account behavior, MCP, x402, escrow, revenue splitting, or any specific offchain service protocol.

## Primary Documents

- Minimal submission draft: [docs/ERC-draft-minimal.md](docs/ERC-draft-minimal.md)
- Final hardening review: [docs/final-hardening-review.md](docs/final-hardening-review.md)
- Full first-pass draft and supporting package: [docs/ERC-draft.md](docs/ERC-draft.md)
- Architecture: [docs/architecture.md](docs/architecture.md)
- Security model: [docs/security-model.md](docs/security-model.md)
- Standards analysis: [docs/standards-analysis.md](docs/standards-analysis.md)
- Ethereum Magicians post draft: [docs/ethereum-magicians-post.md](docs/ethereum-magicians-post.md)
- Submission checklist: [docs/submission-checklist.md](docs/submission-checklist.md)

## Repository Layout

```text
interfaces/      Solidity interfaces for the first-pass package
src/             ERC-721 reference implementation and examples
script/          Deployment and interface-id scripts
test/            Foundry tests
docs/            ERC drafts, review reports, schemas, and submission material
docs/diagrams/   Mermaid source and exported architecture diagram
```

## Setup

Requirements:

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js 20 or newer
- npm

From a clean clone:

```bash
git submodule update --init --recursive
npm install
forge test
forge fmt --check
```

Useful commands:

```bash
forge test -vvv
npm run docs:links
forge snapshot --snap .gas-snapshot
forge script script/InterfaceIds.s.sol:InterfaceIds
```

Deployment example:

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url $RPC_URL \
  --account deployer \
  --broadcast
```

Never commit private keys or populated `.env` files.

## Reference Implementation

The current reference implementation is intentionally more complete than the recommended minimal ERC submission. It demonstrates:

- ERC-721 service token behavior
- service manifest and payment manifest commitments
- operator and revenue recipient separation
- route nonce invalidation
- ERC-1271-compatible receipt verification through OpenZeppelin `SignatureChecker`
- optional receipt anchoring
- ERC-4906 metadata update events

Core files:

- [interfaces/IERCServiceObject.sol](interfaces/IERCServiceObject.sol)
- [interfaces/IERCServiceObjectController.sol](interfaces/IERCServiceObjectController.sol)
- [src/TokenizedAutonomousService.sol](src/TokenizedAutonomousService.sol)
- [src/examples/ExampleX402SettlementRecorder.sol](src/examples/ExampleX402SettlementRecorder.sol)
- [test/TokenizedAutonomousService.t.sol](test/TokenizedAutonomousService.t.sol)

Current first-pass interface IDs:

- `IERCServiceObject`: `0x4850f8e0`
- `IERCServiceObjectController`: `0xf2e87b1d`

Recommended reduced base interface ID:

- `IERCServiceObject`: `0xf94c99e5`

## Minimal Service Lifecycle

1. Mint a service token with service and payment manifest hashes.
2. Owner assigns a service operator with optional expiry.
3. Owner publishes or updates the payment route.
4. Client reads the route and verifies offchain payment offers against it.
5. Indexers reconstruct current state from service events.

## Public Review Status

This is a pre-submission ERC candidate under review as ERC-8278. Public discussion is live on Ethereum Magicians, and the draft pull request is open against `ethereum/ERCs`.

- Ethereum Magicians discussion: https://ethereum-magicians.org/t/erc-8278-service-objects/28659
- ERC pull request: https://github.com/ethereum/ERCs/pull/1777

## License

CC0-1.0. See [LICENSE](LICENSE).
