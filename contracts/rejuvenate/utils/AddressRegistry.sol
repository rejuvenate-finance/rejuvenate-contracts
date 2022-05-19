// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @dev Interface to interact with contract below
interface IAddressRegistry {
  function onList(address target_) external view returns (bool);

  function notOnList(address target_) external view returns (bool);
}

/// @title
/// @author Rejuvenate Finance
/// @dev keeps track of addresses with a binary state
contract AddressRegistry is Initializable, OwnableUpgradeable {
  mapping(address => bool) public list;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  /// @dev replaces constructor (proxy)
  function initialize() public initializer {
    __Ownable_init();
  }

  /// @dev adds address to registry
  /// @param target_ address to be added
  function add(address target_) external onlyOwner {
    list[target_] = true;
  }

  /// @dev removes address to registry
  /// @param target_ address to be removed
  function remove(address target_) external onlyOwner {
    list[target_] = false;
  }

  /// @dev checks if a specific address is registered
  /// @param target_ address which will be checked
  /// @return bool true if target_ is registered
  function onList(address target_) external view returns (bool) {
    return list[target_];
  }

  /// @dev checks if a specific address is not registered
  /// @param target_ address which will be checked
  /// @return bool true if target_ is not registered
  function notOnList(address target_) external view returns (bool) {
    return !list[target_];
  }

  /// @notice release stuck tokens from the contract
  /// @dev let's the owner remove unwanted/stuck tokens from the c
  /// @param token_ address of the token to be unstuck
  function inCaseTokensGetStuck(address token_) external onlyOwner {
    uint256 amount = IERC20Upgradeable(token_).balanceOf(address(this));
    IERC20Upgradeable(token_).transfer(msg.sender, amount);
  }
}
