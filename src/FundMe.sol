// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {PriceConvertor} from "./PriceConvertor.sol";

error NotOwner();

contract FundMe {
    // attach a library for a specific datatype
    // makes library methods available on any var which is that datatype ?!?!?!
    // var value is automatically passed to method as first arg
    using PriceConvertor for uint256;

    // keep track of addresses we've received eth from
    address[] public s_funders;
    mapping(address funder => uint256 amountFunded)
        public s_addressToAmountFunded;

    // constant/immutable variables save gas - can use if value is never going to be changed
    address private immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    // runs when contract is deployed
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // can perform exponentiation like this is solidity
    // 5 * (10 ** 18)
    // 5e18 is a scientific notation known as e notation :)
    uint256 public constant MINIMUM_USD = 5e18; // 5 * 10 ^ 18

    function fund() public payable {
        // revert if amount of eth sent isn't enough
        require(
            msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD,
            "Didn't send enough ETH!"
        );
        s_funders.push(msg.sender);
        // add amount received to anything already received from same sender
        s_addressToAmountFunded[msg.sender] += msg.value;
        // addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    // use modifer to make sure address calling function is contract owner
    function withdraw() public onlyOwner {
        // set all address mapping values to zero
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // reset funders array to a new blank array
        s_funders = new address[](0);

        // msg.sender = address
        // payable(msg.sender) = payable address

        // call - lower level, powerful. Preferred way to transfer eth
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed!!");
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // reset funders array to a new blank array
        s_funders = new address[](0);

        // msg.sender = address
        // payable(msg.sender) = payable address

        // call - lower level, powerful. Preferred way to transfer eth
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed!!");
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    // like a decorator - attach some functionality to other methods
    modifier onlyOwner() {
        // fail if sender isn't contract owner - using custom error uses less gas!!
        if (msg.sender != i_owner) {
            revert NotOwner();
        }

        // require(msg.sender == i_owner, "Sender is not owner!!");

        // _ means carry on with modified function
        _;
    }

    // can hand off simple eth transfers to our fund function
    // this will actually
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / Pure Functions
     */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}

// transfer - if action fails it will error and reverse the tx

// address must be payable to send it eth
// get address of this actual contract with address(this)
// payable(msg.sender).transfer(address(this).balance);

// send - returns boolean to indicate whether transfer was successful
// bool sendSuccess = payable(msg.sender).send(address(this).balance);
// can then assert and send useful error message if sending failed
// require(sendSuccess, "Send failed!!");
