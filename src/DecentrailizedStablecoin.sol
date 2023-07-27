// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Decentrailized stable coin
 * @author 0xpranav
 * @notice This contract is implemented using the ERC20 token and it is governed by DSCengine.
 */
contract DecentrailizedStablecoin is ERC20Burnable, Ownable {
    error DecentrailizedStablecoin__MustBeMoreThanZero();
    error DecentrailizedStablecoin__BurnAmountExceedsBalance();
    error DecentrailizedStablecoin__NotAddressZero();

    constructor() ERC20("DecentrailizedStablecoin", "DSC") {}

    // Function burn() which burn the stablecoin when exchange in collateral: Stablecoin -> burn -> collateral
    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            // amount should be more than zero
            revert DecentrailizedStablecoin__MustBeMoreThanZero();
        }
        if (balance < _amount) {
            //  balance should be greater than the amount to burn
            revert DecentrailizedStablecoin__BurnAmountExceedsBalance();
        }

        super.burn(_amount);
    }

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            // Cannot send to address zero
            revert DecentrailizedStablecoin__NotAddressZero();
        }
        if (_amount <= 0) {
            revert DecentrailizedStablecoin__MustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
