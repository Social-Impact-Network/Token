// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts//access/AccessControl.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/utils/Pausable.sol";
//import "openzeppelin-solidity/contracts/token/ERC20/ERC20Snapshot.sol";

contract SIToken is Context, AccessControl, ERC20, Pausable {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");


    constructor () public AccessControl() ERC20("Social Impact Token", "SIT") Pausable()  {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());

        _mint(msg.sender, 1);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override{
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "SIToken: token transfer while paused not possible");
    }

    function pause() whenNotPaused public {
        require(hasRole(PAUSER_ROLE, _msgSender()), "SIToken: must have pauser role to pause");
        _pause();
    }

    function unpause() whenPaused public {
        require(hasRole(PAUSER_ROLE, _msgSender()), "SIToken: must have pauser role to pause");
        _unpause();
    }

    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "SIToken: must have minter role to mint");
        _mint(to, amount);
    }
}