// SPDX-License-Identifier: MIT
pragma solidity^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DecentrailizedStablecoin} from "../src/DecentrailizedStablecoin.sol";
import {DSCengine} from "../src/DSCengine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDSC is Test {
    address[] public tokenAddress;
    address[] public priceFeed;
    function run() external returns(DecentrailizedStablecoin, DSCengine , HelperConfig) {
      HelperConfig helperConfig = new HelperConfig();

      ( address wethUsdPriceFeed,
        address wbtcUsdPriceFeed,
        address wETH,
        address wBTC,
        uint256 deployerKey) = helperConfig.activeNetworkConfig();

        tokenAddress = [wETH,wBTC];
        priceFeed =[wethUsdPriceFeed,wbtcUsdPriceFeed];

        vm.startBroadcast(deployerKey);
        DecentrailizedStablecoin dsc = new DecentrailizedStablecoin();
        DSCengine engine = new DSCengine(tokenAddress,priceFeed,address(dsc));

        dsc.transferOwnership(address(engine));
        vm.stopBroadcast();

        return (dsc,engine,helperConfig);
    }
}