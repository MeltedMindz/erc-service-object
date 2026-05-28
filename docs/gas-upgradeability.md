# Gas And Upgradeability Analysis

## Gas Optimization

The reference implementation follows the intended gas model:

- Store hashes and short role fields onchain, not JSON.
- Keep dynamic endpoint, capability, x402, and MCP details offchain.
- Use events for indexers instead of enumerable onchain registries.
- Use EIP-712 signed receipts offchain and anchor only selected receipts.
- Use custom errors instead of revert strings.
- Use one packed service struct for account, operator, expiry, route nonce, issuer epoch, revenue recipient, and hashes.

Current gas snapshot highlights:

| Test flow | Gas |
| --- | ---: |
| Mint initializes service | 225320 |
| Owner/operator permissions | 253332 |
| Revenue and payment manifest route update | 232825 |
| Transfer resets operational rights | 273852 |
| Verify and anchor receipt | 323477 |

High-volume services should not anchor every receipt onchain. They should issue signed receipts offchain and anchor only dispute receipts, accounting checkpoints, or validation proofs.

## Upgradeability

The ERC should be interface-stable and extension-based. New behavior should be added as optional ERC-165 interfaces, not by changing the core interface.

Compliant implementations may be:

- immutable ERC-721 or ERC-1155 contracts
- ERC-1167 clones with immutable implementation commitments
- ERC-1967/UUPS proxies
- diamond/facet systems, if storage and interface discovery remain reliable

Recommended upgrade rules:

- Core token ownership semantics should be immutable or timelocked.
- Upgradeable contracts should expose admin, implementation, and version metadata.
- Upgrades should emit standard upgrade events.
- Operational account implementation/code hash should be visible in the service manifest.
- Service account modules and session keys should bind to current route nonce or authority epoch.

## Minimal Proxy Strategy

A factory may deploy many service-token collections or service registrars as ERC-1167 clones. The core ERC does not require a factory. If a factory is used, it should publish implementation addresses and source verification so indexers can trust interface support.
