// SPDX-License-Identifier: MIT
pragma solidity^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DecentrailizedStablecoin} from "../../src/DecentrailizedStablecoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DSCengine} from "../../src/DSCengine.sol";
import {Handler} from "./Handler.t.sol";


contract InvariantsTest is StdInvariant, Test {
    DeployDSC deployer;
    DecentrailizedStablecoin dsc;
    DSCengine engine;
    HelperConfig config;
    address weth;
    address wbtc;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, engine, config ) = deployer.run(); 
        (,,weth,wbtc,) = config.activeNetworkConfig();


    }
}