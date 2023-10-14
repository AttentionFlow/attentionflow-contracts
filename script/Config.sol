// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Config {
    uint256 internal constant BSCT = 97;
    uint256 internal constant BSC = 56;
    uint256 internal constant POLYGON = 137;
    uint256 internal constant MUMBAI = 80001;

    uint256 internal _privateKey;

    address internal _lensHubProxy = address(0);
    address internal _cyberProfileProxy = address(0);

    function _baseSetUp() internal {}
}
