## Simple Smart Contract Connectors

A beginner-friendly practice project showing how one smart contract can call a function on a different, already-deployed smart contract, using an interface. No prior programming experience needed to follow along, every line is explained below.

## The idea, in plain words

Imagine two separate buildings, each with its own street address. One building (Warehouse) stores a number. The other building (Worker) wants to tell the Warehouse "add this amount to your total", without having a copy of the Warehouse's blueprints (its full code).

To do that, Worker only needs two things:

Thing 1: The Warehouse's address (like a street address).
Thing 2: A menu of what the Warehouse can do (the interface), just the names of the actions available, not how they work internally.

That's the whole idea behind this project.

## The three files

```
contracts/Warehouse.sol    -> the contract that gets called
interfaces/IWarehouse.sol  -> the "menu" describing Warehouse's functions
contracts/Worker.sol       -> the contract that calls Warehouse
```

## File 1: contracts/Warehouse.sol

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.35;

contract Warehouse {

    uint256 public totalStored;

    function addAmount(uint256 amount) external {
        totalStored = totalStored + amount;
    }
}
```

Line by line: `pragma solidity 0.8.35;` tells the compiler which version of the Solidity language to use. `contract Warehouse {` opens a "box" named Warehouse that will hold data and actions. `uint256 public totalStored;` a permanent number stored inside this contract, starting at 0. `public` means anyone can read it from outside. `function addAmount(uint256 amount) external {` an action anyone can trigger, that receives one number called `amount`. `totalStored = totalStored + amount;` takes whatever was already stored, adds the new amount, and saves the result back.

This contract has no idea that Worker exists. It just exposes a public action that anyone (including another contract) is allowed to call.

## File 2: interfaces/IWarehouse.sol

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.35;

interface IWarehouse {

    function addAmount(uint256 amount) external;
}
```

Line by line: `interface IWarehouse {` this is not a real, deployable contract with its own storage. It is only a description, a "menu", of functions that some other contract out there is expected to have. `function addAmount(uint256 amount) external;` notice there is no `{ }` body here, just a semicolon. An interface never says how the function works, only its name and what it needs. The real logic lives in Warehouse.sol.

Important rule: the function name and parameters here must match exactly the real function in Warehouse.sol. If they don't match, the connection won't work.

## File 3: contracts/Worker.sol

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.35;

import "../interfaces/IWarehouse.sol";

contract Worker {

    address warehouseContract;

    mapping(address => uint256) public timesWorked;

    constructor(address initialAddress) {
        warehouseContract = initialAddress;
    }

    function work(uint256 value) external {
        IWarehouse(warehouseContract).addAmount(value);
        timesWorked[msg.sender] = timesWorked[msg.sender] + 1;
    }
}
```

Line by line: `import "../interfaces/IWarehouse.sol";` brings in the "menu" defined in the other file, so this contract knows it exists and what it offers. `address warehouseContract;` a permanent storage slot that will hold only the address of the real Warehouse contract. On its own, an address is just data, it cannot be "called" like a function yet. `mapping(address => uint256) public timesWorked;` a lookup table: for every wallet address, it stores how many times that wallet has called the work function. `constructor(address initialAddress) {` code that runs once, automatically, the moment this contract is deployed. `warehouseContract = initialAddress;` saves the Warehouse's address into permanent storage, so this contract will always remember who to talk to. `IWarehouse(warehouseContract).addAmount(value);` this is the key line. warehouseContract alone is just an address, like a phone number written on paper. Wrapping it in `IWarehouse(...)` turns that plain address into something you can actually interact with. `.addAmount(value)` is the actual call, like dialing that phone number and making the request. `timesWorked[msg.sender] = timesWorked[msg.sender] + 1;` this line runs entirely inside Worker, not inside Warehouse. msg.sender is the wallet address that called work right now, Solidity provides it automatically and it cannot be faked.

## Why the data lives in different places

totalStored lives inside Warehouse, check its value there, regardless of which contract triggered the update. timesWorked lives inside Worker, it is Worker's own record of who has called it, so you check it there, passing the calling wallet's address.

## A simple analogy

Think of Worker as a waiter and Warehouse as the kitchen. When you order food, the waiter goes to the kitchen and asks for it (Worker calls Warehouse), the food is prepared and stays in the kitchen's records (totalStored lives in Warehouse). The waiter also writes down in their own notebook how many times you ordered something (timesWorked lives in Worker).

## How to test it in Remix

Deploy Warehouse first. Copy its deployed address. Deploy Worker, pasting that address into the constructor field. Call work(50) from Worker a couple of times. Check timesWorked on Worker, passing your own wallet address, it should show how many times you called work. Check totalStored on Warehouse, it should show the sum of every value ever passed to work, even though you never called Warehouse directly.

## Concepts practiced

Interfaces, calling a function on a separate, already-deployed contract. Constructor, storing a value (here, an address) once, at deployment time. msg.sender, identifying who is calling a function, safely. Mappings, an independent counter per wallet address. The accumulate pattern (x = x + something) applied across two separate contracts instead of just one.

---

Simple practice exercise built while learning Solidity fundamentals.
