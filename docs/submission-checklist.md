# ERC Submission Checklist

## Public Repository

- [ ] Repository is public.
- [ ] License is CC0-1.0.
- [ ] README explains the minimal ERC shape.
- [ ] `CONTRIBUTING.md` exists.
- [ ] `SECURITY.md` exists.
- [ ] Issue and PR templates exist.
- [ ] No secrets, credentials, private keys, or populated env files are committed.
- [ ] `node_modules/`, `out/`, and `cache/` are not committed.
- [ ] `git submodule update --init --recursive` succeeds.
- [ ] `npm install` succeeds.
- [ ] `forge test` succeeds.
- [ ] `forge fmt --check` succeeds.
- [ ] Interface IDs are documented.

## Ethereum Magicians

- [ ] Public discussion thread created in the ERCs category.
- [ ] Thread links to the public repository.
- [ ] Thread links to the minimal ERC draft.
- [ ] Thread asks specifically for ERC-7656, ERC-8004, wallet, indexer, and smart-account review.
- [ ] Draft `discussions-to` field updated with the thread URL.

## ERC Draft

- [ ] Draft follows `ethereum/ERCs/erc-template.md`.
- [ ] `eip: <to be assigned>` is preserved before editor assignment.
- [ ] Title is 44 characters or fewer.
- [ ] Description is one short sentence.
- [ ] Author field is complete.
- [ ] `status: Draft`.
- [ ] `type: Standards Track`.
- [ ] `category: ERC`.
- [ ] `created` uses ISO date format.
- [ ] `requires` includes only dependencies required to understand or implement the specification.
- [ ] No fake external references.
- [ ] No marketing claims.
- [ ] Security Considerations are substantive.
- [ ] Copyright section uses CC0.

## ERC PR

- [ ] Fork `ethereum/ERCs`.
- [ ] Add draft under `ERCS/eip-draft_service_objects.md`.
- [ ] Do not self-assign a number.
- [ ] PR title follows `Add ERC: Service Objects`.
- [ ] PR body links the Magicians thread and public repository.
- [ ] CI passes.
