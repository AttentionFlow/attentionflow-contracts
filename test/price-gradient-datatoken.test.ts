import { ethers, type Signer, type Wallet } from 'ethers'
import { describe, beforeEach } from '@jest/globals'
import { config } from 'dotenv'
import {
  IDataToken__factory,
  type IDataTokenFactory,
  IDataTokenFactory__factory
} from '../typechain/contracts'
import {
  type CollectDataTokenOutput,
  type CreateDataTokenInput,
  type CreateDataTokenOutput,
  ProfilelessCollectModule
} from './types'
import {
  generateCollectData,
  generateCreateDataTokenInitVars,
  mintTestToken
} from './utils'
config()
describe('DataTokenFactory Tests', () => {
  const dataTokenFactoryAddr = '0xc6FfA71615d1C77F226ABdA51CfDDEeEfA614FA8'
  const currency = '0xac4D44189ae385D03ca80eDAbb59bEEc682e60e3'

  const rpcUrl = 'https://sepolia-rpc.scroll.io/'
  const privateKey = process.env.PRIVATE_KEY as string
  const contentURI = 'https://dataverse-os.com'

  describe('ProfilelessDataTokenFactory', () => {
    let signer: Signer
    let dataTokenFactory: IDataTokenFactory

    beforeEach(async () => {
      const provider = new ethers.providers.JsonRpcProvider(rpcUrl, 534351)
      signer = new ethers.Wallet(privateKey, provider)

      dataTokenFactory = IDataTokenFactory__factory.connect(
        dataTokenFactoryAddr,
        signer
      )

      // mint test token
      await mintTestToken({
        signer: signer as Wallet,
        currency,
        recipient: await signer.getAddress()
      })
    })

    test.skip('create dataToken with priceGradientCollectModule', async () => {
      const input: CreateDataTokenInput = {
        contentURI,
        collectModule: ProfilelessCollectModule.FeeCollectModule,
        collectLimit: 100,
        amount: ethers.utils.parseEther('1'),
        currency,
        recipient: await signer.getAddress()
      }

      const initVars = generateCreateDataTokenInitVars(input)
      const output: Partial<CreateDataTokenOutput> = {}
      await dataTokenFactory.createDataToken(initVars).then(async (tx: any) => {
        const r = await tx.wait()
        r.events.forEach((e: any) => {
          if (e.event === 'DataTokenCreated') {
            output.creator = e.args[0]
            output.originalContract = e.args[1]
            output.dataToken = e.args[2]
          }
        })
      })
      console.log('output: ', output)
      // output:  {
      //   creator: '0xE85483888e10917ba7Bc1584BE303d5a3288d033',
      //     originalContract: '0xc6FfA71615d1C77F226ABdA51CfDDEeEfA614FA8',
      //     dataToken: '0xFF1e501E348dc7c6409c50375BDB08e48a27608a'
      // }
      return output
      // @ts-expect-error timeout
    }, 500000)

    test('collect with priceGradientCollectModule', async () => {
      const dataToken = IDataToken__factory.connect(
        '0xFF1e501E348dc7c6409c50375BDB08e48a27608a',
        signer
      )
      const metadata = await dataToken.getMetadata()
      console.log('metadata: ', metadata)

      const data = await generateCollectData({
        signer: signer as Wallet,
        meta: metadata
      })
      const output: Partial<CollectDataTokenOutput> = {}
      await dataToken.collect(data).then(async (tx: any) => {
        const r = await tx.wait()
        r.events.forEach((e: any) => {
          if (e.event === 'Collected') {
            output.dataToken = e.args.dataToken
            output.collector = e.args.collector
            output.collectNFT = e.args.collectNFT
            output.tokenId = e.args.tokenId.toString()
          }
        })
      })
      console.log('output: ', output)
      // output:  {
      //   dataToken: '0xFF1e501E348dc7c6409c50375BDB08e48a27608a',
      //   collector: '0xE85483888e10917ba7Bc1584BE303d5a3288d033',
      //   collectNFT: '0xFF1e501E348dc7c6409c50375BDB08e48a27608a',
      //   tokenId: '1'
      //   }
      return output
      // @ts-expect-error timeout
    }, 500000)
  })
})
