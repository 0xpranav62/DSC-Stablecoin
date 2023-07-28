// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {DecentrailizedStablecoin} from "./DecentrailizedStablecoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
contract DSCengine is ReentrancyGuard {
    //////////////
    // StateVar //
    //////////////
    mapping(address token => address priceFeed) private s_priceFeeds;
    DecentrailizedStablecoin private immutable i_dsc;
    mapping (address user => mapping(address token => uint256 amount)) private s_collateralDeposit;

    //////////////
    //  Events  //
    //////////////
    event CollateralDeposit(address indexed user, address indexed collateral, uint256 indexed amount);

    //////////////
    //   ERROR  //
    //////////////

    error DSCengine__AmountShouldBeMoreThanZero();
    error DSCengine__TokenAddressesArrayAndPriceFeedAddressArrayShouldBeEqual();
    error DSCengine__TokenNotAllowed();
    error DSCengine__TransferFailed();

    //////////////
    // Modifier //
    //////////////

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCengine__AmountShouldBeMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCengine__TokenNotAllowed();
        }
        _;
    }

    //////////////
    // Function //
    //////////////

    constructor(
        address[] memory tokenAddress,
        address[] memory priceFeedAddress,
        address DSCAddress
    ) {
        if (tokenAddress.length != priceFeedAddress.length) {
            revert DSCengine__TokenAddressesArrayAndPriceFeedAddressArrayShouldBeEqual();
        }
        for (uint256 i = 0; i < tokenAddress.length; i++) {
            s_priceFeeds[tokenAddress[i]] = priceFeedAddress[i];
        }
        i_dsc = DecentrailizedStablecoin(DSCAddress);
    }

    ///////////////////////
    // External Function //
    ///////////////////////

    // Deposit the collateral in exchange of minted DSC
    function depositCollateralAndMintDsc() external {}

    /*
     * @notice Follow CEI (Check Effects and Interaction)
     * @param  tokenCollaternalAddress the address of the token to deposit as collateral
     * @param  amountCollateral the amount of collateral to deposit
     */
    function depositCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    )
        external
        isAllowedToken(tokenCollateralAddress)
        moreThanZero(amountCollateral)
        nonReentrant
    {
        s_collateralDeposit[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposit(msg.sender ,tokenCollateralAddress ,amountCollateral);
        (bool success) = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this),amountCollateral);
        if(!success){
            revert DSCengine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function getHealthFactor() external {}

    function liquidate() external view {}
}
