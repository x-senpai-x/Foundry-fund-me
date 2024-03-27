// SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;
import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
contract FundMeTest is Test {
//most important thing to test is whether fund() is working so that we get correct conversion rate 
//To get correct conversion rate getVersion() should work
     //inherits from Test contract
    FundMe fundMe;
    function setUp() external {
      //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306)  ;//constructor//0x694AA1769357215DE4FAC081bf1f309aDC325306
      // fundMe variable of type FundMe is new fundme contract
      DeployFundMe deployFundMe= new DeployFundMe();
      fundMe=deployFundMe.run(); // returns fund me contract  now we only need to update address chain in script file and it automatically updates in test file
    }
    //now it is the deployFundMe contract that creates fundMe

    function testMinimumDollarIsFive() public {
      assertEq(fundMe.MINIMUM_USD(),5e18);//assertEq initites test
    }

    function testIsOwnerMsgSender() public{
      //whoever is calling fundMeTest is deploying fundME 
      console.log(fundMe.i_owner());//actual owner of fundMe
      console.log(msg.sender);//here msg.sender is 
      //console statement treated as test (gets printed in terminal)
      //assertEq(fundMe.i_owner(),msg.sender);//false bcoz we are calling fundMetest which is deploying fundMe 
      //assertEq(fundMe.i_owner(),address(this));//true
      //fundMeTest contract is owner of fundMe here 
      //address(this) denotes the address of current contract instance 
      //msg.sender however is the one who is currently executing the test function 
      //after again updating code so that it is modular and changing only script instead of both script and test
      //DeployFUndMe is the owner of fundMe
      //and msg.sender is the same 
      assertEq(fundMe.i_owner(),msg.sender);
    }
    function testPriceFeedVersionIsCorrect() public {
      uint256 version=fundMe.getVersion();
      console.log(version);
      //gives error on forge test --match-test testPriceFeedVersionIsCorrect
      //because 
      //we first call testPriceFeedVersionIsCorrect() we then call getVersion()
      //but it reverts because we are calling a contract address that doesnt exist
      //when we run tests in foundry and we don't specify a chain (np rpc url given )
      //foundry automatically creates an anvil chain to run tests and deletes when test is done
      //so we are calling a contract that doesn't exist
      
    }
    }
