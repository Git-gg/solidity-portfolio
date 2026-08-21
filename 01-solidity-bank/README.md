## Solidity Bank

A practice bank contract built while learning Solidity fundamentals: mappings, conditionals, require validations, loops, msg.sender, and basic access control.

## What it does

Deposit: adds to the caller's balance (saldos), based on msg.sender so nobody can operate on someone else's balance.
Withdraw: subtracts from the caller's balance, with a require check for sufficient funds.
Client tier: classifies the caller as Bronce, Plata or Oro depending on their balance.
Interest simulation: projects how the caller's balance would grow over a number of years at a fixed 5% compound rate.
Owner reset: lets the contract owner (set at deployment via msg.sender) reset any address's balance to zero.

## Concepts practiced

mapping(address => uint256) to track a balance per wallet. if/else if/else conditionals. require for validation. for loops for accumulation (compound interest). msg.sender to identify the caller safely, instead of trusting a caller-supplied address. A basic owner pattern set in the constructor and checked with require(msg.sender == owner, ...).

## Note

This contract uses internal balances (uint256), not real ETH, it is an exercise in practicing contract logic before working with payable and msg.value.

---

Simple practice project built while learning Solidity fundamentals.
