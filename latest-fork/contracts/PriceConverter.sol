// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract PriceConverter {

    // MATIC / USD
    address immutable private priceFeedAddress = 0x001382149eBa3441043c1c66972b4772963f5D43;
    AggregatorV3Interface internal priceFeed;
 
    constructor(){
       priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function getChainlinkDataFeedLatestAnswer() private view returns (int) {
        (
            /*uint80 roundID*/, 
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    function convertUsdToMatic(uint256 ticketPrice) external view returns (uint256) {
         uint256 price = uint(getChainlinkDataFeedLatestAnswer());
         uint256 cost_per_ticket_in_matic = SafeMath.div(ticketPrice, price);
         return cost_per_ticket_in_matic;
    } 
}