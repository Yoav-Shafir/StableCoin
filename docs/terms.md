Stable coin
1 coin equal 1 USD

Collateral of 110%
Means that the user (borrower) needs to send enough Eth which has a value in USD equal to the amount of stable coins
he wants to borrow + 10%

Example:

- Collateral ratio is 110%
- User wants to borrow 100 stable coin.
- Lets say 1 Eth = 1 USD
  -> The user needs to send 110 Eth

If the Eth value in USD goes down below 1 USD which means the 110% ratio is no longer kept, then a liquidation process starts

Before Eth price in USD goes down
110 Eth equals 110 USD -> This covers the entire borrowing amount (100) + 10% -> This is a good collateral ratio

Eth price in USD goes down to 1 Eth = 0.5 USD
110 Eth equals 55 USD -> This doesnt even cover the borrowing amount -> collateral ratio is only 55% -> triggers liquidation

Values in Wei:

Collateral ratio of 150%
150 = 150000000000000000000

100 = 100000000000000000000

Eth price in USD 1 Eth = 1 USD
1 = 1000000000000000000

Borrowing fee
0.5 = 500000000000000000

GAS_COMPANSATION:
10 = 10000000000000000000

Composite debt:
110.5 = 110500000000000000000
