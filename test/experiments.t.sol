// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";

contract TestingExpiriments is Test {
    function testDefaultAccount() public view {
        console.log("default account: ", msg.sender);
    }
}
