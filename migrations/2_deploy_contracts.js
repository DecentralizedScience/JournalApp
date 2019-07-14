/* global artifacts */
var JournalApp = artifacts.require('JournalApp.sol')

module.exports = function(deployer) {
  deployer.deploy(JournalApp)
}
