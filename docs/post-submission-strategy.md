# Post-Submission Strategy

## Likely Editor Feedback

- Reduce scope further.
- Remove or split optional receipt sections.
- Avoid x402 and MCP as normative dependencies.
- Clarify ERC-7656 relationship.
- Remove ERC-1155 from the base draft.
- Keep `requires` limited to standards required for implementation.
- Avoid external links in the official ERC body where possible.

## Likely Ecosystem Criticism

| Criticism | Recommended response |
| --- | --- |
| This duplicates ERC-7656. | ERC-7656 standardizes linked service deployment. This draft standardizes service route semantics. A linked service can expose this interface. |
| This duplicates ERC-8004. | ERC-8004 is identity, reputation, and validation. This draft is route and manifest state for an owned service token. |
| Wallets will ignore this. | Initial consumers are indexers, service clients, and payment middleware. Wallet UX can remain ordinary ERC-721 metadata. |
| x402 and MCP are not Ethereum standards. | Correct. They are examples of offchain profiles, not requirements. |
| Receipts are too complex. | Receipts are not in the reduced base draft. |
| Service quality cannot be enforced. | Correct. The ERC only exposes commitments and route state. |

## Recommended Revisions If Challenged

1. Drop `serviceOperator` if reviewers want the absolute minimum.
2. Rename to `ERC Service Routes` if "Service Objects" sounds too broad.
3. Split payment route into a separate extension if reviewers object to payment semantics in the base.
4. Move all x402/MCP text to non-normative examples.
5. Submit receipt verification later as a separate ERC after real deployments exist.

## Outreach Targets

- ERC-7656 author/reviewers
- ERC-8004 authors
- ERC-6551 maintainers
- Safe signatures team
- Base and x402 implementers
- MCP registry/server implementers
- viem and wagmi maintainers
- Reservoir/OpenSea indexing contacts
- The Graph/Substreams developers

