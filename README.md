## Solidity Learning Portfolio

A collection of Solidity practice projects built while learning smart contract development, from fundamentals through security patterns. Each folder is a standalone project with its own contract(s) and README explaining what it does, line by line.

Start here: 05-cryptobank is the most complete project and the best one to review first, it combines everything from the other four plus deposit/withdraw limits and an emergency circuit breaker.

## Projects, in learning order

01-solidity-bank: the first project. A bank contract using internal balances (not real ETH), covering mappings, conditionals, require, loops, msg.sender, and a basic owner pattern.

02-require-vs-revert: a small focused contract comparing two equivalent ways to write access control in Solidity, if/revert versus require.

03-smart-contract-connectors: two separate contracts calling each other through an interface, without needing each other's full source code. Covers interfaces, constructors, and msg.sender across contract calls.

04-voting-exercise: an on-chain voting contract using structs, arrays, a constructor that preloads data, and a mapping to prevent double voting.

05-cryptobank: the most advanced project. A bank contract handling real ETH (payable, msg.value), with per-user and per-transaction limits, an emergency pause (circuit breaker), the Checks-Effects-Interactions pattern against reentrancy, and a full security analysis documenting both the protections implemented and the remaining design trade-offs.

## About this portfolio

These are learning projects, not production code. Each README documents not only what the contract does, but why it is built that way, and in several cases, real bugs that were found and fixed during development (an accounting bug that trusted user input instead of msg.value, an overwrite-instead-of-accumulate bug, and a reentrancy ordering issue). Understanding and fixing those bugs was part of the learning process.

---

Built while learning Solidity fundamentals, on the path toward a junior blockchain developer role.
