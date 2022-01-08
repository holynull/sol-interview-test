const SolTest = artifacts.require('SolTest')

contract('SolTest', async accounts => {
  let solTest
  const fee = 20 * 10 ** 9
  const [
    devAccount,
    ownerAccount,
    tempFactoryAddress,
    otherAccountOne,
    whiteListUserOne
  ] = accounts

  beforeEach(async () => {
    solTest = await SolTest.new(
      devAccount,
      fee,
      ownerAccount,
      tempFactoryAddress,
      { from: devAccount }
    )
  })

  it('should fetch owner.', async () => {
    const owner = await solTest.owner()
    assert.equal(owner, ownerAccount)
  })

  it('should add WhiteList.', async () => {
    await solTest.addWhiteList(whiteListUserOne, { from: ownerAccount })
    const isWhiteListed = await solTest.isWhiteListed(whiteListUserOne)
    assert.equal(isWhiteListed, true)
  })

  it('should remove WhiteList.', async () => {
    await solTest.removeWhiteList(whiteListUserOne, { from: ownerAccount })
    const isWhiteListed = await solTest.isWhiteListed(whiteListUserOne)
    assert.equal(isWhiteListed, false)
  })

  it('should require owner to add WhiteList.', async () => {
    try {
      await solTest.addWhiteList(whiteListUserOne, { from: otherAccountOne })
    } catch (e) {
      assert.include(e.message, 'Ownable: caller is not the owner')
    }
  })

  it('should require owner to remove WhiteList.', async () => {
    try {
      await solTest.removeWhiteList(whiteListUserOne, { from: otherAccountOne })
    } catch (e) {
      assert.include(e.message, 'Ownable: caller is not the owner')
    }
  })
})
