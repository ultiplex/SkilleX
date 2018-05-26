var WithdraweX = artifacts.require("./WithdraweX.sol");
var ERC721ComposableRegistry = artifacts.require("./ERC721ComposableRegistry.sol");

module.exports = function(deployer) {
  deployer.deploy(WithdraweX, ERC721ComposableRegistry.address);
};
