// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.35;

contract Warehouse {

    uint256 public totalStored;

    function addAmount(uint256 amount) external {
        totalStored = totalStored + amount;
    }
}
