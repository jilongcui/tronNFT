const port = process.env.HOST_PORT || 9060
/*
Create a .env file (it must be gitignored) containing something like

  export PRIVATE_KEY_MAINNET=4E7FECCB71207B867C495B51A9758B104B1D4422088A87F4978BE64636656243

Then, run the migration with:

  source .env && tronbox migrate --network mainnet

*/

module.exports = {
  networks: {
    mainnet: {
      // Don't put your private key here:
      privateKey: process.env.PRIVATE_KEY_MAINNET,
      userFeePercentage: 80,
      feeLimit: 1500 * 1e6,
      fullHost: 'https://api.trongrid.io',
      timeout: 2000,
      mnemonic: process.env.MNEMONIC_MAINNET,
      network_id: '*'
    },
    shasta: {
      privateKey: process.env.PRIVATE_KEY_SHASTA,
      userFeePercentage: 100,
      feeLimit: 5000 * 1e6,
      fullHost: 'https://api.shasta.trongrid.io',
      timeout: 2000,
      mnemonic: process.env.MNEMONIC_SHASTA,
      network_id: '2'
    },
    nile: {
      privateKey: process.env.PRIVATE_KEY_NILE,
      userFeePercentage: 100,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://api.nileex.io',
      network_id: '3'
    },
    development: {
      // For trontools/quickstart docker image
      privateKey: 'cef2f56267bab49ba95035b5d9528c7078aadfa8267c6e475ed48d48506fdb23',
      mnemonic: 'novel possible lion inner suffer extend lock hamster spoon belt',
      userFeePercentage: 0,
      feeLimit: 1000 * 1e6,
      fullHost: 'http://47.102.218.158:' + port,
      network_id: '9'
    },
    compilers: {
      solc: {
        version: '0.8.6'
      }
    }
  },
  // solc compiler optimize
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    },
    evmVersion: 'istanbul'
  }
}
