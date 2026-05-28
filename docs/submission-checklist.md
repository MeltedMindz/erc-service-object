# ERC Submission Checklist

Status: public repository, candidate release, Ethereum Magicians discussion, and early-review `ethereum/ERCs` pull request are complete. The ERC PR now uses the editor-assigned number and proposal-specific discussion URL.

Official early-review PR: https://github.com/ethereum/ERCs/pull/1777

Official Ethereum Magicians discussion: https://ethereum-magicians.org/t/erc-service-objects/28659

## Public Repository

- [x] Repository is public.
- [x] License is CC0-1.0.
- [x] README explains the minimal ERC shape.
- [x] `CONTRIBUTING.md` exists.
- [x] `SECURITY.md` exists.
- [x] Issue and PR templates exist.
- [x] No secrets, credentials, private keys, or populated env files are committed.
- [x] `node_modules/`, `out/`, and `cache/` are not committed.
- [x] `git submodule update --init --recursive` succeeds.
- [x] `npm install` succeeds.
- [x] `npm run docs:links` succeeds.
- [x] `forge test` succeeds.
- [x] `forge fmt --check` succeeds.
- [x] Interface IDs are documented.

## Ethereum Magicians

- [x] Public discussion thread created in the ERCs category.
- [x] Thread links to the public repository.
- [x] Thread links to the minimal ERC draft.
- [x] Thread asks specifically for ERC-7656, ERC-8004, wallet, indexer, and smart-account review.
- [x] Draft `discussions-to` field updated with the thread URL.

## ERC Draft

- [x] Draft follows the current `ethereum/ERCs` preamble order.
- [x] No ERC number is self-assigned.
- [x] Title is 44 characters or fewer.
- [x] Description is one short sentence.
- [x] Author field is complete.
- [x] `status: Draft`.
- [x] `type: Standards Track`.
- [x] `category: ERC`.
- [x] `created` uses ISO date format.
- [x] `requires` includes only dependencies required to understand or implement the specification.
- [x] No fake external references.
- [x] No marketing claims.
- [x] Security Considerations are substantive.
- [x] Copyright section uses CC0.
- [x] Replace `eip: TBD` with the editor-assigned ERC number.
- [x] Replace `discussions-to: TBD` with the Ethereum Magicians thread URL.

## ERC PR

- [x] Fork `ethereum/ERCs`.
- [x] Add minimal draft under `ERCS/erc-TBD.md`.
- [x] Do not self-assign a number.
- [x] PR title follows `Add ERC: Service Objects`.
- [x] PR body links the public repository and Magicians discussion.
- [x] PR body links the Magicians thread.
- [x] CI passes after editor number assignment and Magicians discussion URL are available.
