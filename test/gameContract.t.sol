//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/gameContract.sol";

contract gameContractTest is Test {

    gameContract game;
    address attacker;
    address[] users;

    function setUp() public {
        game = new gameContract();
        vm.label (address(game), "Game Contract!!!");

        attacker = address(10);
        vm.label(attacker, "Attacker");

        for(uint i = 1; i < 9; i++){
            users[i] = address(i);
        }
    }
}