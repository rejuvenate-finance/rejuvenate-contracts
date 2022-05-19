// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../tokens/Rejuvenate.sol";

/// @title WLMMigration
/// @author Rejuvenate Finance
/// @notice Migrates the old WLM Tokens to the new RJV tokens
/// @dev sends the input token to the 'dead' address and mint output tokens (only works if this contract is whitelisted in the Rejuvenate contract)
contract WLMMigration is Ownable, ReentrancyGuard {
  address public input;
  address public output;

  /// @notice Migration Event
  /// @dev Gets emitted when tokens were migrated
  /// @param address_ address who migrated
  /// @param amount_ amount that was migrated
  event Migrate(address address_, uint256 amount_);

  constructor(address input_, address output_) {
    input = input_;
    output = output_;
  }

  /// @notice Migrates the tokens
  /// @dev sends the input token to the 'dead' address and mint output tokens (only works if this contract is whitelisted in the Rejuvenate contract)
  function migrate() external nonReentrant {
    IERC20 tokenIn = IERC20(input);
    IRejuvenate tokenOut = IRejuvenate(output);
    require(tokenIn.balanceOf(msg.sender) > 0, "!balance");
    uint256 amount = tokenIn.balanceOf(msg.sender);
    tokenIn.transferFrom(
      msg.sender,
      0x000000000000000000000000000000000000dEaD,
      amount
    );
    tokenOut.mint(msg.sender, amount);
    emit Migrate(msg.sender, amount);
  }

  /// @notice release stuck tokens from the contract
  /// @dev let's the owner remove unwanted/stuck tokens from the c
  /// @param token_ address of the token to be unstuck
  function inCaseTokensGetStuck(address token_) external onlyOwner {
    require(token_ != input && token_ != output, "!token");
    uint256 amount = IERC20Upgradeable(token_).balanceOf(address(this));
    IERC20Upgradeable(token_).transfer(msg.sender, amount);
  }
}
