// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {SingletonDeployer} from "../script/SingletonDeployer.s.sol";
import {MockERC20} from "forge-std/mocks/MockERC20.sol";

contract MockERC20Deployer is SingletonDeployer {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        bytes32 salt = bytes32(0);
        bytes memory initCode = abi.encodePacked(type(MockERC20).creationCode);
        _deployIfNotAlready("MockERC20", initCode, salt, pk);
    }
}
