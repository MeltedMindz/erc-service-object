# Metadata And Manifest Schemas

The ERC stores only URI and hash commitments. The schemas below are recommended offchain formats for interoperability. `manifestHash` and related hashes are `keccak256` over the exact UTF-8 bytes fetched from the URI. Publishers may use canonical JSON to make hashes stable, but consumers verify bytes.

## Service Manifest

See [schemas/service-manifest.schema.json](schemas/service-manifest.schema.json).

Required concepts:

- service identity: chain ID, token standard, contract, token ID
- human-readable name and description
- service status
- MCP server metadata
- capability manifest pointer and hash
- provenance pointers and hashes
- x402 payment manifest pointer and hash

## Capability Manifest

See [schemas/capability-manifest.schema.json](schemas/capability-manifest.schema.json).

This is preflight metadata for wallets and indexers. MCP runtime `tools/list`, `resources/list`, and `prompts/list` remain authoritative.

## x402 Payment Manifest

See [schemas/x402-payment-manifest.schema.json](schemas/x402-payment-manifest.schema.json).

The manifest should list allowed origins, accepted `(scheme, network, asset, payTo)` rails, optional facilitators, resource patterns, and receipt requirements. Live x402 `PAYMENT-REQUIRED` responses remain the authoritative quotes.

## Usage Receipt

See [schemas/service-receipt.schema.json](schemas/service-receipt.schema.json).

Receipts are portable offchain artifacts. They should be signed by the current service operator, service account, or an authorized receipt issuer. Onchain anchoring is optional.

