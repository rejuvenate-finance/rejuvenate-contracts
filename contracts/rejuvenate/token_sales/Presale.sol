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
  address public paymentCurrency;
  address public forSaleCurrency;
  uint256 public pricePerToken;

  // wallets
  address internal _dev;
  address internal _treasury;

  // token iformation
  uint256 public tokenCap;
  uint256 public tokenSold;

  /// @dev gets emitted when someone bought from presale
  event Buy(address sender_, uint256 paid_, uint256 received_);

  constructor(
    address forSaleCurrency_,
    address paymentCurrency_,
    uint256 pricePreToken_,
    address treasury_,
    address dev_,
    uint256 tokenCap_
  ) {
    _treasury = treasury_;
    _dev = dev_;

    pricePerToken = pricePreToken_;
    forSaleCurrency = forSaleCurrency_;
    paymentCurrency = paymentCurrency_;

    tokenCap = tokenCap_;
    tokenSold = 0;
  }

  /// @notice Allows people to buy @param amount_ of paymentCurrency worth of forSaleCurrency
  /// @dev Transfering paymentTokens form user to contract and minting the correct amount of forSaleTokens back
  /// @param amount_ amount of paymentCurrency to use
  function buy(uint256 amount_) external nonReentrant {
    require(tokenSold < tokenCap, "!empty");
    tokenSold = tokenSold.add(amount_);
    //! require 18 decimals
    uint256 buyAmount = amount_.mul(1e18).div(pricePerToken);
    IERC20(paymentCurrency).safeTransferFrom(
      msg.sender,
      address(this),
      amount_
    );
    _distributePayment();
    IRejuvenate(forSaleCurrency).mint(msg.sender, buyAmount);
    emit Buy(msg.sender, amount_, buyAmount);
  }

  /// @dev helper function to distribute the payment to dev and treasury
  function _distributePayment() private nonReentrant {
    // fixed rate of 10% goes to dev
    IERC20(paymentCurrency).safeTransfer(
      _dev,
      IERC20(paymentCurrency).balanceOf(address(this)).div(10)
    );
    // send rest to treasury
    IERC20(paymentCurrency).safeTransfer(
      _treasury,
      IERC20(paymentCurrency).balanceOf(address(this))
    );
  }

  /// @notice Gives the remaning amount of tokens up for presale
  /// @dev Subsctract sold tokens from available tokensß
  /// @return uint256 amount of token in WEI
  function remaining() external view returns (uint256) {
    return tokenCap.sub(tokenSold);
  }

  /// @notice Allows the owmer to withdraw stuck tokens
  /// @dev Withdraws whole balance of specified tokens
  /// @param token Address of Token to withdraw
  function inCaseTokensGetStuck(address token) external onlyOwner {
    uint256 amount = IERC20(token).balanceOf(address(this));
    IERC20(token).transfer(msg.sender, amount);
  }
}
