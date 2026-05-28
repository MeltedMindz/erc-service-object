# Example Service Object Lifecycle

## 1. Mint

The issuer mints an ERC-721 service token with:

- service manifest URI/hash
- x402 payment manifest URI/hash
- initial revenue recipient
- initial route nonce

```solidity
uint256 serviceId = service.mintService(
    owner,
    "ipfs://service-manifest",
    serviceManifestHash,
    "ipfs://payment-manifest",
    paymentManifestHash
);
```

## 2. Operator Assignment

The token owner assigns an operator with optional expiry:

```solidity
service.setServiceOperator(serviceId, operator, uint64(block.timestamp + 30 days));
```

The operator can update the service manifest but cannot change revenue routing in the reference implementation.

## 3. Endpoint Registration

The endpoint is registered offchain in the service manifest and committed onchain through the manifest hash:

```solidity
service.setServiceManifest(serviceId, "ipfs://service-manifest-v2", serviceManifestHashV2);
```

The manifest may include MCP server metadata, endpoint attestations, capability manifest pointers, provenance hashes, and the payment manifest pointer.

## 4. Payment Route Settlement

x402 settlement happens outside this ERC. Clients:

1. Read `servicePaymentManifest(serviceId)`.
2. Fetch and hash-check the payment manifest.
3. Call the paid endpoint.
4. Verify the returned `PAYMENT-REQUIRED` offer is allowed by the manifest.
5. Send `PAYMENT-SIGNATURE`.
6. Receive the response and signed receipt.

The onchain `serviceRevenueRecipient(serviceId)` is the recipient or router clients expect the payment manifest to use.

## 5. Receipt Verification

The service issues an EIP-712 receipt. The receipt is valid when:

- it is signed by the active operator, service account, or authorized issuer
- its `paymentManifestHash` equals the current payment manifest hash
- its `routeNonce` equals the current route nonce
- its `issuerEpoch` equals the current issuer epoch
- its `receiptURIHash` matches the receipt URI being anchored

```solidity
bool ok = service.verifyServiceReceipt(receipt, signature);
```

Optional onchain anchoring:

```solidity
bytes32 receiptHash = service.anchorServiceReceipt(receipt, signature, "ipfs://receipt");
```

## 6. Ownership Transfer

When a service token transfers in the reference implementation:

- service account is cleared
- operator is cleared
- revenue recipient resets to the new owner
- payment manifest is cleared
- route nonce increments
- issuer epoch increments

This prevents stale endpoints, signers, or payment routes from silently surviving a sale.

