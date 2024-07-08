
# MakerDAO Endgame contest details

- Join [Sherlock Discord](https://discord.gg/MABEWyASkp)
- Submit findings using the issue page in your private contest repo (label issues as med or high)
- [Read for more details](https://docs.sherlock.xyz/audits/watsons)

# Q&A

### Q: On what chains are the smart contracts going to be deployed?
Ethereum
___

### Q: If you are integrating tokens, are you allowing only whitelisted tokens to work with the codebase or any complying with the standard? Are they assumed to have certain properties, e.g. be non-reentrant? Are there any types of [weird tokens](https://github.com/d-xo/weird-erc20) you want to integrate?
The token contracts used in each repository are known in advance and there is no use of arbitrary tokens in any of the contest modules:
* In the nst module, apart from the NST token itself only DAI is used (in the DaiNst converter).
* In the ngt module, apart from the NGT token itself, only MKR is used (in the MkrNgt converter).
* In the snst module, apart from the SNST token, only NST is used (as the deposit token).
* In the vote-delegate module only MKR and the existing Chief's IOU tokens are used.
* In endgame-toolkit the farm types to be used through different deployment phases are (using rewards/stake notation): NGT/NST, SDAO/NST, NGT/SDAO, NST/LSMKR and SDAO/LSMKR (the last two types are only for lockstake).
* In the lockstake module only MKR, NGT, NST and LSMKR are used (plus the two farms types mentioned above).

Issues stemming from potential different future implementations of NST and SNST (due to their upgradeability) are out of scope.

All the above means that there is no need to analyze potential use/integration of any other token code (which could potentially have weird behaviour) in any of the modules.
___

### Q: Are there any limitations on values set by admins (or other roles) in the codebase, including restrictions on array lengths?
No
___

### Q: Are there any limitations on values set by admins (or other roles) in protocols you integrate with, including restrictions on array lengths?
No
___

### Q: For permissioned functions, please list all checks and requirements that will be made before calling the function.
N/A
___

### Q: Is the codebase expected to comply with any EIPs? Can there be/are there any deviations from the specification?
Optionally Compliant
ERC20: NST, NGT and SNST tokens.
ERC4626: SNST
___

### Q: Are there any off-chain mechanisms or off-chain procedures for the protocol (keeper bots, arbitrage bots, etc.)?
Public Keeper Bots
Endgame Toolkit: VestedRewardsDistribution.distribute()
* No input data needed
Smart Burn Engine: vow.flap() -> Splitter.kick()
* No input data needed

Arbitrage Bots
LockStake Engine: LockstakeClipper.take()
* Input parameters are Auction id, collateral, and bid amounts. This information can be found in the event emitted by kick- Kick(id, top, tab, lot, usr, kpr, coin)
___

### Q: Are there any hardcoded values that you intend to change before (some) deployments?
None
___

### Q: If the codebase is to be deployed on an L2, what should be the behavior of the protocol in case of sequencer issues (if applicable)? Should Sherlock assume that the Sequencer won't misbehave, including going offline?
Not deployed to L2.
___

### Q: Should potential issues, like broken assumptions about function behavior, be reported if they could pose risks in future integrations, even if they might not be an issue in the context of the scope? If yes, can you elaborate on properties/invariants that should hold?
No
___

### Q: Please discuss any design choices you made.
Please refer to https://github.com/makerdao/sherlock-contest/blob/9a01337e8f82acdf699a5c1c54233636c640ca89/README.md, and the documentation present in the codebases. 
___

### Q: Please list any known issues and explicitly state the acceptable risks for each known issue.
Please refer to https://github.com/makerdao/sherlock-contest/blob/9a01337e8f82acdf699a5c1c54233636c640ca89/README.md, and the documentation present in the codebases for a list of known issues and general disclaimers for this contest. 
___

### Q: We will report issues where the core protocol functionality is inaccessible for at least 7 days. Would you like to override this value?
No
___

### Q: Please provide links to previous audits (if any).
https://github.com/makerdao/nst/tree/sherlock-contest/audit
https://github.com/makerdao/ngt/tree/sherlock-contest/audit
https://github.com/makerdao/sdai/tree/sherlock-contest/audit
https://github.com/makerdao/endgame-toolkit/tree/sherlock-contest/audits
https://github.com/makerdao/dss-flappers/tree/sherlock-contest/audit
https://github.com/makerdao/univ2-pool-migrator/tree/sherlock-contest/audit
https://github.com/makerdao/vote-delegate/tree/sherlock-contest/audit
https://github.com/makerdao/lockstake/tree/sherlock-contest/audit
___

### Q: Please list any relevant protocol resources.
Please find additional information about the codebases here: https://www.notion.so/jetstreamgg/Maker-Endgame-Launch-Sherlock-Audit-Contest-Scope-641baee4028548ccbb3783f2278c3215
___

### Q: Additional audit information.
Severity Definitions:
We are building on top of the current Sherlock severity definitions apart from changes explicitly mentioned (for example see about functionality breaking). However, we are giving guidance to the words that describe loss.

Sherlock's Medium definition:

Causes a loss of funds but requires certain external conditions or specific states, or a loss is highly constrained. The losses must exceed small, finite amount of funds, and any amount relevant based on the precision or significance of the loss.

"a loss is highly constrained". As a guideline for this contest, a highly constrained loss is a loss of up to 5% of the affected party (both protocol and user).

"The losses must exceed small, finite amount of funds". As a guideline for this contest, small, finite amount of funds are 0.5% of the affected party (both protocol and user).

With this clarification

Any loss smaller than 0.5% can never be Medium
Any loss between 0.5% and 5% loss can be Medium at most
Any issue larger than 5% can be Medium or High (depending on constraints)
If a single attack can cause a 0.01% loss but can be replayed indefinitely (assuming little to no costs), it will be perceived as a 100% loss. Note that in most modules governance can step in within hours (aka Mom contracts), or otherwise if needed plus the governance pause delay to halt the system. This should be taken into account when determining if replaying indefinitely is possible. For the contest we assume 2 hours from the point an exploit starts until a delay-bypass Mom contract executes and 50 hours for a fix that requires governance delay (including the delay).
For protocol losses, it must be demonstrated that the losses exceed the above percentage assuming protocol reserves of 100m+. For user losses, it must demonstrate those losses with the user's 10k+ of value locked/vulnerable as part of the attack.

In the lockstake case, the maximal locked MKR is assumed at $250m and the maximal line is assumed as 100m dai. A user in the lockstake case is a single urn.

For the SNST case, the maximal locked NST amount is assumed as 1B DAI.

Rules:
The protocol chooses to override at least the following from https://docs.sherlock.xyz/audits/judging/judging. Other changes may also be communicated through the competition website or elsewhere.

"Breaks core contract functionality, rendering the contract useless or leading to loss of funds." Breaking any kind of functionality is not a medium or high severity issue for this competition, only loss of funds.

"The protocol team can use the README (and only the README) to define language that indicates the codebase's restrictions and/or expected functionality." Any public material should be valid as known issues for this competition.

"Issues that break these statements, irrespective of whether the impact is low/unknown, will be assigned Medium severity." Even if an intended functionality is broken but there is no material loss of funds then it is not a medium or high issue for this competition.

"Example: The README states "Admin can only call XYZ function once" but the code allows the Admin to call XYZ function twice; this is a valid Medium" This shouldn't be a valid medium if there is no loss of funds.

"EIP Compliance: For issues related to EIP compliance, the protocol & codebase must show that there are important external integrations that would require strong compliance with the EIP's implemented in the code. The EIP must be in regular use or in the final state for EIP implementation issues to be considered valid" There is no commitment with regards to EIP compliance. On top of that, any loss of funds incurred in an integrating contract is out of scope.

"User input validation: User input validation to prevent user mistakes is not considered a valid issue. However, if a user input could result in a major protocol malfunction or significant loss of funds could be a valid high." Any user mistakes resulting in their own funds being lost is out of scope.

Please refer to https://github.com/makerdao/sherlock-contest/blob/9a01337e8f82acdf699a5c1c54233636c640ca89/README.md, and the documentation present in the codebases for a list of known issues and general disclaimers for this contest. 

Also see https://hackmd.io/@h3li0s/rk3x9uFw0
___



# Audit scope


[dss-flappers @ b2e2ed17554b887cee517daa8d3e0d2f841b4871](https://github.com/makerdao/dss-flappers/tree/b2e2ed17554b887cee517daa8d3e0d2f841b4871)
- [dss-flappers/deploy/FlapperDeploy.sol](dss-flappers/deploy/FlapperDeploy.sol)
- [dss-flappers/deploy/FlapperInit.sol](dss-flappers/deploy/FlapperInit.sol)
- [dss-flappers/deploy/SplitterInstance.sol](dss-flappers/deploy/SplitterInstance.sol)
- [dss-flappers/src/Babylonian.sol](dss-flappers/src/Babylonian.sol)
- [dss-flappers/src/FlapperUniV2.sol](dss-flappers/src/FlapperUniV2.sol)
- [dss-flappers/src/FlapperUniV2SwapOnly.sol](dss-flappers/src/FlapperUniV2SwapOnly.sol)
- [dss-flappers/src/OracleWrapper.sol](dss-flappers/src/OracleWrapper.sol)
- [dss-flappers/src/Splitter.sol](dss-flappers/src/Splitter.sol)
- [dss-flappers/src/SplitterMom.sol](dss-flappers/src/SplitterMom.sol)

[vote-delegate @ ae29376d2b8fdb7293c588584f62fe302914f575](https://github.com/makerdao/vote-delegate/tree/ae29376d2b8fdb7293c588584f62fe302914f575)
- [vote-delegate/src/VoteDelegate.sol](vote-delegate/src/VoteDelegate.sol)
- [vote-delegate/src/VoteDelegateFactory.sol](vote-delegate/src/VoteDelegateFactory.sol)

[lockstake @ ca5ef60eb4d2be83dc4275345bf0d5859c66a72e](https://github.com/makerdao/lockstake/tree/ca5ef60eb4d2be83dc4275345bf0d5859c66a72e)
- [lockstake/deploy/LockstakeDeploy.sol](lockstake/deploy/LockstakeDeploy.sol)
- [lockstake/deploy/LockstakeInit.sol](lockstake/deploy/LockstakeInit.sol)
- [lockstake/deploy/LockstakeInstance.sol](lockstake/deploy/LockstakeInstance.sol)
- [lockstake/src/LockstakeClipper.sol](lockstake/src/LockstakeClipper.sol)
- [lockstake/src/LockstakeEngine.sol](lockstake/src/LockstakeEngine.sol)
- [lockstake/src/LockstakeMkr.sol](lockstake/src/LockstakeMkr.sol)
- [lockstake/src/LockstakeUrn.sol](lockstake/src/LockstakeUrn.sol)
- [lockstake/src/Multicall.sol](lockstake/src/Multicall.sol)

[ngt @ 39d29dc99e927b93be5c8b1964cd3267497cc4a1](https://github.com/makerdao/ngt/tree/39d29dc99e927b93be5c8b1964cd3267497cc4a1)
- [ngt/deploy/NgtDeploy.sol](ngt/deploy/NgtDeploy.sol)
- [ngt/deploy/NgtInit.sol](ngt/deploy/NgtInit.sol)
- [ngt/deploy/NgtInstance.sol](ngt/deploy/NgtInstance.sol)
- [ngt/src/MkrNgt.sol](ngt/src/MkrNgt.sol)
- [ngt/src/Ngt.sol](ngt/src/Ngt.sol)

[endgame-toolkit @ 70b59deb7201758fcb7b81497a09c30b8aacda95](https://github.com/makerdao/endgame-toolkit/tree/70b59deb7201758fcb7b81497a09c30b8aacda95)
- [endgame-toolkit/script/dependencies/SDAODeploy.sol](endgame-toolkit/script/dependencies/SDAODeploy.sol)
- [endgame-toolkit/script/dependencies/StakingRewardsDeploy.sol](endgame-toolkit/script/dependencies/StakingRewardsDeploy.sol)
- [endgame-toolkit/script/dependencies/StakingRewardsInit.sol](endgame-toolkit/script/dependencies/StakingRewardsInit.sol)
- [endgame-toolkit/script/dependencies/SubProxyDeploy.sol](endgame-toolkit/script/dependencies/SubProxyDeploy.sol)
- [endgame-toolkit/script/dependencies/SubProxyInit.sol](endgame-toolkit/script/dependencies/SubProxyInit.sol)
- [endgame-toolkit/script/dependencies/VestInit.sol](endgame-toolkit/script/dependencies/VestInit.sol)
- [endgame-toolkit/script/dependencies/VestedRewardsDistributionDeploy.sol](endgame-toolkit/script/dependencies/VestedRewardsDistributionDeploy.sol)
- [endgame-toolkit/script/dependencies/VestedRewardsDistributionInit.sol](endgame-toolkit/script/dependencies/VestedRewardsDistributionInit.sol)
- [endgame-toolkit/script/dependencies/phase-0/FarmingInit.sol](endgame-toolkit/script/dependencies/phase-0/FarmingInit.sol)
- [endgame-toolkit/script/helpers/Reader.sol](endgame-toolkit/script/helpers/Reader.sol)
- [endgame-toolkit/script/phase-0/01-FarmingDeploy.s.sol](endgame-toolkit/script/phase-0/01-FarmingDeploy.s.sol)
- [endgame-toolkit/src/SDAO.sol](endgame-toolkit/src/SDAO.sol)
- [endgame-toolkit/src/SubProxy.sol](endgame-toolkit/src/SubProxy.sol)
- [endgame-toolkit/src/VestedRewardsDistribution.sol](endgame-toolkit/src/VestedRewardsDistribution.sol)
- [endgame-toolkit/src/interfaces/DssVestWithGemLike.sol](endgame-toolkit/src/interfaces/DssVestWithGemLike.sol)
- [endgame-toolkit/src/synthetix/StakingRewards.sol](endgame-toolkit/src/synthetix/StakingRewards.sol)
- [endgame-toolkit/src/synthetix/interfaces/IStakingRewards.sol](endgame-toolkit/src/synthetix/interfaces/IStakingRewards.sol)
- [endgame-toolkit/src/synthetix/utils/Owned.sol](endgame-toolkit/src/synthetix/utils/Owned.sol)
- [endgame-toolkit/src/synthetix/utils/Pausable.sol](endgame-toolkit/src/synthetix/utils/Pausable.sol)

[nst @ 0936cf96830ca1d44f10a1ebe39d4da209b97339](https://github.com/makerdao/nst/tree/0936cf96830ca1d44f10a1ebe39d4da209b97339)
- [nst/deploy/NstDeploy.sol](nst/deploy/NstDeploy.sol)
- [nst/deploy/NstInit.sol](nst/deploy/NstInit.sol)
- [nst/deploy/NstInstance.sol](nst/deploy/NstInstance.sol)
- [nst/src/DaiNst.sol](nst/src/DaiNst.sol)
- [nst/src/Nst.sol](nst/src/Nst.sol)
- [nst/src/NstJoin.sol](nst/src/NstJoin.sol)

[sdai @ c07bfe164d036acbc1e0b50560fdd18378fd9dd3](https://github.com/makerdao/sdai/tree/c07bfe164d036acbc1e0b50560fdd18378fd9dd3)
- [sdai/deploy/SNstDeploy.sol](sdai/deploy/SNstDeploy.sol)
- [sdai/deploy/SNstInit.sol](sdai/deploy/SNstInit.sol)
- [sdai/deploy/SNstInstance.sol](sdai/deploy/SNstInstance.sol)
- [sdai/src/ISNst.sol](sdai/src/ISNst.sol)
- [sdai/src/SNst.sol](sdai/src/SNst.sol)

[univ2-pool-migrator @ 2adb62b7c67705977a0f8fb89c228779f52de12e](https://github.com/makerdao/univ2-pool-migrator/tree/2adb62b7c67705977a0f8fb89c228779f52de12e)
- [univ2-pool-migrator/deploy/UniV2PoolMigratorInit.sol](univ2-pool-migrator/deploy/UniV2PoolMigratorInit.sol)




