// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";

import {HelperConfig} from "./HelperConfig.s.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    // helperConfig checks the network and returns the correct config for that enviornment
    HelperConfig helperConfig = new HelperConfig();

    function run() external returns (FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe(helperConfig.activeNetworkConfig());
        vm.stopBroadcast();
        return fundMe;
    }
}
