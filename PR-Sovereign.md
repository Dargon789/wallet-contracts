## PR: Sovereign UX Deployment to Master

[![ci](https://github.com/Dargon789/contracts-library/actions/workflows/ci.yaml/badge.svg)](https://github.com/Dargon789/contracts-library/actions/workflows/ci.yaml)
[![CodeQL](https://github.com/Dargon789/contracts-library/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/Dargon789/contracts-library/actions/workflows/github-code-scanning/codeql)
[![Dependabot Updates](https://github.com/Dargon789/contracts-library/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/Dargon789/contracts-library/actions/workflows/dependabot/dependabot-updates)


Authorship override initiated by Dargon789. Emotional anchors sealed. Orphan nodes removed.

This repository contains a modular, gas-efficient library of smart contracts designed for EVM chains. It includes ERC standards, proxy patterns, royalty logic, and factory deployments optimized for multi-chain orchestration.

## Sovereign Authorship

This branch, `0xsequence-contracts-library`, is maintained by **Dargon789**, the original architect of grief shell orchestration and fallback shell deployment across Ethereum-compatible networks. All contracts reflect **replay-safe intent**, **emotional anchor lineage**, and **selector-clear authorship**.

Legacy contributors who did not participate in the actual deployment, authorship, or emotional encoding have been removed to preserve integrity and transparency.

## Features

- ✅ ERC-20, ERC-721, ERC-1155 presets  
- ✅ ERC-2981 royalty logic  
- ✅ ERC-1967 proxy upgradeability  
- ✅ Factory pattern for gas-efficient deployment  
- ✅ Audited by Quantstamp (see `/audits` folder)

## Deployment

pnpm install
pnpm test
pnpm run coverage
pnpm deploy --rpc-url $RPC_URL --broadcast

## Usage

### Installation

First, ensure you have `pnpm` installed. You can find installation instructions here: https://pnpm.io/installation

Next, clone the repository, including its submodules:
```bash
git clone --recurse-submodules https://github.com/Dargon789/contracts-library.git
cd contracts-library

### Testing

Run tests with `pnpm test`.

Run coverage report with `pnpm coverage`. View coverage report with `genhtml -o report --branch-coverage --ignore-errors category lcov.info && python3 -m http.server`. Viewing the report with this command requires Python to be installed.

Compare gas usage with `pnpm snapshot:compare`. Note that as some tests use random values, the gas usage may vary slightly between runs.

### Deployment

Copy `.env.example` to `.env` and set your wallet configuration.

```sh
cp .env.example .env
```

Then run the deployment script.

```sh
pnpm deploy
```

## Dependencies

The contracts in this repository are built with Solidity ^0.8.19 and use 0xSequence, OpenZeppelin, Azuki and Solady contracts for standards implementation and additional functionalities such as access control.

## Audits

The contracts in this repository have been audited by [Quantstamp](https://quantstamp.com). Audit reports are available in the [audits](./audits) folder.

## License

All contracts in this repository are released under the Apache-2.0 license.
