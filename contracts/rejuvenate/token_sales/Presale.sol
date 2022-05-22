// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../tokens/Rejuvenate.sol";

/// @title Presale
/// @author Rejuvenate Finance
/// @notice this contracts is the contract for the second Presale Phase with a fixed price (no limits / whale prevention)
/// @dev provides functionality to buy tokens for a specific amount of another ERC20 token | forSaleCurrency needs to be IRejuvenate -> presale end when address no longer whitelisted
contract Presale is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  // presale parameters
  address public constant paymentCurrency =
    0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  address public constant forSaleCurrency =
    0x2B60Bd0D80495DD27CE3F8610B4980E94056b30c;

  // wallets
  address internal constant _dev = 0xa9ae2738A7915B3512aACcD5Ff9e6CA5d09a1bfF;
  address internal constant _teamFirst =
    0x495eA0834daBC7B20045804690d46960DC0bD83c;
  address internal constant _teamSecond =
    0x4775357848EBbf4a1395A6684D45D0f206Aa4F2F;
  address internal constant _treasury =
    0xFb08de74D3DC381d2130e8885BdaD4e558b24145;

  // token iformation
  uint256 public tokenCap;
  uint256 public tokensSold;

  /// @dev gets emitted when someone bought from presale
  event Buy(address sender_, uint256 paid_, uint256 received_);

  constructor(uint256 tokensSold_, uint256 tokenCap_) {
    tokenCap = tokenCap_;
    tokensSold = tokensSold_;
  }

  /// @notice Allows people to buy @param amount_ of paymentCurrency worth of forSaleCurrency
  /// @dev Transfering paymentTokens form user to contract and minting the correct amount of forSaleTokens back
  /// @param amount_ amount of paymentCurrency to use
  function buy(uint256 amount_) external nonReentrant {
    require(tokensSold < tokenCap, "!empty");
    //! require 18 decimals
    uint256 buyAmount = amount_.div(4).mul(5); // 80% -> 0.8$
    tokensSold.add(buyAmount);
    // fixed rate of 4% goes to other teammember
    IERC20(paymentCurrency).safeTransferFrom(
      msg.sender,
      _teamFirst,
      amount_.div(25)
    );
    // fixed rate of 4% goes to other teammember
    IERC20(paymentCurrency).safeTransferFrom(
      msg.sender,
      _teamSecond,
      amount_.div(25)
    );
    // fixed rate of 12% goes to dev
    IERC20(paymentCurrency).safeTransferFrom(
      msg.sender,
      _dev,
      amount_.div(25).mul(3)
    );
    // treasury
    IERC20(paymentCurrency).safeTransferFrom(
      msg.sender,
      _treasury,
      amount_.div(5).mul(4)
    );
    IRejuvenate(forSaleCurrency).mint(msg.sender, buyAmount);
    emit Buy(msg.sender, amount_, buyAmount);
  }

  /// @notice Gives the remaning amount of tokens up for presale
  /// @dev Subsctract sold tokens from available tokensß
  /// @return uint256 amount of token in WEI
  function remaining() external view returns (uint256) {
    return tokenCap.sub(tokensSold);
  }

  /// @notice Allows the owmer to withdraw stuck tokens
  /// @dev Withdraws whole balance of specified tokens
  /// @param token Address of Token to withdraw
  function inCaseTokensGetStuck(address token) external onlyOwner {
    uint256 amount = IERC20(token).balanceOf(address(this));
    IERC20(token).transfer(msg.sender, amount);
  }
}
