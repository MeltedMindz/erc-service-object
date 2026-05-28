# Protocol Architecture

## Core Model

```mermaid
flowchart LR
  Owner["Token owner"]
  Token["ERC-721 or ERC-1155 service token"]
  Interface["IERCServiceObject via ERC-165"]
  Operator["Operator / receipt issuer"]
  Revenue["Revenue recipient or router"]
  Account["Optional service account"]
  Manifest["Service manifest URI + hash"]
  Payment["x402 payment manifest URI + hash"]
  MCP["MCP endpoint and capability manifest"]
  Receipt["EIP-712 usage receipt"]

  Owner --> Token
  Token --> Interface
  Interface --> Operator
  Interface --> Revenue
  Interface --> Account
  Interface --> Manifest
  Interface --> Payment
  Manifest --> MCP
  Operator --> Receipt
  Payment --> Receipt
```

## x402 Payment Flow

```mermaid
sequenceDiagram
  participant Client
  participant Token as Service Token
  participant Server as Resource Server
  participant Facilitator
  participant Chain

  Client->>Token: servicePaymentManifest(serviceId)
  Client->>Client: fetch URI and verify hash
  Client->>Server: request paid resource
  Server-->>Client: 402 + PAYMENT-REQUIRED
  Client->>Client: verify offer against manifest and revenueRecipient
  Client->>Server: retry with PAYMENT-SIGNATURE
  Server->>Facilitator: verify/settle, optional
  Facilitator->>Chain: settle payment, scheme-specific
  Facilitator-->>Server: settlement response
  Server-->>Client: 200 + PAYMENT-RESPONSE + signed receipt
```

The live x402 offer remains the price quote. The onchain payment manifest is the authorization envelope.

## MCP Service Discovery Flow

```mermaid
sequenceDiagram
  participant Wallet
  participant Token as Service Token
  participant Manifest as Service Manifest
  participant MCP as MCP Server

  Wallet->>Token: serviceManifest(serviceId)
  Wallet->>Manifest: fetch URI
  Wallet->>Wallet: verify manifest hash
  Wallet->>MCP: initialize
  MCP-->>Wallet: serverInfo and capabilities
  Wallet->>MCP: tools/list or resources/list
  Wallet->>Wallet: compare runtime claims to manifest
```

Runtime MCP discovery stays authoritative because tools can be dynamic. The manifest is a preflight commitment and provenance record.

## Minimal Viable Standard Surface

Core:

- service account discovery
- service operator discovery with expiry
- revenue recipient discovery
- service manifest URI/hash
- payment manifest URI/hash/route nonce
- receipt issuer authorization
- EIP-712 receipt hash and verification
- optional receipt anchoring event

Optional extensions:

- ERC-6551 account binding details
- lease and encumbrance reporting
- revenue splitting metadata
- onchain receipt checkpoints
- ERC-7579/ERC-6900 module policy profiles
- validation/reputation adapters

