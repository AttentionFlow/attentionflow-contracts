import { type BigNumberish } from 'ethers'
import { type DataTypes } from '../typechain/contracts/IDataToken'

type Chain = 'Polygon' | 'Mumbai' | 'BSC' | 'BSCT' | 'Other'

type CreateDataTokenInput = {
  contentURI: string
  collectModule: string
} & LensDataTokenInput &
CyberDataTokenInput &
ProfilelessDataTokenInput

interface LensDataTokenInput {
  profileId?: BigNumberish
  amount?: BigNumberish
  currency?: string
  collectLimit?: BigNumberish
  recipient?: string
  endTimestamp?: BigNumberish
  followerOnly?: boolean
  referralFee?: BigNumberish
  deadline?: string
}

interface CyberDataTokenInput {
  profileId?: BigNumberish
  amount?: BigNumberish
  currency?: string
  totalSupply?: BigNumberish
  subscribeRequired?: boolean
  signerAddr?: string
  root?: string
  name?: string
  symbol?: string
  transferable?: boolean
  deployAtRegister?: boolean
  deadline?: string
}

interface ProfilelessDataTokenInput {
  collectLimit?: BigNumberish
  amount?: BigNumberish
  currency?: string
  recipient?: string
  endTimestamp?: BigNumberish
}

interface CreateDataTokenOutput {
  creator: string
  originalContract: string
  dataToken: string
}

interface CollectDataTokenOutput {
  dataToken: string
  collector: string
  collectNFT: string
  tokenId: BigNumberish
}

interface CyberCollectParamsStruct {
  collector: string
  profileId: BigNumberish
  essenceId: BigNumberish
}

interface Sig {
  v: number
  r: string
  s: string
  deadline: string
}

// Lens
interface CollectWithSigData {
  collector: string
  profileId: BigNumberish
  pubId: BigNumberish
  data: string
  sig: Sig
}

interface PostWithSigData {
  profileId: BigNumberish
  contentURI: string
  collectModule: string
  collectModuleInitData: string
  referenceModule: string
  referenceModuleInitData: string
  sig: Sig
}

interface ProfilelessPostData {
  contentURI: string
  collectModule: string
  collectModuleInitData: string
}

interface ProfilelessPostDataSigParams {
  dataTokenCreator: string
  sig: Sig
}

enum LensCollectModule {
  FeeCollectModule = 'FeeCollectModule',
  FreeCollectModule = 'FreeCollectModule',
  LimitedTimedFeeCollectModule = 'LimitedTimedFeeCollectModule',
  LimitedFeeCollectModule = 'LimitedFeeCollectModule',
}

enum ProfilelessCollectModule {
  FeeCollectModule = 'FeeCollectModule',
  FreeCollectModule = 'FreeCollectModule',
  LimitedTimedFeeCollectModule = 'LimitedTimedFeeCollectModule',
}

type CollectModule = LensCollectModule | ProfilelessCollectModule

interface CustomizeConfig {
  generateCollectData: (meta: DataTypes.MetadataStructOutput) => Promise<string>
  generateModuleInitData: (input: CreateDataTokenInput) => Promise<string>
  dataTokenFactory: string
  collectModule: string
}

export {
  type CustomizeConfig,
  type Chain,
  type ProfilelessPostData,
  type ProfilelessPostDataSigParams,
  type CreateDataTokenOutput,
  type Sig,
  type PostWithSigData,
  type CollectWithSigData,
  type CreateDataTokenInput,
  type CollectDataTokenOutput,
  type CyberCollectParamsStruct,
  LensCollectModule,
  ProfilelessCollectModule,
  type CollectModule
}
