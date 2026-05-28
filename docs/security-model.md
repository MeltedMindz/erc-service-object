# Security Model And Threat Analysis

## Security Boundary

This ERC can secure:

- service identity
- token ownership
- role authorization
- manifest commitments
- revenue recipient declarations
- receipt issuer authorization
- EIP-712 receipt verification
- audit events

This ERC cannot prove that an offchain service is honest, available, useful, non-malicious, or that a response is correct. A signed receipt proves a service identity signed a delivery claim, not that the output was high quality.

## Threat Matrix

| Threat | Risk | Mitigation |
| --- | ---: | --- |
| Endpoint spoofing | Critical | Bind endpoints to service manifest hash and operator-signed attestations. Prefer `.well-known` domain verification. |
| Payment replay | Critical | Use x402 payment identifiers, scheme-native nonces/deadlines, request fingerprints, and route nonce binding. |
| Receipt replay | Critical | Include service contract, service ID, manifest hash, route nonce, request hash, payment hash, issuer, and timestamp. Consume receipt hashes in any onchain claim path. |
| Signature replay | Critical | Use EIP-712 domain separation and ERC-1271 for smart contract signers. |
| Ownership hijacking | Critical | Keep service owner tied to ERC-721/1155 ownership. Do not treat marketplace approvals as service operators. |
| Operator abuse | High | Scope operator rights. Operators cannot change revenue recipients or payment manifests in the reference implementation. |
| Upgrade abuse | High | Prefer immutable contracts or timelocked upgrades. Surface implementation metadata. |
| Metadata poisoning | High | Hash manifests, sanitize display fields, and treat SVG/HTML/Markdown as hostile. |
| Registry poisoning | High | No mandatory registry. Identify services by chain, contract, and token ID. |
| Marketplace stale state | High | Orders should commit to route nonce, operator, revenue recipient, and manifest hashes. |
| Token-bound account capture | High | Marketplaces should inspect ERC-6551 account assets/modules before transfer. |
| MCP tool poisoning | Medium/High | Treat tool descriptions as untrusted. Require user consent for destructive or paid tool calls. |
| x402 facilitator trust | Medium/High | Facilitators are payment helpers, not service identity authorities. Verify offers against manifest. |
| Revenue confusion | Medium/High | Display revenue recipient separately from owner. |
| Availability failure | Medium | Service status and manifests help discovery, but uptime belongs to separate SLA/escrow systems. |

## Transfer Safety

On service-token transfer, the reference implementation:

- clears operator
- clears service account
- clears payment manifest
- resets revenue recipient to the new owner
- increments route nonce
- increments receipt issuer epoch

This prevents the seller from silently keeping operational or revenue control after transfer.

## Receipt Requirements

A valid receipt should commit to:

- chain ID through the EIP-712 domain
- verifying contract
- service ID
- payer
- issuer
- revenue recipient
- request hash
- response hash
- payment hash
- payment manifest hash
- route nonce
- issued timestamp

Historical receipt verification may require event logs or state at the issuance block because current operator state can change.

