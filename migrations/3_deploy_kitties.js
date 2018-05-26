var KittyNFT = artifacts.require("./KittyNFT.sol");

module.exports = function(deployer) {
  deployer.deploy(KittyNFT);
};
