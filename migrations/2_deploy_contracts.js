var Token = artifacts.require("./Token.sol");
var TokenSale = artifacts.require("./TokenSale.sol");

module.exports = function(deployer) {
    deployer.deploy(Token).then(function() {
    return deployer.deploy(TokenSale, Token.address, 1530000000, 2, 1530200000, 15);
  });
};
