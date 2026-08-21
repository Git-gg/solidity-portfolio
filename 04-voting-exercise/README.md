## Solidity Voting Exercise

A simple learning exercise: a basic on-chain voting contract written while learning Solidity fundamentals.

## What it does

The contract starts with three proposals already loaded (Option A, Option B, Option C). Any address can vote once for one of them. The contract keeps track of who has already voted so nobody can vote twice, and it can tell you which proposal currently has the most votes.

## Concepts practiced

Structs for grouping related data (a proposal's description and vote count) together. Arrays of structs to store a list of proposals. A constructor that preloads data at deployment time. A mapping to track which addresses have already voted. require for basic access control (blocking a second vote). A loop that compares values across an array of structs to find the one with the highest count, similar to a classic "find the maximum" pattern.

## How to test it in Remix

Deploy the contract, three proposals are created automatically. Call vote(0) to vote for Option A, vote(1) for Option B, or vote(2) for Option C. Try calling vote again from the same account, it should revert with "You already voted". Switch to a different account in Remix and vote again, it should work. Call winner() to see the description of the proposal with the most votes.

---

Simple practice project built while learning Solidity fundamentals.
