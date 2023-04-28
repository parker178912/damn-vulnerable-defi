## Challenge #5 - The Rewarder
There’s a pool offering rewards in tokens every 5 days for those who deposit their DVT tokens into it.

Alice, Bob, Charlie and David have already deposited some DVT tokens, and have won their rewards!

You don’t have any DVT tokens. But in the upcoming round, you must claim most rewards for yourself.

By the way, rumours say a new pool has just launched. Isn’t it offering flash loans of DVT tokens?

---

The way we attack this contract is by doing flash loan to get DVT tokens and deposit into contract, at the same time, we adjust the time to make the time be after the 5 days, so we can get all the reward now.