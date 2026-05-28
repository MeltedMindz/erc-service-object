# Security Policy

## Supported Scope

This repository is an ERC candidate and reference implementation. Security review should focus on:

- Solidity reference implementation bugs
- incorrect ERC-165 interface reporting
- receipt signature verification issues
- replay or stale-route risks
- unsafe event or manifest semantics
- misleading security claims in the ERC draft

## Reporting Vulnerabilities

Please open a private GitHub security advisory if available, or contact the maintainers through the repository owner profile. If the issue is not exploitable and concerns standards language, a public issue is preferred.

Do not include private keys, live credentials, or sensitive production service details in public issues.

## Important Limitations

This ERC candidate cannot prove that an offchain service is honest, available, useful, safe, or correct. It only exposes service metadata and route commitments. Implementations using this work must perform their own service, endpoint, payment, and operational security reviews.

