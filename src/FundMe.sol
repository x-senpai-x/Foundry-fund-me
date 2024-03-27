// SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner(); //defines custom error types used with revert statements

contract FundMe {
    using PriceConverter for uint256;
    //allows you to extend the functionality of the uint256 data type by adding functions defined in the PriceConverter library.
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public i_owner; //address of contract owner
    uint256 public constant MINIMUM_USD = 5e18; //minUSD reqd for contribution
    AggregatorV3Interface private s_priceFeed;//variable s_priceFeed of type AggregatorV3Interface 
    //added to constructor for modular chains
    //now pricefeed can be changed according to the chain we are on

    constructor( address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed=AggregatorV3Interface(priceFeed);
        //constructor is typically used for initialization tasks such as setting initial values of state variables
        // or performing other setup operations.
    }

    function fund() public payable {
        //public --> can be called from outside the contract
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Spend More ETH"
        ); /*
    .getConversionRAte is fn imported and checks if eth sent by address funder converted in USD
    is more than Minimum reqd */
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns(uint256) {
        /*
    getVersion() function provides a way for external entities to query the version of the 
    Chainlink price feed aggregator contract being used within the FundMe.sol contract.  */
        
        return s_priceFeed.version();
        //This interface allows interaction with the price feed aggregator contract.
    }

    modifier onlyOwner() {
        /*restrict access of some fns and operations to only owner 
    i.e if someone is calling a fn and if he is not owner then he might not be able to call the fn
    if this clause is added eg withdraw fn*/
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
        /*_; indicates where the body of the function being modified will be inserted. When a function
     with the onlyOwner modifier is called, the code inside the modifier (if (msg.sender != i_owner)
    revert NotOwner();) is executed first. If the condition (msg.sender != i_owner) is true
    (meaning the caller is not the owner), the function reverts with the NotOwner error.
    If the condition is false (meaning the caller is the owner), execution continues to the
    actual function body, denoted by _;.
    a modifier can include additional code besides the underscore (_) placeholder, but it's not mandatory
     */
    }

    function withdraw() public onlyOwner {
        //modifier added
        /*
  allows the owner of the contract to withdraw all funds collected in the contract
  resets the amounts funded by each address, clears the list of funders, 
  and transfers the remaining balance to the owner.
   */
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0); //new dynamically allocate memory of array/struct In this case length is 0
        //new is also used to create new instance of contract
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(
            ""
        ); /*
    The amount transferred is the entire balance of the contract (address(this).balance).
    
    empty quotation denotes no data is being sent along with value transfer  */
        require(callSuccess, "Call failed");
    }

    //If the revert message is not used with the call function and the call fails for any reason,
    //the transaction will revert, but the error message provided will be generic.

    //NOTE: EVEN IF TXN FAILS IRRESPECTIVE OF WHETHER REVERT IS USED OR NOT GAS WOULD STILL BE CONSUMED

    /*
    transfer
    payable(msg.sender.transfer(address(this).balance)) 
    //costs gas and is capped at 2300 gas and if any more gas is used then throws an error
    // insufficient for executing arbitrary contract code
    
    send
    bool sendSuccess=payable(msg.sender.send(address(this).balance) ;
    require (sendSuccess ,"Send failed");
    //in transfer it automatically reverts if transfer fails no need to add require
    //returns bool if more than 2300 gas used

    */

    /*
   call
   (bool callSuccess , bytes memory dataReturned)=payable(msg.sender.call{value:address(this).balance}("")) 
   require (callSuccess ,"Call failed");

   //no cap of gas


    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

*/

    /*
RECIEVE
gets triggered anytime a txn is sent from/to that contract
its triggered only when calldata is blank 

with calldata fallback is reqd 
ie can work even if data is sent with transacton */

    //NOTE recieve fallback etc are special functions they do not require function keyword
    //even constructor is a special function
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
    /*We are using recieve and fallback in this contract just in case somebody accidently sends us ETH
and forgets to call fund() function */
}
