//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {Enums} from "./Enums.sol";

library Types {
    struct LoanValues {
        uint256 ethPrice;
        uint256 collateralRatio;
        uint256 borrowingFee;
        uint256 borrowingRequestedAmount;
        uint256 borrowingCompositeDebt;
    }

    struct Vault {
        uint256 collateral;
        uint256 debt;
        Enums.Status status;
    }
}
