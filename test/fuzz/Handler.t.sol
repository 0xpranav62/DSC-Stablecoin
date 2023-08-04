// SPDX-License-Identifier: MIT
pragma solidity^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DecentrailizedStablecoin} from "../../src/DecentrailizedStablecoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DSCengine} from "../../src/DSCengine.sol";

contract Handler is Test {
    
}