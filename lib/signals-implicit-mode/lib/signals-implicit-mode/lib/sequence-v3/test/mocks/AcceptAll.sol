// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.27;

contract AcceptAll {

  fallback() external payable { }

  receive() external payable { }

}
