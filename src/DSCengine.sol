// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {DecentrailizedStablecoin} from "./DecentrailizedStablecoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

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
    uint256 private constant ADDITIONAL_PRECISION_VALUE = 1e10;
    uint256 private constant PRECISION_VALUE = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50;
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    mapping(address token => address priceFeed) private s_priceFeeds;
    DecentrailizedStablecoin private immutable i_dsc;
    mapping(address user => mapping(address token => uint256 amount))
        private s_collateralDeposit;
    mapping(address user => uint256 dscAmount) private s_DSCminted;
    address[] private s_collateralTokens;

    //////////////
    //  Events  //
    //////////////
    event CollateralDeposit(
        address indexed user,
        address indexed collateral,
        uint256 indexed amount
    );

    //////////////
    //   ERROR  //
    //////////////

    error DSCengine__AmountShouldBeMoreThanZero();
    error DSCengine__TokenAddressesArrayAndPriceFeedAddressArrayShouldBeEqual();
    error DSCengine__TokenNotAllowed();
    error DSCengine__TransferFailed();
    error DSCengine__BelowMinHealthFactor(uint256 healthFactor);

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
            s_collateralTokens.push(tokenAddress[i]);
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
        s_collateralDeposit[msg.sender][
            tokenCollateralAddress
        ] += amountCollateral;
        emit CollateralDeposit(
            msg.sender,
            tokenCollateralAddress,
            amountCollateral
        );
        bool success = IERC20(tokenCollateralAddress).transferFrom(
            msg.sender,
            address(this),
            amountCollateral
        );
        if (!success) {
            revert DSCengine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    /*
     * @notice This function mint the decentrailized stable coin. The minted value should be less than the
     *         collateral value deposited
     * @param  amountDscToMint The amount dsc to mint
     */
    function mintDsc(
        uint256 amountDscToMint
    ) external moreThanZero(amountDscToMint) nonReentrant {
        s_DSCminted[msg.sender] += amountDscToMint;
        // If they minted too much dsc above thier threshold revert
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function burnDsc() external {}

    function getHealthFactor() external {}

    function liquidate() external view {}

    ////////////////////////////////////////
    // Private and Internal View Function //
    ////////////////////////////////////////

    function _revertIfHealthFactorIsBroken(address user) internal view {
        // This function revert if the user health factor is below the  Min. threshold
        uint256 healthFactor = _healthFactor(user);
        if(healthFactor < MIN_HEALTH_FACTOR){
            revert DSCengine__BelowMinHealthFactor(healthFactor);
        }
    }

    function _getAccountInformation(
        address user
    )
        internal
        view
        returns (uint256 totalDSCminted, uint256 collateralDepositInUSD)
    {
        // This function gets the user Information like:
        // 1. total collateral deposit is usd
        // 2. total dsc minted

        totalDSCminted = s_DSCminted[user];
        collateralDepositInUSD = getAccountCollateralValueInUSD(user);
    }

    /**
     * Return How close the user is to be liquidate.
     * If Health factor is below 1, than user can get liquidate.
     */
    function _healthFactor(address user) internal view returns (uint256) {
        (
            uint256 totalDSCMintedValue,
            uint256 collateralValueInUSD
        ) = _getAccountInformation(user);
        // $1000 Eth = 1000 * 50 = 50000 / 100 = 500
        // $500 dsc mint = 500 * 100 = 50000/500 = 100;
        uint256 collateralAdjustedForThreshold =(collateralValueInUSD*LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold / totalDSCMintedValue);
    }

    /////////////////////////////////////////
    // Public and External View Function  ///
    /////////////////////////////////////////

    function getAccountCollateralValueInUSD(
        address user
    ) public view returns (uint256 totalCollateralValueInUSD) {
        // Loop through each token they have deposit, add thier value in usd
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposit[user][token];
            totalCollateralValueInUSD += getUSDValue(token, amount);
        }
        return totalCollateralValueInUSD;
    }

    function getUSDValue(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(token);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // return price will be price * 1e8(8 decimals)
        // price * 1e10 *  amount
        return
            (uint256(price) * ADDITIONAL_PRECISION_VALUE * amount) /
            PRECISION_VALUE;
    }
}
