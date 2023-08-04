// SPDX-License-Identifier: MIT
pragma solidity^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DecentrailizedStablecoin} from "../../src/DecentrailizedStablecoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {DSCengine} from "../../src/DSCengine.sol";

contract DSCengineTest is Test {
    DeployDSC deployer;
    DecentrailizedStablecoin dsc;
    DSCengine engine;
    HelperConfig config;
    address wethPriceFeed;
    address wbtcPriceFeed;
    address weth;
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;
    address public user = makeAddr("user");

    function setUp() public{
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (wethPriceFeed,wbtcPriceFeed,weth,,) = config.activeNetworkConfig();

        ERC20Mock(weth).mint(user,STARTING_ERC20_BALANCE);
    }

    //////////////////////
    // Constructor Test //
    ////////////////////// 

    address[] tokenAddress;
    address[] priceFeedAddress;

    function testRevertIfTokenArrayIsNotEqualPriceFeedArray() public {
        tokenAddress.push(weth);
        priceFeedAddress.push(wethPriceFeed);
        priceFeedAddress.push(wbtcPriceFeed);

        vm.expectRevert(DSCengine.DSCengine__TokenAddressesArrayAndPriceFeedAddressArrayShouldBeEqual.selector);
        new DSCengine(tokenAddress,priceFeedAddress, address(dsc));
    }

    //////////////////
    //  Price Test  //
    //////////////////

    function testIFGetTokenAmountFromUSDCorrect() public {
        uint256 ethValueInUSD = 100 ether;
        uint256 expectedValue = 0.05 ether;

        uint256 actualValue = engine.getTokenAmountFromUSD(weth,ethValueInUSD);

        assertEq(expectedValue,actualValue);
    }
    function testIfGetUSDValueCorrect() public {
        uint256 ethamount = 15e18;   
        uint256 expectedUSDValue = 30000e18;
        uint256 actualUSDValue = engine.getUSDValue(weth, ethamount);
        
        assertEq(expectedUSDValue,actualUSDValue);
    }

    function testRevertIfCollateralZero() public {
        vm.startPrank(user);

        ERC20Mock(weth).approve(address(engine),AMOUNT_COLLATERAL);
        vm.expectRevert(DSCengine.DSCengine__AmountShouldBeMoreThanZero.selector);
        engine.depositCollateral(weth,0);
        vm.stopPrank();
    }

    function testRevertForUnapprovedCollateral() public {
        ERC20Mock ranToken = new ERC20Mock("Ran", "Ran" , user, AMOUNT_COLLATERAL);
        vm.startPrank(user);
        vm.expectRevert(DSCengine.DSCengine__TokenNotAllowed.selector);
        engine.depositCollateral(address(ranToken),AMOUNT_COLLATERAL);
        vm.stopPrank();

    }
}







