# Adoption Strategy

## Submission Path

1. Open an Ethereum Magicians thread in the ERC category.
2. Present the narrow problem statement and explicitly distinguish the proposal from ERC-8004 and ERC-7656.
3. Collect feedback from x402, MCP, ERC-6551, account abstraction, Base, wallet, marketplace, and indexing communities.
4. Submit an ERC PR using `eip: TBD` and the EIP-1 format.
5. Keep the core interface small and move contentious features into optional extensions.

## Likely Review Criticism

- "ERC-8004 already covers agents."
- "ERC-7656 already covers linked services."
- "x402 should not be in an Ethereum ERC."
- "Receipts are offchain, so why standardize them?"
- "ERC-1155 ownership is ambiguous."
- "This is too specific to AI."
- "Marketplaces will not display these fields."

## Responses

ERC-8004 is an agent identity and trust registry. This ERC is a token-compatible service control and payment-manifest surface.

ERC-7656 is a generic linked-service factory. This ERC standardizes specific paid-service roles and receipt semantics.

x402 settlement remains offchain and rail-agnostic. The ERC only anchors a payment manifest hash and revenue recipient.

Receipts need standardized typed data so accounting, reputation, validation, and dispute systems can interoperate.

ERC-1155 support should be limited to implementations with unambiguous control of a service ID.

The standard should use "service" as the primary term. AI and MCP are important use cases, not normative dependencies.

## Initial Ecosystem Integrations

- Base service deployments using USDC-compatible x402 manifests
- ERC-6551 account explorers
- Safe and smart account receipt signing
- OpenSea-style metadata indexing
- The Graph and other indexers for role/manifest/receipt events
- viem/wagmi helper libraries for manifest and receipt verification
- MCP clients that can preflight service manifests
- x402 resource server middleware that checks `servicePaymentManifest`

## Risks To Adoption

- Too much AI-specific language.
- Mandatory global registry or facilitator assumptions.
- Requiring onchain receipts for every request.
- Treating revenue recipients as passive yield claims.
- Over-specifying MCP or x402 internals.
- Ambiguous ERC-1155 control semantics.
- Not giving marketplaces a simple state summary to display.

## What To Remove Or Simplify Before Submission

- Remove mandatory endpoint arrays from onchain interfaces.
- Remove any required revenue splitting.
- Remove leasing from the core.
- Remove any AI provider, model, or prompt-specific fields from core.
- Keep ERC-6551 and smart accounts optional.
- Keep x402 settlement schemes out of the ERC.
- Keep MCP runtime behavior out of the ERC.

