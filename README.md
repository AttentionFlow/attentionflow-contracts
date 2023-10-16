# AttentionFlow Contracts

We use [datatoken-contracts](https://github.com/dataverse-os/datatoken-contracts) as monetization tool.
> DataToken: DataToken represent ownership of specific data or digital assets. These tokens can be collected, and the resulting revenue will be distributed to the DataToken owners.


We have customized the logic for collect pricing in PriceGradientCollectModule, as the number of collected collect increases, the price of collect will be more influenced by our configured price algorithm as the number of collected collect increases.

The collect price will be (S - 1)^2 / 16000. Each increase of 1 in the quantity of nft collected will result in a rise in price of (2S + 1) / S^2.

## Deployed Contract Address
```ts
const ContractsAddress = {
  DataTokenHub: "0x2Fc8c6036261980A557d55E9eb5a63f3fF967125",
  Profileless: {
    DataTokenFactory: "0xc6FfA71615d1C77F226ABdA51CfDDEeEfA614FA8",
    PriceGradientCollectModule: "0xfB1BC11167CBF1c79Ca91dD0F51EEC3185bb7697",
  },
  MockCurrency: "0xac4D44189ae385D03ca80eDAbb59bEEc682e60e3",
};
```

## Usage

To use attentionflow contracts, follow these steps:

1. Deploy contracts to target evm.
2. Create dataToken.
3. Approve enough erc20 token to priceGradientModule and collect.

## License

This project is licensed under the [MIT License](LICENSE).

## Contributions

Contributions to the AttentionFlow Contracts are welcome! If you have any suggestions, bug reports, or feature requests, please submit them to the [attentionflow contracts issues](https://github.com/AttentionFlow/attentionflow-contracts/issues).