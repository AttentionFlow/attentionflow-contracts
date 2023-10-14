// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import {Config} from "datatoken-contracts/script/Config.sol";
import {DeployDataTokenHub} from "datatoken-contracts/script/DataTokenHub/01_DeployDataTokenHub.s.sol";
import {DeployProfilelessDataTokenFactory} from
    "datatoken-contracts/script/Profileless/01_DeployProfilelessDataTokenFactory.s.sol";
import {DeployProfilelessDataTokenModules} from
    "datatoken-contracts/script/Profileless/02_DeployProfilelessDataTokenModules.s.sol";

import {ProfilelessDataTokenFactory} from
    "datatoken-contracts/contracts/core/profileless/ProfilelessDataTokenFactory.sol";
import {PriceGradientCollectModule} from "../contracts/PriceGradientCollectModule.sol";
//import {Config} from "../Config.sol";

contract DeployPriceGradientCollectModule is Script, Config {
    function run(address dataTokenHub, address profilelessDataTokenFactory) public {
        _baseSetUp();
        _privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(_privateKey);
        new PriceGradientCollectModule(dataTokenHub, profilelessDataTokenFactory);
        vm.stopBroadcast();
    }
}
