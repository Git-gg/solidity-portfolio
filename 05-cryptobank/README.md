## CryptoBank (Solidity Learning Project)

A simple bank-style smart contract built while learning Solidity fundamentals: security patterns, access control, and a circuit breaker. This README documents the specification, explains every line of the contract, and includes a security analysis of what is protected against and what remains a design trade-off worth knowing.

## Specification

Multi-user: every address has its own independent balance, tracked internally. Users can only deposit and withdraw native ETH, no other tokens are involved. A user can only withdraw ETH they have previously deposited themselves, never anyone else's. Each user has a maximum balance cap (maxBalance), configurable by the admin. Each withdrawal is capped per transaction (maxLimit), also configurable by the admin. The admin can pause and unpause the entire contract as an emergency circuit breaker.

## Full contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

contract CryptoBank {

    uint256 public maxBalance;
    uint256 public maxLimit;
    bool public state;
    address public admin;
    mapping(address => uint256) public userBalance;

    event etherDeposit(address user_, uint256 etheramount_);
    event etherWithdraw(address user_, uint256 etheramount_);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not Allowed");
        _;
    }

    constructor(uint256 maxBalance_, uint256 maxLimit_, address admin_) {
        maxBalance = maxBalance_;
        maxLimit = maxLimit_;
        admin = admin_;
    }

    function depositEther() external payable {
        require(!state, "Contract is paused");
        require(userBalance[msg.sender] + msg.value <= maxBalance, "MaxBalance reached");
        userBalance[msg.sender] += msg.value;
        emit etherDeposit(msg.sender, msg.value);
    }

    function withdrawEther(uint256 amount_) external {
        require(!state, "Contract is paused");
        require(amount_ <= userBalance[msg.sender], "Not enough ether");
        require(amount_ <= maxLimit, "Max Limit");

        userBalance[msg.sender] -= amount_;

        (bool succes,) = msg.sender.call{value: amount_}("");
        require(succes, "Transfer failed");

        emit etherWithdraw(msg.sender, amount_);
    }

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
```

## Line-by-line explanation

### State variables

`uint256 public maxBalance;` the maximum amount of ETH a single user is allowed to hold in this contract at once.
`uint256 public maxLimit;` the maximum amount of ETH that can be withdrawn in a single transaction.
`bool public state;` the circuit breaker flag. true means the contract is paused, false means it is active. Defaults to false.
`address public admin;` the address with permission to change the limits and to pause/unpause the contract.
`mapping(address => uint256) public userBalance;` the internal ledger. For every address, stores how much ETH that address has deposited and not yet withdrawn.

### Events

`event etherDeposit(address user_, uint256 etheramount_);` and `event etherWithdraw(address user_, uint256 etheramount_);` declare two log entries external applications (a frontend, an indexer) can listen to, without needing to poll the contract's storage. They are emitted, not called, and they do not cost as much gas as writing to storage.

### Modifier

```solidity
modifier onlyAdmin() {
    require(msg.sender == admin, "Not Allowed");
    _;
}
```
A reusable access-control check. `require(msg.sender == admin, ...)` blocks the call if the caller is not the admin. `_;` is a placeholder that means "insert the rest of the function's code here". Any function declared with `onlyAdmin()` in its header runs this check first, then continues into its own body.

### Constructor

```solidity
constructor(uint256 maxBalance_, uint256 maxLimit_, address admin_) {
    maxBalance = maxBalance_;
    maxLimit = maxLimit_;
    admin = admin_;
}
```
Runs exactly once, automatically, at deployment time. It stores the initial cap per user, the initial withdrawal limit, and the admin address. `state` is not set here, so it keeps its default bool value, false: the contract starts unpaused.

### depositEther

```solidity
function depositEther() external payable {
    require(!state, "Contract is paused");
    require(userBalance[msg.sender] + msg.value <= maxBalance, "MaxBalance reached");
    userBalance[msg.sender] += msg.value;
    emit etherDeposit(msg.sender, msg.value);
}
```
`external payable` means the function is only callable from outside the contract and can receive ETH attached to the call. `require(!state, ...)` blocks execution while paused. The second require checks that this user's balance after the deposit would not exceed maxBalance, note it adds the incoming msg.value to the current balance before comparing, not just the new amount alone. `userBalance[msg.sender] += msg.value;` credits the caller with the ETH actually received, using msg.value rather than any user-supplied number. `emit etherDeposit(...)` logs who deposited and how much.

### withdrawEther

```solidity
function withdrawEther(uint256 amount_) external {
    require(!state, "Contract is paused");
    require(amount_ <= userBalance[msg.sender], "Not enough ether");
    require(amount_ <= maxLimit, "Max Limit");

    userBalance[msg.sender] -= amount_;

    (bool succes,) = msg.sender.call{value: amount_}("");
    require(succes, "Transfer failed");

    emit etherWithdraw(msg.sender, amount_);
}
```
Three checks in sequence: the contract must not be paused, the caller must have enough balance, and the amount must not exceed the per-transaction limit. `userBalance[msg.sender] -= amount_;` deducts the balance BEFORE any ETH leaves the contract, this is the Effects step of the Checks-Effects-Interactions pattern. `(bool succes,) = msg.sender.call{value: amount_}("");` sends the ETH using a low-level call, which forwards all remaining gas rather than a fixed stipend. `require(succes, ...)` reverts the whole transaction, including the earlier balance deduction, if the transfer failed. Finally the withdrawal is logged.

### Admin functions

```solidity
function modifyMaxBalance(uint256 newMaxBalance_) external onlyAdmin() {
    maxBalance = newMaxBalance_;
}

