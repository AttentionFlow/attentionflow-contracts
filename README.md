## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum
application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending
  transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

# Deployed Contract Address

```ts
const ContractsAddress = {
  DataTokenHub: "0x2Fc8c6036261980A557d55E9eb5a63f3fF967125",
  Profileless: {
    DataTokenFactory: "0xc6FfA71615d1C77F226ABdA51CfDDEeEfA614FA8",
    LimitedFeeCollectModule: "0x16d7E8E51Be046578970718ad55B1Bd7Bba7745a",
    FreeCollectModule: "0xcA0Be665C8484Ab20282eFCF82cEe36d6AFB5959",
    LimitedTimedFeeCollectModule: "0x7b3F2Da2f0bB05a2422Aec70aBB5890B652B1310",
    PriceGradientCollectModule: "0xfB1BC11167CBF1c79Ca91dD0F51EEC3185bb7697",
  },
  MockCurrency: "0xac4D44189ae385D03ca80eDAbb59bEEc682e60e3",
};
```
