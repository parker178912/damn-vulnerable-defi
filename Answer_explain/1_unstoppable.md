First of all, check the origin test script:

```javascript
const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Unstoppable', function () {
    let deployer, player, someUser;
    let token, vault, receiverContract;

    const TOKENS_IN_VAULT = 1000000n * 10n ** 18n;
    const INITIAL_PLAYER_TOKEN_BALANCE = 10n * 10n ** 18n;

    before(async function () {
        // Get three person in this test case.
        [deployer, player, someUser] = await ethers.getSigners();

        // deploy token contract and unstoppable contract.
        token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();
        vault = await (await ethers.getContractFactory('UnstoppableVault', deployer)).deploy(
            token.address,    // token address
            deployer.address, // owner address
            deployer.address  // fee recipient
        );
        
        // check if the token address is equal to the vault asset address.
        expect(await vault.asset()).to.eq(token.address);

        // approve token to the contract and deposit token to it.
        await token.approve(vault.address, TOKENS_IN_VAULT);
        await vault.deposit(TOKENS_IN_VAULT, deployer.address);

        // check all variables.
        expect(await token.balanceOf(vault.address)).to.eq(TOKENS_IN_VAULT);
        expect(await vault.totalAssets()).to.eq(TOKENS_IN_VAULT);
        expect(await vault.totalSupply()).to.eq(TOKENS_IN_VAULT);
        expect(await vault.maxFlashLoan(token.address)).to.eq(TOKENS_IN_VAULT);
        expect(await vault.flashFee(token.address, TOKENS_IN_VAULT - 1n)).to.eq(0);
        expect(
            await vault.flashFee(token.address, TOKENS_IN_VAULT)
        ).to.eq(50000n * 10n ** 18n);

        // set initial balance of player.
        await token.transfer(player.address, INITIAL_PLAYER_TOKEN_BALANCE);
        expect(await token.balanceOf(player.address)).to.eq(INITIAL_PLAYER_TOKEN_BALANCE);

        // deploy the player attack contract.
        receiverContract = await (await ethers.getContractFactory('ReceiverUnstoppable', someUser)).deploy(
            vault.address
        );

        // execute the flash loan.
        await receiverContract.executeFlashLoan(100n * 10n ** 18n);
    });

    it('Execution', async function () {
        /** CODE YOUR SOLUTION HERE */
    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // It is no longer possible to execute flash loans
        await expect(
            receiverContract.executeFlashLoan(100n * 10n ** 18n)
        ).to.be.reverted;
    });
});
