// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Banco {

    mapping(address => uint256) public saldos;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function depositar(uint256 cantidad) public {
        saldos[msg.sender] = saldos[msg.sender] + cantidad;
    }

    function retirar(uint256 cantidad) public {
        require(saldos[msg.sender] >= cantidad, "Saldo insuficiente");
        saldos[msg.sender] = saldos[msg.sender] - cantidad;
    }

    function nivelCliente() public view returns (string memory) {
        if (saldos[msg.sender] < 100) {
            return "Bronce";
        } else if (saldos[msg.sender] <= 999) {
            return "Plata";
        } else {
            return "Oro";
        }
    }

    function simularInteres(uint256 anios) public view returns (uint256) {
        uint256 saldoFinal = saldos[msg.sender];

        for (uint256 i = 0; i < anios; i++) {
            saldoFinal = saldoFinal + (saldoFinal * 5 / 100);
        }

        return saldoFinal;
    }

    function resetearSaldo(address wallet) public {
        require(msg.sender == owner, "Solo el owner puede hacer esto");
        saldos[wallet] = 0;
    }
}
