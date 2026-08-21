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
