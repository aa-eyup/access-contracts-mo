// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title BaseUpgradeablePausable contract
 * @notice This is our Base contract that most other contracts inherit from. It includes many standard
 *  useful abilities like ugpradeability, pausability, access control, and re-entrancy guards.
 */

contract BaseRoleCheckerPausable is Initializable, AccessControl, Pausable {
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  // Pre-reserving a few slots in the base contract in case we need to add things in the future.
  // This does not actually take up gas cost or storage cost, but it does reserve the storage slots.
  uint256[50] private __gap1;
  uint256[50] private __gap2;
  uint256[50] private __gap3;
  uint256[50] private __gap4;

  // solhint-disable-next-line func-name-mixedcase
  function __BaseRoleCheckerPausable__init(address _admin) public initializer {
    require(_admin != address(0), "Admin cannot be the zero address");

    _setupRole(ADMIN_ROLE, _admin);
    _setupRole(PAUSER_ROLE, _admin);

    // When calling grantRole, AccessControl checks if the msg.sender has the admin role for the role being granted
    //  so when the ADMIN_ROLE is being granted to an account, the msg.sender must have the admin role for ADMIN_ROLE (which is ADMIN_ROLE).
    // set the PAUSER_ROLE's admin role on the struct to ADMIN_ROLE
    _setRoleAdmin(PAUSER_ROLE, ADMIN_ROLE);
    // set the ADMIN_ROLE's admin role on the struct to ADMIN_ROLE
    _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
  }

  function isAdmin() public view returns (bool) {
    return hasRole(ADMIN_ROLE, _msgSender());
  }

  modifier onlyAdmin() {
    require(isAdmin(), "Must have admin role to perform this action");
    _;
  }

  /**
   * @dev Pauses all functions guarded by Pause
   *
   * See {Pausable-_pause}.
   *
   * Requirements:
   *
   * - the caller must have the PAUSER_ROLE.
   */

  function pause() public onlyPauserRole {
    _pause();
  }

  /**
   * @dev Unpauses the contract
   *
   * See {Pausable-_unpause}.
   *
   * Requirements:
   *
   * - the caller must have the Pauser role
   */
  function unpause() public onlyPauserRole {
    _unpause();
  }

  modifier onlyPauserRole() {
    require(hasRole(PAUSER_ROLE, _msgSender()), "Must have pauser role to perform this action");
    _;
  }
}
