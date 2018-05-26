var SkilleX = artifacts.require("./SkilleX.sol");
var ERC721ComposableRegistry = artifacts.require("./ERC721ComposableRegistry.sol");

module.exports = function(deployer) {
  deployer.deploy(SkilleX, ERC721ComposableRegistry.address);
};
