import { type BigNumberish, ethers, type Wallet } from 'ethers'
import {
  CurrencyMock__factory,
  IERC20__factory,
  PriceGradientCollectModule__factory
} from '../typechain/contracts'
import { type DataTypes } from '../typechain/contracts/IDataToken'
import { type CreateDataTokenInput } from './types'
import { abiCoder } from './constants'

export const mintTestToken = async ({
  signer,
  currency,
  recipient
}: {
  signer: Wallet
  currency: string
  recipient: string
}): Promise<void> => {
  const erc20 = CurrencyMock__factory.connect(currency, signer)
  const bal = await erc20.balanceOf(recipient)
  if (bal.gt(ethers.utils.parseEther('500'))) {
    return
  }
  await erc20.mint(recipient, ethers.utils.parseEther('10000'))
}

export const checkERC20BalanceAndApprove = async (
  signer: Wallet,
  currency: string,
  amount: BigNumberish,
  spender: string
): Promise<void> => {
  const erc20 = IERC20__factory.connect(currency, signer)
  const signerAddr = await signer.getAddress()
  const userBalance = await erc20.balanceOf(signerAddr)
  if (userBalance.lt(amount)) {
    throw new Error('Insufficient Balance')
  }
  await erc20.approve(spender, amount)
}

export const generateCreateDataTokenInitVars = (
  input: CreateDataTokenInput
): string => {
  const generateModuleInitData = (input: CreateDataTokenInput): string => {
    return abiCoder.encode(
      ['uint256', 'uint256', 'address', 'address'],
      [input.collectLimit, input.amount, input.currency, input.recipient]
    )
  }

  const initData = {
    contentURI: input.contentURI,
    collectModule: input.collectModule,
    collectModuleInitData: generateModuleInitData(input)
  }

  return abiCoder.encode(
    [
      'tuple(string contentURI,address collectModule,bytes collectModuleInitData) initData'
    ],
    [initData]
  )
}

export const generateCollectData = async ({
  signer,
  meta
}: {
  signer: Wallet
  meta: DataTypes.MetadataStructOutput
}): Promise<string> => {
  const collectModule = PriceGradientCollectModule__factory.connect(
    meta.collectModule,
    signer
  )

  const generateCollectData = async (
    meta: DataTypes.MetadataStructOutput
  ): Promise<string> => {
    const moduleInfo = await collectModule.getPublicationData(meta.pubId)
    const price = await collectModule.currentPrice(meta.pubId)

    await checkERC20BalanceAndApprove(
      signer,
      moduleInfo.currency,
      price,
      meta.collectModule
    )

    return abiCoder.encode(
      ['address', 'uint256'],
      [moduleInfo.currency, price]
    )
  }

  const collector = await signer.getAddress()
  const collectVars = await generateCollectData(meta)
  return abiCoder.encode(['address', 'bytes'], [collector, collectVars])
}