function modifyMaxLimit(uint256 newMaxLimit_) external onlyAdmin() {
    maxLimit = newMaxLimit_;
}
```
Both simply overwrite the corresponding state variable with a new value, and both are gated by onlyAdmin, so only the stored admin address can call them.

```solidity
function changeState() external onlyAdmin() {
    state = !state;
}
```
Takes no parameters. `!state` means "the opposite of the current value of state". `state = !state;` flips true to false or false to true, toggling the circuit breaker with a single call, restricted to the admin.

## Security analysis

### Protections already implemented

Reentrancy (Checks-Effects-Interactions). withdrawEther updates userBalance before making the external call. If msg.sender is a malicious contract that tries to re-enter withdrawEther from its receive function, the balance has already been decremented, so the second call's require(amount_ <= userBalance[msg.sender]) fails. This is the exact pattern that prevented the 2016 DAO-style exploit.

Access control. Admin-only actions (changing limits, pausing) are gated behind the onlyAdmin modifier, backed by a plain require(msg.sender == admin). msg.sender is used for this check, not tx.origin, which avoids the phishing-style vulnerability where a malicious contract could relay a transaction through the real admin's wallet.

Accounting based on msg.value, not user input. depositEther credits the caller using msg.value, the ETH actually attached to the call, rather than trusting a caller-supplied amount parameter. An earlier draft of this contract used a parameter instead of msg.value, which allowed inflating a balance with no real ETH backing it, and a later draft overwrote the balance instead of accumulating it, silently losing previously deposited funds. Both are fixed in this version.

Explicit transfer-success check. The low-level call used to send ETH out has its boolean result checked with require(succes, ...), so a failed transfer reverts the whole withdrawal instead of silently leaving the internal ledger out of sync with the contract's real ETH balance.

Emergency pause. The state flag, checked at the top of both depositEther and withdrawEther, lets the admin freeze all fund movement if a bug or attack is discovered elsewhere in the contract or its environment.

### Remaining risks and design trade-offs

Centralization / single point of failure. admin is one address with no multisig and no timelock. A compromised admin private key would let an attacker set maxLimit or maxBalance to disruptive values, or pause the contract indefinitely, denying service to all users. Admin cannot directly steal user funds through these functions, but can grief the system.

No admin transfer or recovery mechanism. There is no function to change admin after deployment, and the constructor does not check admin_ against the zero address. If admin_ is ever passed as address(0), or if the admin's private key is lost, every onlyAdmin function becomes permanently uncallable. If the contract happens to be paused at that point, user funds would be frozen with no way to unpause.

Admin actions are not logged. modifyMaxBalance, modifyMaxLimit, and changeState do not emit events. Users and monitoring tools have no on-chain way to be notified when the admin changes these parameters, reducing transparency compared to the deposit and withdraw events that do exist.

Forced ETH is not recoverable through normal accounting. The contract has no receive or fallback function, so a plain ETH transfer to its address would revert. However, ETH can still be forced into any contract via selfdestruct from another contract. Any ETH forced in this way increases the contract's real balance without crediting any entry in userBalance, effectively becoming stuck and unclaimable through withdrawEther.

Gas cost of require strings. Every require in this contract uses a string message, which is more expensive to deploy and to trigger than a custom error (introduced in Solidity 0.8.4). Functionally equivalent, but a gas-optimized version of this contract would replace these with custom errors.

maxLimit is not validated against maxBalance. The admin can set maxLimit higher than maxBalance, which does not break anything but makes the per-transaction limit meaningless in practice, since a user's balance can never exceed maxBalance in the first place.

## How to test in Remix

Deploy the contract with an initial maxBalance, maxLimit, and admin address. Call depositEther with a Value amount set in Remix, from a non-admin account, and confirm userBalance for that account increases correctly. Try depositing past maxBalance and confirm it reverts. Call withdrawEther for an amount within balance and within maxLimit, and confirm it succeeds and the ETH is received. Try withdrawing more than maxLimit in one call and confirm it reverts. As the admin account, call changeState, then try depositEther or withdrawEther from any account and confirm both revert with "Contract is paused". Call changeState again and confirm normal operation resumes. Try calling modifyMaxBalance, modifyMaxLimit, or changeState from a non-admin account and confirm all three revert with "Not Allowed".

## Concepts practiced

State variables and mappings for per-user accounting. payable functions and msg.value for real ETH deposits. The Checks-Effects-Interactions pattern to prevent reentrancy. Custom modifiers for reusable access control. A circuit breaker (pausable) pattern for emergency response. Events for off-chain visibility into deposits and withdrawals. Identifying and fixing two real accounting bugs (trusting a user-supplied amount instead of msg.value, and overwriting balances instead of accumulating them) during development.
