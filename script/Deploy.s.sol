// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import {Config} from "datatoken-contracts/script/Config.sol";
import {DeployDataTokenHub} from "datatoken-contracts/script/DataTokenHub/01_DeployDataTokenHub.s.sol";
import {DeployProfilelessDataTokenFactory} from
    "datatoken-contracts/script/Profileless/01_DeployProfilelessDataTokenFactory.s.sol";
import {DeployProfilelessDataTokenModules} from
    "datatoken-contracts/script/Profileless/02_DeployProfilelessDataTokenModules.s.sol";
import {WhitelistDataTokenFactory} from "datatoken-contracts/script/DataTokenHub/02_WhitelistDataTokenFactory.s.sol";

import {DeployPriceGradientCollectModule} from "./DeployPriceGradientCollectModule.s.sol";

contract Deploy is Script, Config {
    DeployDataTokenHub deployDataTokenHub;
    DeployProfilelessDataTokenFactory deployProfilelessDataTokenFactory;
    DeployProfilelessDataTokenModules deployProfilelessDataTokenModules;
    DeployPriceGradientCollectModule deployPriceGradientCollectModule;

    WhitelistDataTokenFactory whitelistDataTokenFactory;

    function run() public {
        _setUp();
        address dataTokenHub = deployDataTokenHub.run();
        address profilelessDataTokenFactory = deployProfilelessDataTokenFactory.run(dataTokenHub);
        address[] memory factories = new address[](1);
        factories[0] = profilelessDataTokenFactory;
        whitelistDataTokenFactory.run(dataTokenHub, factories);
        deployProfilelessDataTokenModules.run(dataTokenHub, profilelessDataTokenFactory);
        deployPriceGradientCollectModule.run(dataTokenHub, profilelessDataTokenFactory);
    }

    function _setUp() internal {
        deployDataTokenHub = new DeployDataTokenHub();
        deployProfilelessDataTokenFactory = new DeployProfilelessDataTokenFactory();
        deployProfilelessDataTokenModules = new DeployProfilelessDataTokenModules();
        deployPriceGradientCollectModule = new DeployPriceGradientCollectModule();
        whitelistDataTokenFactory = new WhitelistDataTokenFactory();
    }
}
