// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @dev Interface to interact with contract below
interface IAddressRegistry {
  function add(address target_) external;

  function remove(address target_) external;

  function onList(address target_) external view returns (bool);

  function notOnList(address target_) external view returns (bool);
}

/// @title
/// @author Kevin Scheeren | Rejuvenate Finance
/// @dev keeps track of addresses with a binary state
contract AddressRegistry is Initializable, OwnableUpgradeable {
  mapping(address => bool) public list;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize() public initializer {
    __Ownable_init();
  }

  function add(address target_) external onlyOwner {
    list[target_] = true;
  }

  function remove(address target_) external onlyOwner {
    list[target_] = false;
  }

  function onList(address target_) external view returns (bool) {
    return list[target_];
  }

  function notOnList(address target_) external view returns (bool) {
    return !list[target_];
  }

  function inCaseTokensGetStuck(address token_) external onlyOwner {
    uint256 amount = IERC20Upgradeable(token_).balanceOf(address(this));
    IERC20Upgradeable(token_).transfer(msg.sender, amount);
  }
}
