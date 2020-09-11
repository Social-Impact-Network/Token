// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/utils/Pausable.sol";
//import "openzeppelin-solidity/contracts/token/ERC20/ERC20Snapshot.sol";

contract SIToken is ERC20, Pausable {
    address _network;

    modifier isNetwork() {
        require(msg.sender == _network, "Not allowed!");
        _;
    }

    constructor () public ERC20("Social Impact Token", "SIT") Pausable() {
        _mint(msg.sender, 1);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override{
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "token transfer while paused not possible");
    }

    function pause() isNetwork whenNotPaused public {
        require(msg.sender == _network, "Not allowed!");
        _pause();
    }

    function unpause() isNetwork whenPaused public {
        require(msg.sender == _network, "Not allowed!");
        _unpause();
    }

}