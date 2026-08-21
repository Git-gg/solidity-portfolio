// SPDX-License-Identifier: MIT
pragma solidity 0.8.35;

// Example comparing two ways to write access control in Solidity:
// 1) if (condition) revert();
// 2) require(condition, "message");
// Both block the function if the caller is not the admin.
contract RequireTest {

    address public admin;

    constructor(address admin_) {
        admin = admin_;
    }

    // Access control using if + revert (no error message)
    function checkAdmin() public view {
        if (msg.sender != admin) revert();
    }

    // Access control using require (includes a readable error message)
    function checkAdminRequire() public view {
        require(msg.sender == admin, "Msg.sender is not admin");
    }
}
