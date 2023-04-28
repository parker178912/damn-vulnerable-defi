## Challenge #4 - Side Entrance
A surprisingly simple pool allows anyone to deposit ETH, and withdraw it at any point in time.

It has 1000 ETH in balance already, and is offering free flash loans using the deposited ETH to promote their system.

Starting with 1 ETH in balance, pass the challenge by taking all ETH from the pool.

---

The way we are attacking this contract is by using the "deposit" function to put the ETH we borrowed back into the contract. 

This allows us to use the "withdraw" function to take out the money even when it passes the flash loan check.
