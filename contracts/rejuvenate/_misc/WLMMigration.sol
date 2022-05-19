// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../tokens/Rejuvenate.sol";

contract WLMMigration is Ownable, ReentrancyGuard {
  address public input;
  address public output;

  event Migrate(address address_, uint256 amount_);

  constructor(address input_, address output_) {
    input = input_;
    output = output_;
  }

  function migrate() external nonReentrant {
    IERC20 tokenIn = IERC20(input);
    IRejuvenate tokenOut = IRejuvenate(output);
    require(tokenIn.balanceOf(msg.sender) > 0, "!balance");
    uint256 amount = tokenIn.balanceOf(msg.sender);
    tokenIn.transferFrom(msg.sender, address(0), amount);
    tokenOut.mint(msg.sender, amount);
    emit Migrate(msg.sender, amount);
  }

  function inCaseTokensGetStuck(address token_) external onlyOwner {
    require(token_ != input && token_ != output, "!token");
    uint256 amount = IERC20Upgradeable(token_).balanceOf(address(this));
    IERC20Upgradeable(token_).transfer(msg.sender, amount);
  }
}
