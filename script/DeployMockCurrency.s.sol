// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {CurrencyMock} from "datatoken-contracts/contracts/mocks/CurrencyMock.sol";
import {Config} from "datatoken-contracts/script/Config.sol";
import "forge-std/Script.sol";

contract DeployMockCurrency is Script, Config {
    function run() public {
        _baseSetUp();
        _privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(_privateKey);
        new CurrencyMock("AttentionFlow", "AF");
        vm.stopBroadcast();
    }
}
