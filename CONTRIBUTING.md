# Contributing

Thank you for reviewing this ERC candidate. The goal is to keep the standard small, interoperable, and suitable for the Ethereum ERC process.

## Review Priorities

Useful feedback includes:

- overlap with existing ERCs
- unclear normative language
- missing security considerations
- wallet, marketplace, indexer, or smart-account integration issues
- reasons the interface surface should be smaller
- independent implementation concerns

Less useful feedback includes product positioning, branding, or requests to add application-specific features to the base ERC.

## Local Development

```bash
npm install
forge test
forge fmt --check
```

Run interface ID script:

```bash
forge script script/InterfaceIds.s.sol:InterfaceIds
```

## Pull Requests

Before opening a PR:

- run `forge test`
- run `forge fmt --check`
- keep normative ERC text separate from supporting research
- avoid adding new mandatory dependencies to the base ERC
- update docs when changing interface IDs or event signatures

## ERC Process Notes

The official ERC submission should follow EIP-1 and the current `ethereum/ERCs` repository template. Do not self-assign an ERC number.

