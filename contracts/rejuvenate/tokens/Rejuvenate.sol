// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../utils/AddressRegistry.sol";

/// @dev Interface to interact with contract below
interface IRejuvenate {
  function mint(address to_, uint256 amount_) external;
}

/// @title Rejuvenate (RJV) Token
/// @author Kevin Scheeren | Rejuvenate Finance
/// @dev Base Token for the Rejuvenate Finance Protocol
contract Rejuvenate is
  Initializable,
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable,
  ERC20CappedUpgradeable
{
  address public whitelist;
  address public blacklist;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize(address whitelist_, address blacklist_)
    public
    initializer
  {
    __ERC20_init("Rejuvenate", "RJV");
    __Ownable_init();
    __ReentrancyGuard_init();
    // cap at 10.000.000 Tokens
    __ERC20Capped_init(10000000 * 10**18);

    whitelist = whitelist_;
    blacklist = blacklist_;
  }

  function _beforeTokenTransfer(
    address from_,
    address to_,
    uint256 amount_
  ) internal override {
    super._beforeTokenTransfer(from_, to_, amount_);
    IAddressRegistry bl = IAddressRegistry(blacklist);
    require(bl.notOnList(from_) && bl.notOnList(to_), "!blacklist");
  }

  function mint(address to_, uint256 amount_) external nonReentrant {
    require(IAddressRegistry(whitelist).onList(msg.sender), "!whitelist");
    _mint(to_, amount_);
  }

  function inCaseTokensGetStuck(address token_) external onlyOwner {
    require(token_ != address(this), "!token");
    uint256 amount = IERC20Upgradeable(token_).balanceOf(address(this));
    IERC20Upgradeable(token_).transfer(msg.sender, amount);
  }
}
