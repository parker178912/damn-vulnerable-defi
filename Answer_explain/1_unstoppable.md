## Challenge #1 - Unstoppable
There’s a tokenized vault with a million DVT tokens deposited. It’s offering flash loans for free, until the grace period ends.

To pass the challenge, make the vault stop offering flash loans.

You start with 10 DVT tokens in balance.

---

In the flash loan function we can see that only the checks of the balance before loan start can be intervene by the player.

So what we can do is to transfer tokens from player to the attack contract, so that the check by 
```if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance();``` 
will be revert.