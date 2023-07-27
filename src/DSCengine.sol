// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title  Dsc Engine
 * @author 0xpranav
 * @notice This contract handles all the logic of our decentrialized stable coin.
 *         Our stabe coin has 3 properties
 *         1. Its an collateral backed stable coin (Eth or btc).
 *         2. Algorithmic
 *         3. Relative Stablility pegged  to Dollar
 * @notice The core mechanism of our stable coin is based on Dai stablecoin
 *         As if Dai had no fee, no governance, and is backed by collateral
 */
contract DSCengine {
    constructor() {}

    // Deposit the collateral in exchange of minted DSC
    function depositCollateralAndMintDsc() external {}

    function depositCollateral() external {}

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function getHealthFactor() external {}

    function liquidate() external view {}
}
