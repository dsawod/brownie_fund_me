// SPDX-License-Identifier: MIT

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

pragma solidity ^0.6.6;

contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;

    address[] public funders;

    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        // $ 50 -> wei
        uint256 minimumUSD = 50 * 10**18;

        //require(getConversionRate(msg.value) >= minimumUSD);
        //revert with message
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more Eth!"
        );

        addressToAmountFunded[msg.sender] += msg.value;

        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        /**(uint80 roundId,
         int256 answer,
         uint256 startedAt,
         uint256 updatedAt,
         uint80 answerInRound) 
        = priceFeed.latestRoundData();
        return uint256(answer); 
        compiler complains about used touple variables
        */
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 1000000000);
    }

    //1 gwei = 1000000000 wei
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUSD;
    }

    function getEntranceFee() public view returns (uint256) {
        //minimum USD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        //Anyone can withdraw all eth they sent
        //msg.sender.transfer( address(this).balance);
        //Only want contract owner to do this
        //require(msg.sender == owner);  // don't need with modifier

        msg.sender.transfer(address(this).balance);

        for (uint256 index = 0; index < funders.length; index++) {
            address funder = funders[index];
            addressToAmountFunded[funder] = 0;
        }
        //reset array
        funders = new address[](0);
    }
}
