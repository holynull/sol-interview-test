var SolTest = artifacts.require('./SolTest.sol')

module.exports = async (deployer, network, accounts) => {
  const [devAccount, ownerAccount, tempFactoryAddress] = accounts
  const fee = 20 * 10 ** 9
  await deployer.deploy(
    SolTest,
    devAccount,
    fee,
    ownerAccount,
    tempFactoryAddress,
    { from: devAccount }
  )
}
