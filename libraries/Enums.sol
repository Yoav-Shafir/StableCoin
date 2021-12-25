//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

library Enums {
    // values 0 - 4
    enum Status {
        nonExistent,
        active,
        closedByOwner,
        closedByLiquidation,
        closedByRedemption
    }
}
