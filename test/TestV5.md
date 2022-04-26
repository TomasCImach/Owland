# 0x37A7Db875900FF22125081CC874049F1F6416202

Single and Batch Stake - OK (no failures)
Try to unstake before time lock - SUCCESS

# 0xe761F253f8952775213e0b92B669428Cf2ac8408

Deployed with Cycle Length = 60 seconds.

stakeLand - gas 74k , USD 14 @60 Gwei
batchStakeLands x 2 - gas 124k (62k/u)
claimSingleReward - gas 95k
claimRewards x 2 - gas 95k (47k/u)

*** implemented FIX override _beforeTokenTransfer require !staked ***

*** unstakeLand FAIL - FIX moved down staked[ID] = true (after claim rewards) ***

*** batchUnstakeLands FAIL - FIX moved up rewardClaim ***

# 0x0E6044f0d3B2289AAbc63068c3570A7FE8D10786

batchStakeLands x 3 - 173k 33USD @60 Gwei (58k/u)
unstakeLand - 70k
batchUnstakeLAnds x 2 - 106k (53k/u)