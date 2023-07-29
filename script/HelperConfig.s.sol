// SPDX-License-Identifier: MIT
pragma solidity^0.8.18;
import {Test} from "forge-std/Test.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract HelperConfig is Test {
    struct NetworkConfig {
        address wethUsdPriceFeed;
        address wbtcUsdPriceFeed;
        address wETH;
        address wBTC;
        uint256 deployerKey;
    }
    uint8 constant DECIMALS = 8;
    int256 constant ETH_USD = 2000e8;
    int256 constant BTC_USD = 1000e8;
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    constructor() {
            if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    NetworkConfig activeNetworkConfig;
    function getSepoliaConfig() public view returns(NetworkConfig memory) {
        NetworkConfig memory sepoliaNetworkConfig = NetworkConfig({
            wethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // ETH / USD
            wbtcUsdPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            wETH: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wBTC: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
        return sepoliaNetworkConfig;
    }
    // Note: Due to change in ERCMock contract the below function maybe cause some problems.
    function getAnvilConfig() public returns(NetworkConfig memory) {
        if(activeNetworkConfig.wethUsdPriceFeed != address(0)){
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator ethUsdPriceFeed = new MockV3Aggregator(DECIMALS,ETH_USD);

        ERC20Mock wethPriceFeed = new ERC20Mock();

        MockV3Aggregator btcUsdPriceFeed = new MockV3Aggregator(DECIMALS, BTC_USD);

        ERC20Mock wbtcPriceFeed = new ERC20Mock();
        vm.stopBroadcast();
        
        NetworkConfig memory  anvilNetworkConfig = NetworkConfig({
            wethUsdPriceFeed: address(ethUsdPriceFeed), // ETH / USD
            wbtcUsdPriceFeed: address(btcUsdPriceFeed),
            wETH: address(wethPriceFeed),
            wBTC: address(wbtcPriceFeed),
            deployerKey: DEFAULT_ANVIL_PRIVATE_KEY
        });

        return anvilNetworkConfig;
    }
}