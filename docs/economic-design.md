# Economic Design

## Roles

| Role | Meaning | Transfer behavior |
| --- | --- | --- |
| Owner | Holder/controller of the service token. | Transfers with ERC-721/ERC-1155 semantics. |
| Operator | Address allowed to operate the service and sign receipts. | Cleared on transfer in the reference implementation. |
| Revenue recipient | Address or router that paid endpoints should use. | Resets to buyer in the reference implementation. |
| Service account | Optional operational account that may hold assets or execute actions. | Cleared on transfer in the reference implementation. |
| Receipt issuer | Additional signer allowed to issue receipts. | Invalidated by issuer epoch changes. |

ERC-721 approvals are intentionally not service operators. Marketplace approvals should not change endpoints, payment manifests, receipt signers, or revenue routes.

## Payment Routing

The core standard exposes a single revenue recipient:

```solidity
function serviceRevenueRecipient(uint256 serviceId) external view returns (address);
```

That address may be:

- an EOA
- a Safe
- an ERC-4337 smart account
- an ERC-6551 token-bound account
- a splitter or revenue router
- an escrow or subscription contract

The ERC does not standardize split math, refunds, subscription accounting, or slashing. Those are implemented behind the revenue recipient/router.

## x402 Fee Flow

For x402-native endpoints:

1. Client verifies the current payment manifest.
2. Server returns a live x402 `PAYMENT-REQUIRED` quote.
3. Client checks that the quote is allowed by the manifest.
4. Client signs a payment payload.
5. Server or facilitator settles using the selected x402 scheme.
6. Server returns a response and signed usage receipt.

The ERC does not require a facilitator or settlement rail. It only anchors the payment route and receipt verification context.

## Transfer Safety

The reference implementation makes a conservative buyer-protection choice: service transfer invalidates operational and payment route state. That prevents a seller from keeping the endpoint or revenue route after sale.

An implementation may support leases or encumbrances, but they should be explicit and indexable. Hidden leases are an adoption blocker for marketplaces.

## Incentives And Abuse Scenarios

| Scenario | Mitigation |
| --- | --- |
| Seller transfers token but keeps revenue route. | Reset or explicitly disclose route on transfer; bump route nonce. |
| Operator changes endpoint to a clone. | Hash service manifests and require operator events. |
| Resource server advertises stale x402 route. | Client verifies route nonce and payment manifest hash. |
| Server reuses or overuses payment authorization. | Use x402 payment identifiers, scheme nonces, deadlines, and request fingerprints. |
| Fake receipts inflate reputation. | Verify issuer, route nonce, issuer epoch, payment hash, and service identity. |
| Router later diverts funds. | Prefer immutable or timelocked routers and surface router metadata in manifests. |
| Token is marketed as passive income. | Standardize technical routing only; avoid yield/profit claims. |

## What Is Intentionally Out Of Scope

- revenue splits
- fee percentages
- escrow
- refunds
- subscriptions
- staking or slashing
- service-level agreements
- facilitator fees
- legal/business ownership rights
- securities or profit-sharing semantics

