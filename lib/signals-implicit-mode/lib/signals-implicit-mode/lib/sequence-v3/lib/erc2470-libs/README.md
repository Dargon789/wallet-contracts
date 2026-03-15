# ERC-2470 Libs

This repository contains helpers for interacting with the [ERC-2470 Singleton Deployer](https://eips.ethereum.org/EIPS/eip-2470) in [forge scripts](https://book.getfoundry.sh/reference/forge/forge-script).

## Usage

Install this package via forge install:

```bash
forge install ScreamingHawk/erc2470-libs
```

Base your scripts on the `SingletonDeployer` script contract:

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {SingletonDeployer, console} from "erc2470-libs/script/SingletonDeployer.s.sol";
import {MyContract} from "../src/MyContract.sol";

contract Deploy is SingletonDeployer {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        bytes32 salt = bytes32(0);
        address exampleConstructorArg = address(0);

        bytes memory initCode = abi.encodePacked(type(MyContract).creationCode, abi.encode(exampleConstructorArg));

        address expectedAddr = _singletonAddressOf(initCode, salt);
        address actualAddr = _deployIfNotAlready("MyContract", initCode, salt, pk);
    }
}
```

This script will deploy your contract using the `SingletonDeployer` and output the address of the deployed contract.
If your contract has already been deployed, the address will be returned without deploying again.
If the `SingletonDeployer` has not yet been deployed on chain, that will be done first.

> [!NOTE]
> The `SingletonDeployer` has a fixed gas cost which may not be compatible with all networks. If deployment fails, check the gas settings of the network.
> A network base fee exceeding 100 gwei will cause the deployment to fail.
> Networks requiring additions gas costs (L2, etc) will require additional funds for the factory deployer.

Ensure you have your private key set in your `.env` file:

```txt
PRIVATE_KEY=0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

Then run your script using [forge script](https://book.getfoundry.sh/reference/forge/forge-script):

```bash
forge script script/Deploy.s.sol
```

> [!WARNING]
> Forge is unable to automatically verify deployments created via the `SingletonDeployer`. You will need to manually verify the contract using the `forge verify` command.

### Git Hooks

To install git hooks run the following:

```bash
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
```

### Testing

Test by running the `MockERC20Deployer` script against a local anvil instance (or the network of your choice):

```bash
anvil
```

```bash
forge script script/MockERC20Deployer.s.sol --rpc-url http://localhost:8545
```
