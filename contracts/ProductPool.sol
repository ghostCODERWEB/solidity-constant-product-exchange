// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Constant-product token exchange
/// @notice Two-asset ERC20 AMM with LP shares, proportional liquidity, fee-retaining swaps and slippage bounds.
/// @dev Reference implementation; independent audit required before production.

contract ProductPool is ERC20, SuiteBase {
    using SafeERC20 for IERC20;
    IERC20 public immutable token0;
    IERC20 public immutable token1;
    uint256 public reserve0;
    uint256 public reserve1;
    uint16 public immutable feeBps;
    uint256 public constant MINIMUM_LIQUIDITY = 1000;
    event LiquidityAdded(
        address indexed account,
        uint256 amount0,
        uint256 amount1,
        uint256 shares
    );
    event LiquidityRemoved(
        address indexed account,
        uint256 amount0,
        uint256 amount1,
        uint256 shares
    );
    event Swapped(
        address indexed account,
        address indexed input,
        uint256 amountIn,
        uint256 amountOut
    );
    constructor(
        address asset0,
        address asset1,
        uint16 fee,
        address admin
    ) ERC20("Product Pool LP", "PPLP") SuiteBase(admin) {
        require(
            asset0.code.length > 0 &&
                asset1.code.length > 0 &&
                asset0 != asset1 &&
                fee < 1000,
            "config"
        );
        token0 = IERC20(asset0);
        token1 = IERC20(asset1);
        feeBps = fee;
    }
    function _sync() internal {
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
    }
    function addLiquidity(
        uint256 desired0,
        uint256 desired1,
        uint256 minShares
    ) external nonReentrant whenNotPaused returns (uint256 shares) {
        uint256 a = desired0;
        uint256 b = desired1;
        uint256 supply = totalSupply();
        require(a > 0 && b > 0, "amount");
        if (supply == 0) {
            uint256 root = Math.sqrt(a * b);
            require(root > MINIMUM_LIQUIDITY, "minimum");
            shares = root - MINIMUM_LIQUIDITY;
            _mint(address(0xdead), MINIMUM_LIQUIDITY);
        } else {
            uint256 optimal1 = Math.mulDiv(a, reserve1, reserve0);
            if (optimal1 <= b) b = optimal1;
            else a = Math.mulDiv(b, reserve0, reserve1);
            shares = Math.min(
                Math.mulDiv(a, supply, reserve0),
                Math.mulDiv(b, supply, reserve1)
            );
        }
        require(shares > 0 && shares >= minShares, "slippage");
        AssetFlow.pullExact(token0, msg.sender, a);
        AssetFlow.pullExact(token1, msg.sender, b);
        _mint(msg.sender, shares);
        _sync();
        emit LiquidityAdded(msg.sender, a, b, shares);
    }
    function removeLiquidity(
        uint256 shares,
        uint256 min0,
        uint256 min1
    ) external nonReentrant returns (uint256 a, uint256 b) {
        uint256 supply = totalSupply();
        a = Math.mulDiv(shares, reserve0, supply);
        b = Math.mulDiv(shares, reserve1, supply);
        require(
            shares > 0 && a > 0 && b > 0 && a >= min0 && b >= min1,
            "slippage"
        );
        _burn(msg.sender, shares);
        token0.safeTransfer(msg.sender, a);
        token1.safeTransfer(msg.sender, b);
        _sync();
        emit LiquidityRemoved(msg.sender, a, b, shares);
    }
    function quote(
        address input,
        uint256 amount
    ) public view returns (uint256) {
        require(
            amount > 0 &&
                (input == address(token0) || input == address(token1)),
            "input"
        );
        uint256 ri = input == address(token0) ? reserve0 : reserve1;
        uint256 ro = input == address(token0) ? reserve1 : reserve0;
        require(ri > 0 && ro > 0, "liquidity");
        uint256 effective = amount * (10000 - feeBps);
        return Math.mulDiv(effective, ro, ri * 10000 + effective);
    }
    function swap(
        address input,
        uint256 amount,
        uint256 minOutput
    ) external nonReentrant whenNotPaused returns (uint256 output) {
        output = quote(input, amount);
        require(output > 0 && output >= minOutput, "slippage");
        IERC20 incoming = input == address(token0) ? token0 : token1;
        IERC20 outgoing = input == address(token0) ? token1 : token0;
        AssetFlow.pullExact(incoming, msg.sender, amount);
        outgoing.safeTransfer(msg.sender, output);
        _sync();
        emit Swapped(msg.sender, input, amount, output);
    }
}
