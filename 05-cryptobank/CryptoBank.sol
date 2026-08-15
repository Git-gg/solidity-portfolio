// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

// CryptoBank - a simple learning-project bank contract.
//
// Specification:
// - Multi-user: each address has its own independent balance.
// - Users can only deposit and withdraw native ETH (no other tokens).
// - Users can only withdraw ETH they have previously deposited themselves.
// - Each user has a maximum balance cap (maxBalance), settable by the admin.
// - Each withdrawal is capped per transaction (maxLimit), settable by the admin.
// - The admin can pause/unpause the whole contract (circuit breaker).
contract CryptoBank {

    // ---------- State variables ----------

    uint256 public maxBalance;
    uint256 public maxLimit;
    bool public state;
    address public admin;
    mapping(address => uint256) public userBalance;

    // ---------- Events ----------

    event etherDeposit(address user_, uint256 etheramount_);
    event etherWithdraw(address user_, uint256 etheramount_);

    // ---------- Modifiers ----------

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not Allowed");
        _;
    }

    // ---------- Constructor ----------

    constructor(uint256 maxBalance_, uint256 maxLimit_, address admin_) {
        maxBalance = maxBalance_;
        maxLimit = maxLimit_;
        admin = admin_;
    }

    // ---------- Functions ----------

    // 1. Deposit
    function depositEther() external payable {
        require(!state, "Contract is paused");
        require(userBalance[msg.sender] + msg.value <= maxBalance, "MaxBalance reached");
        userBalance[msg.sender] += msg.value;
        emit etherDeposit(msg.sender, msg.value);
    }

    // 2. Withdraw
    function withdrawEther(uint256 amount_) external {
        require(!state, "Contract is paused");
        require(amount_ <= userBalance[msg.sender], "Not enough ether");
        require(amount_ <= maxLimit, "Max Limit");

        // Effects: update internal accounting BEFORE the external call
        // CEI pattern: 1. Checks 2. Effects 3. Interactions
        userBalance[msg.sender] -= amount_;

        // Interactions: send the ether
        (bool succes,) = msg.sender.call{value: amount_}("");
        require(succes, "Transfer failed");

        emit etherWithdraw(msg.sender, amount_);
    }

    // 3. Admin functions: modify maxBalance, maxLimit, pause state
    function modifyMaxBalance(uint256 newMaxBalance_) external onlyAdmin() {
        maxBalance = newMaxBalance_;
    }

    function modifyMaxLimit(uint256 newMaxLimit_) external onlyAdmin() {
        maxLimit = newMaxLimit_;
    }

    function changeState() external onlyAdmin() {
        state = !state;
    }
}
