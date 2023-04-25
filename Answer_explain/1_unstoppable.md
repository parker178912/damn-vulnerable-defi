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
```

So in the test script we can see that it start flash loan, so we have to check the function of flash loan.

```javascript
function flashLoan(
    IERC3156FlashBorrower receiver,
    address _token,
    uint256 amount,
    bytes calldata data
) external returns (bool) {
    // don't loan anything.
    if (amount == 0) revert InvalidAmount(0);

    // don't loan specific token
    if (address(asset) != _token) revert UnsupportedCurrency();

    // record the balance before loan start.
    uint256 balanceBefore = totalAssets();
    if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance();
    uint256 fee = flashFee(_token, amount);

    // transfer tokens out + execute callback on receiver
    ERC20(_token).safeTransfer(address(receiver), amount);

    // callback must return magic value, otherwise assume it failed
    if (receiver.onFlashLoan(msg.sender, address(asset), amount, fee, data) != keccak256("IERC3156FlashBorrower.onFlashLoan"))
        revert CallbackFailed();

    // pull amount + fee from receiver, then pay the fee to the recipient
    ERC20(_token).safeTransferFrom(address(receiver), address(this), amount + fee);
    ERC20(_token).safeTransfer(feeRecipient, fee);
    return true;
}
```

