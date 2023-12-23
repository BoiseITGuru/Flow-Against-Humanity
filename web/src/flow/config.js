import { config } from '@onflow/fcl'

config({
  'app.detail.title': 'Flow Against Humanity', // this adds a custom name to our wallet
  'app.detail.icon':
    'https://bafkreicxmoooyqwcb3h24jxvvdod7aqi7fn2xryo72ltzokeao7s63dbry.ipfs.nftstorage.link', // this adds a custom image to our wallet
  'accessNode.api': process.env.NEXT_PUBLIC_ACCESS_NODE, // this is for the local emulator
  'discovery.wallet': process.env.NEXT_PUBLIC_WALLET, // this is for the local dev wallet
})
