## Challenge #3 - Truster
More and more lending pools are offering flash loans. In this case, a new pool has launched that is offering flash loans of DVT tokens for free.

The pool holds 1 million DVT tokens. You have nothing.

To pass this challenge, take all tokens out of the pool. If possible, in a single transaction.

---

In the flash loan function we can see that there can be a calldata can send into the flash loan function.

So how we attack this contract is to let the flash loan contract help us approve the token in calldata, and then we can transfer all of the token from pool.