// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Errors} from "datatoken-contracts/contracts/libraries/Errors.sol";
import {ProfilelessCollectModuleBase} from
    "datatoken-contracts/contracts/core/profileless/base/ProfilelessCollectModuleBase.sol";

contract PriceGradientCollectModule is ProfilelessCollectModuleBase {
    struct ProfilePublicationData {
        uint256 collectLimit;
        uint256 currentCollects;
        uint256 amount;
        address currency;
        address recipient;
        address dataToken;
    }

    error PriceNotMatch(uint256 expectPrice);

    using SafeERC20 for IERC20;

    address public immutable DATA_TOKEN_FACTORY;

    mapping(uint256 => ProfilePublicationData) internal _dataByPublication;
    /// @dev pubId => shared people => bool
    mapping(uint256 => mapping(address => bool)) internal _isFeeFree;

    constructor(address dataTokenHub, address dataTokenFactory) ProfilelessCollectModuleBase(dataTokenHub) {
        DATA_TOKEN_FACTORY = dataTokenFactory;
    }

    modifier onlyDataTokenFactory() {
        if (msg.sender != DATA_TOKEN_FACTORY) {
            revert Errors.NotDataTokenFactory();
        }
        _;
    }

    function initializePublicationCollectModule(uint256 pubId, bytes calldata data, address dataToken)
        external
        onlyDataTokenFactory
        returns (bytes memory)
    {
        (uint256 collectLimit, uint256 amount, address currency, address recipient) =
            abi.decode(data, (uint256, uint256, address, address));

        if (collectLimit == 0 /*!_isCurrencyWhitelistedByHub(currency) ||*/ || amount == 0) {
            revert Errors.InitParamsInvalid();
        }

        ProfilePublicationData memory _profilePublicationData;

        _profilePublicationData.collectLimit = collectLimit;
        _profilePublicationData.amount = amount;
        _profilePublicationData.currency = currency;
        _profilePublicationData.recipient = recipient;
        _profilePublicationData.dataToken = dataToken;

        _dataByPublication[pubId] = _profilePublicationData;

        return data;
    }

    function processCollect(uint256 id, address collector, bytes calldata data) external onlyDataToken(id) {
        if (_dataByPublication[id].currentCollects >= _dataByPublication[id].collectLimit) {
            revert Errors.ExceedCollectLimit();
        }
        ++_dataByPublication[id].currentCollects;
        _processCollect(collector, id, data);
    }

    function _processCollect(address collector, uint256 pubId, bytes calldata data) internal {
        ProfilePublicationData storage targetProfilePublicationData = _dataByPublication[pubId];
        uint256 newAmount = currentPrice(pubId);
        _dataByPublication[pubId].amount = newAmount;
        _validateDataIsExpected(data, targetProfilePublicationData.currency, newAmount);

        if (_isFeeFree[pubId][collector]) {
            _isFeeFree[pubId][collector] = false;
        } else {
            if (targetProfilePublicationData.amount > 0) {
                IERC20(targetProfilePublicationData.currency).safeTransferFrom(
                    collector, targetProfilePublicationData.recipient, targetProfilePublicationData.amount
                );
            }
        }
    }

    function _validateDataIsExpected(bytes calldata data, address currency, uint256 amount) internal pure {
        (address decodedCurrency, uint256 decodedAmount) = abi.decode(data, (address, uint256));
        if (decodedAmount != amount || decodedCurrency != currency) {
            revert PriceNotMatch(amount);
        }
    }

    function getPublicationData(uint256 id) external view returns (ProfilePublicationData memory) {
        return _dataByPublication[id];
    }

    function _isFromDataToken(uint256 id) internal view override {
        if (_dataByPublication[id].dataToken != msg.sender) {
            revert Errors.NotDataToken();
        }
    }

    function currentPrice(uint256 pubId) public view returns (uint256) {
        uint256 previousPrice = _dataByPublication[pubId].amount;
        uint256 sParam = calculateSquareRoot(previousPrice * 16000 * 1e18) + 1e18;
        uint256 delta = (2 * 1e18 * sParam + 1 * 1e18 * 1e18) * 1e18 / (sParam * sParam);
        return previousPrice + delta;
    }

    function calculateSquareRoot(uint256 value) public pure returns (uint256) {
        uint256 guess = value / 2;
        uint256 previousGuess;

        while (guess != previousGuess) {
            previousGuess = guess;
            guess = (guess + value / guess) / 2;
        }

        return guess;
    }
}
