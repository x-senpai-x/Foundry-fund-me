// SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.Sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
  //on local anvil deploy mocks 
  //else frab existing address from live network
  NetworkConfig public activeNetworkConfig;
  uint8 public constant DECIMALS=8;
  int256 public constant INITIAL_PRICE=2000e8;
  struct NetworkConfig{
    address pricefeed;
  }
  constructor(){
    if (block.chainid==11155111) {
      //chain id of sepoliaEthexchange
      activeNetworkConfig=getSepoliaEthConfig();
    }
    else if (block.chainid==1){
      activeNetworkConfig=getMainnetEthConfig();
    }
    else {
      activeNetworkConfig=getOrCreateAnvilEthConfig();
    }
  }
  function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
    NetworkConfig memory sepoliaConfig=NetworkConfig({
      pricefeed:0x694AA1769357215DE4FAC081bf1f309aDC325306 //sepoliatestnet address for eth usd
    });
    return sepoliaConfig;
  }
  function getMainnetEthConfig() public pure returns (NetworkConfig memory){
    NetworkConfig memory ethConfig=NetworkConfig({
      pricefeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 //ethereummainnet address for eth usd
    });
    return ethConfig;
  }
  function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory){
    //deploy the mocks 
    //much faster as this is done on local chain 
    //no api calls needed to make to alchemy 
    //return the mock address
    if (activeNetworkConfig.pricefeed!=address(0)){
      // if a price feed has not been set then address points to 0 
      // if a price feed has been set then there is no need to broadcast 
      return activeNetworkConfig;
    }
    vm.startBroadcast();
    MockV3Aggregator mockPriceFeed=new MockV3Aggregator(DECIMALS,INITIAL_PRICE);//ethusd has 8 decimals
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig=NetworkConfig({
      pricefeed:address(mockPriceFeed)
    });
    return anvilConfig;
  }

}