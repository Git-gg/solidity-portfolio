## Require vs If + Revert

A small practice contract comparing two equivalent ways to write access control in Solidity.

## What it does

The contract stores an admin address at deployment time. It exposes two view functions that both check whether the caller (msg.sender) is that admin, using two different styles:

checkAdmin() uses if (condition) revert(); which blocks execution with no error message.
checkAdminRequire() uses require(condition, "message"); which blocks execution and returns a readable error message.

Both approaches produce the same result: the function stops if the caller is not the admin. require is generally preferred in day-to-day code because it documents the reason for failure. A gas-optimized production version would use a custom error instead of a require string, since custom errors are cheaper while still being readable by tools like Etherscan.

## Concepts practiced

msg.sender for identifying the caller. constructor for storing a value once at deployment. Two equivalent syntaxes for access control: if/revert and require.

---

Simple practice project built while learning Solidity fundamentals.
