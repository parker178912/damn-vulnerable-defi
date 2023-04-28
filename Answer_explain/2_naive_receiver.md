## Challenge #2 - Naive receiver
There’s a tokenized vault with a million DVT tokens deposited. It’s offering flash loans for free, until the grace period ends.

To pass the challenge, make the vault stop offering flash loans.

You start with 10 DVT tokens in balance.

---

The way we attack this contract is by doing flash loan 10 times in once so that we can drain all of the token from pool.