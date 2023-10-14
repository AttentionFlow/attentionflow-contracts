// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ProfilelessDataToken} from "datatoken-contracts/core/profileless/ProfilelessDataToken.sol";
import {ProfilelessCollectModuleBaseTest} from "../lib/datatoken-contracts/test/profileless/modules/Base.t.sol";
import {DataTypes} from "datatoken-contracts/libraries/DataTypes.sol";
import {Constants} from "datatoken-contracts/libraries/Constants.sol";
import {Errors} from "datatoken-contracts/libraries/Errors.sol";
import {PriceGradientCollectModule} from "../contracts/PriceGradientCollectModule.sol";
import "forge-std/Test.sol";

contract PriceGradientCollectModuleTest is ProfilelessCollectModuleBaseTest {
    uint40 constant ONE_DAY = 24 hours;
    PriceGradientCollectModule priceGradientModule;

    function setUp() public {
        baseSetUp();
        priceGradientModule = new PriceGradientCollectModule(
            address(dataTokenHub),
            address(dataTokenFactory)
        );
        console.log("priceGradientModule: ", address(priceGradientModule));
    }

    function test_currentPrice() public {
        dataToken = _createDataverseDataToken();
        DataTypes.Metadata memory metadata = dataToken.getMetadata();
        assertEq(priceGradientModule.getPublicationData(metadata.pubId).amount, 10000);
        assertEq(priceGradientModule.getPublicationData(metadata.pubId).currentCollects, 0);
        assertEq(priceGradientModule.getPublicationData(metadata.pubId).amount, amount);
        assertEq(priceGradientModule.getPublicationData(metadata.pubId).currency, address(currency));
        assertEq(priceGradientModule.getPublicationData(metadata.pubId).recipient, dataTokenOwner);
        assertEq(priceGradientModule.getPublicationData(metadata.pubId).dataToken, address(dataToken));
    }

    function test_InitializePublicationCollectModule() public {
        dataToken = _createDataverseDataToken();
        DataTypes.Metadata memory metadata = dataToken.getMetadata();
        PriceGradientCollectModule.ProfilePublicationData memory profilePublicationData =
            priceGradientModule.getPublicationData(metadata.pubId);
        assertEq(profilePublicationData.collectLimit, 10000);
        assertEq(profilePublicationData.currentCollects, 0);
        assertEq(profilePublicationData.amount, amount);
        assertEq(profilePublicationData.currency, address(currency));
        assertEq(profilePublicationData.recipient, dataTokenOwner);
        assertEq(profilePublicationData.dataToken, address(dataToken));

        uint256 newAmount = priceGradientModule.currentPrice(0);
        assertEq(newAmount, 1015748892146053438);
        console.log("current price : ", newAmount);
    }

    function test_Collect() public {
        dataToken = _createDataverseDataToken();
        console.log("dataToken pubId:", dataToken.getMetadata().pubId);
        uint256 newAmount = priceGradientModule.currentPrice(dataToken.getMetadata().pubId);

        bytes memory validateData = abi.encode(address(currency), newAmount);
        bytes memory data = abi.encode(collector, validateData);

        vm.startPrank(collector);
        currency.approve(address(priceGradientModule), newAmount);
        dataToken.collect(data);
        vm.stopPrank();

        DataTypes.Metadata memory metadata = dataToken.getMetadata();
        PriceGradientCollectModule.ProfilePublicationData memory profilePublicationData =
            priceGradientModule.getPublicationData(metadata.pubId);
        assertEq(profilePublicationData.currentCollects, 1);
        assertEq(profilePublicationData.amount, newAmount);
    }

    function _createDataverseDataToken() internal returns (ProfilelessDataToken) {
        uint40 endTimestamp = uint40(block.timestamp) + ONE_DAY;
        DataTypes.ProfilelessPostData memory postData;
        postData.contentURI = contentURI;
        postData.collectModule = address(priceGradientModule);
        postData.collectModuleInitData = abi.encode(collectLimit, amount, currency, dataTokenOwner, endTimestamp);
        bytes memory initVars = abi.encode(postData);

        vm.prank(dataTokenOwner);
        address dataTokenAddress = dataTokenFactory.createDataToken(initVars);
        return ProfilelessDataToken(dataTokenAddress);
    }
}
