// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script} from "../lib/forge-std/src/Script.sol"; 
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script{
  function run() external returns (FundMe){
    //any statement before start broadcast is not a real transaction
    HelperConfig helperConfig = new HelperConfig();
    address ethUsdPriceFeed=helperConfig.activeNetworkConfig();

    vm.startBroadcast();
    FundMe fundMe = new FundMe(ethUsdPriceFeed);
    vm.stopBroadcast();
    return fundMe;
  }
}