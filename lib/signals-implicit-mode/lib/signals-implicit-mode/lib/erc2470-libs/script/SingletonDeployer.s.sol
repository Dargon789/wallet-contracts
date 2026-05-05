// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

import {
    ISingletonFactory,
    SINGLETON_DEPLOY_COST,
    SINGLETON_DEPLOY_TX,
    SINGLETON_EOA_ADDR,
    SINGLETON_FACTORY_ADDR
} from "../src/ISingletonFactory.sol";

error DeploymentFailed(string reason);

abstract contract SingletonDeployer is Script {
    ISingletonFactory private constant SINGLETON_FACTORY = ISingletonFactory(SINGLETON_FACTORY_ADDR);

    function _deploySingletonFactoryIfNotAlready(uint256 pk) internal {
        if (SINGLETON_FACTORY_ADDR.code.length <= 2) {
            if (SINGLETON_EOA_ADDR.balance < SINGLETON_DEPLOY_COST) {
                // Fund Singleton Factory EOA
                console.log("Funding Singleton Factory EOA");
                vm.startBroadcast(pk);
                payable(SINGLETON_EOA_ADDR).transfer(SINGLETON_DEPLOY_COST - SINGLETON_EOA_ADDR.balance);
                vm.stopBroadcast();
            }
            // Deploy Singleton Factory
            console.log("Deploying Singleton Factory to", SINGLETON_FACTORY_ADDR);
            vm.broadcastRawTransaction(SINGLETON_DEPLOY_TX);
        }
    }

    function _deployIfNotAlready(string memory name, bytes memory _initCode, bytes32 _salt, uint256 pk)
        internal
        returns (address addr)
    {
        _deploySingletonFactoryIfNotAlready(pk);
        addr = _singletonAddressOf(_initCode, _salt);
        if (addr.code.length <= 2) {
            console.log(name, "deploying to", addr);
            vm.startBroadcast(pk);
            address actualAddr = SINGLETON_FACTORY.deploy(_initCode, _salt);
            vm.stopBroadcast();
            if (addr != actualAddr) {
                revert DeploymentFailed("Deployed address mismatch");
            }
            if (addr.code.length <= 2) {
                revert DeploymentFailed("Deployment failed");
            }
        } else {
            console.log(name, "already deployed to", addr);
        }
        return addr;
    }

    function _singletonAddressOf(bytes memory _initCode, bytes32 _salt) internal pure returns (address addr) {
        return address(
            uint160(
                uint256(
                    keccak256(abi.encodePacked(bytes1(0xff), address(SINGLETON_FACTORY), _salt, keccak256(_initCode)))
                )
            )
        );
    }
}
