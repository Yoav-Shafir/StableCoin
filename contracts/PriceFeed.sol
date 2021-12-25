//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./Base.sol";
import "./Borrowing.sol";

contract PriceFeed is Base {
    Borrowing borrowing;

    uint256 latestPrice;

    constructor() Base() {
        console.log("Deploying PriceFeed");
    }

    function initialize(address _nameRgistry) public override {
        Base.initialize(_nameRgistry);
        latestPrice = 1 * DECIMAL_PRECISION;

        (address _borrowing, ) = getContractInfo("Borrowing");
        borrowing = Borrowing(_borrowing);
    }

    function setEthPrice(uint256 _newPrice) external {
        latestPrice = _newPrice * DECIMAL_PRECISION;
    }

    function getEthPrice() external view returns (uint256) {
        // require(
        //     msg.sender == address(borrowing),
        //     "PriceFeed: Access denied for getPrice()"
        // );
        return latestPrice;
    }
}
