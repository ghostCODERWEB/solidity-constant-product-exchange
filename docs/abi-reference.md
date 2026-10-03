# ABI reference

Generated from the successfully compiled primary contract. Includes inherited methods. Authorization and economic semantics are documented in the source.

| Signature | Type | Mutability | Returns |
|---|---|---|---|
| `constructor(address asset0,address asset1,uint16 fee,address admin)` | constructor | nonpayable |  |
| `ERC20InsufficientAllowance(address spender,uint256 allowance,uint256 needed)` | error |  |  |
| `ERC20InsufficientBalance(address sender,uint256 balance,uint256 needed)` | error |  |  |
| `ERC20InvalidApprover(address approver)` | error |  |  |
| `ERC20InvalidReceiver(address receiver)` | error |  |  |
| `ERC20InvalidSender(address sender)` | error |  |  |
| `ERC20InvalidSpender(address spender)` | error |  |  |
| `EnforcedPause()` | error |  |  |
| `ExpectedPause()` | error |  |  |
| `OwnableInvalidOwner(address owner)` | error |  |  |
| `OwnableUnauthorizedAccount(address account)` | error |  |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `SafeERC20FailedOperation(address token)` | error |  |  |
| `Approval(address owner,address spender,uint256 value)` | event |  |  |
| `LiquidityAdded(address account,uint256 amount0,uint256 amount1,uint256 shares)` | event |  |  |
| `LiquidityRemoved(address account,uint256 amount0,uint256 amount1,uint256 shares)` | event |  |  |
| `OwnershipTransferStarted(address previousOwner,address newOwner)` | event |  |  |
| `OwnershipTransferred(address previousOwner,address newOwner)` | event |  |  |
| `Paused(address account)` | event |  |  |
| `Swapped(address account,address input,uint256 amountIn,uint256 amountOut)` | event |  |  |
| `Transfer(address from,address to,uint256 value)` | event |  |  |
| `Unpaused(address account)` | event |  |  |
| `MINIMUM_LIQUIDITY()` | function | view | uint256  |
| `acceptOwnership()` | function | nonpayable |  |
| `addLiquidity(uint256 desired0,uint256 desired1,uint256 minShares)` | function | nonpayable | uint256 shares |
| `allowance(address owner,address spender)` | function | view | uint256  |
| `approve(address spender,uint256 value)` | function | nonpayable | bool  |
| `balanceOf(address account)` | function | view | uint256  |
| `decimals()` | function | view | uint8  |
| `feeBps()` | function | view | uint16  |
| `name()` | function | view | string  |
| `owner()` | function | view | address  |
| `paused()` | function | view | bool  |
| `pendingOwner()` | function | view | address  |
| `quote(address input,uint256 amount)` | function | view | uint256  |
| `removeLiquidity(uint256 shares,uint256 min0,uint256 min1)` | function | nonpayable | uint256 a, uint256 b |
| `renounceOwnership()` | function | nonpayable |  |
| `reserve0()` | function | view | uint256  |
| `reserve1()` | function | view | uint256  |
| `setPaused(bool value)` | function | nonpayable |  |
| `swap(address input,uint256 amount,uint256 minOutput)` | function | nonpayable | uint256 output |
| `symbol()` | function | view | string  |
| `token0()` | function | view | address  |
| `token1()` | function | view | address  |
| `totalSupply()` | function | view | uint256  |
| `transfer(address to,uint256 value)` | function | nonpayable | bool  |
| `transferFrom(address from,address to,uint256 value)` | function | nonpayable | bool  |
| `transferOwnership(address newOwner)` | function | nonpayable |  |
