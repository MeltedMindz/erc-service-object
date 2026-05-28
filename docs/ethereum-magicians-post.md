# Ethereum Magicians Post Draft

Live thread: https://ethereum-magicians.org/t/erc-service-objects/28659

Title: ERC draft: Service Objects for ERC-721 service assets

Category: ERCs

Tags: `erc`, `nft`, `metadata`, `service`, `payments`, `standards`

---

I would like feedback on a small ERC-721 extension for service objects.

## Problem

A transferable ERC-721 token can represent control over an offchain service, but clients and indexers do not have a standard way to resolve the current service manifest, service operator, or payment route before interacting with that service.

Today, each service marketplace, API provider, agent registry, or payment middleware has to invent its own metadata and payment-route conventions. That makes it hard for wallets, indexers, and clients to answer basic questions:

- Which manifest describes this service?
- Which operator is currently associated with it?
- Which revenue recipient and payment manifest should paid endpoints use?
- Did the payment route change since the client last inspected it?

## Proposed primitive

The proposed base interface is intentionally small:

```solidity
interface IERCServiceObject is IERC165 {
    event ServiceManifestUpdated(uint256 indexed serviceId, string uri, bytes32 indexed manifestHash);

    event ServiceOperatorUpdated(uint256 indexed serviceId, address indexed operator, uint64 expiresAt);

    event ServicePaymentRouteUpdated(
        uint256 indexed serviceId,
        address indexed revenueRecipient,
        string paymentURI,
        bytes32 indexed paymentManifestHash,
        uint64 routeNonce
    );

    function serviceManifest(uint256 serviceId)
        external
        view
        returns (string memory uri, bytes32 manifestHash);

    function serviceOperator(uint256 serviceId)
        external
        view
        returns (address operator, uint64 expiresAt);

    function servicePaymentRoute(uint256 serviceId)
        external
        view
        returns (
            address revenueRecipient,
            string memory paymentURI,
            bytes32 paymentManifestHash,
            uint64 routeNonce
        );
}
```

The current reduced interface ID is `0xf94c99e5`.

## Non-goals

This proposal does not define:

- service discovery
- reputation or validation
- payment settlement
- endpoint execution
- smart account modules
- MCP behavior
- x402 behavior
- escrow
- revenue splitting
- service quality guarantees

x402 and MCP can be used as offchain manifest profiles, but neither is required by the ERC.

## Relationship to existing ERCs

ERC-721 provides the ownership and transfer semantics. This proposal does not redefine ownership.

ERC-7656 defines generalized contract-linked service deployment and linking. This proposal defines service object semantics: manifest, operator, and payment route. It should be possible to expose this interface directly on an ERC-721 service token or through a later ERC-7656-linked profile.

ERC-8004 addresses agent identity, reputation, and validation. This proposal does not define an agent registry or trust system. A service object could be referenced by an ERC-8004 registration, and service route state could be used by clients before interacting with a registered agent.

ERC-6551, ERC-4337, ERC-7579, and ERC-6900 cover token-bound accounts and smart-account execution. Service accounts and receipt signing are useful extensions, but they are not part of the minimal base interface proposed here.

## Repository and drafts

Repository: https://github.com/MeltedMindz/erc-service-object

Minimal draft: https://github.com/MeltedMindz/erc-service-object/blob/main/docs/ERC-draft-minimal.md

Hardening review: https://github.com/MeltedMindz/erc-service-object/blob/main/docs/final-hardening-review.md

Reference implementation: https://github.com/MeltedMindz/erc-service-object/tree/main/src

## Questions for review

1. Is this better framed as an ERC-721 extension, an ERC-7656 service semantics profile, or both?
2. Is `serviceOperator` necessary in the base interface, or should the base only expose manifest and payment route?
3. Should the payment route include the revenue recipient, or should that be a separate getter?
4. Is `routeNonce` the right primitive for clients and indexers to detect stale payment offers?
5. Should ERC-1155 support be excluded from the base draft and handled only by a later singleton/controller profile?
6. Are signed usage receipts better as a separate ERC rather than an optional extension?

I am especially looking for feedback from ERC-7656, ERC-8004, wallet, marketplace, indexer, x402, MCP, and smart-account implementers.
