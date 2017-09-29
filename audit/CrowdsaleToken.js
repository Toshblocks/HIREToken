'use strict';

const assertJump = require('./helpers/assertJump');
var Token = artifacts.require("./Token.sol");
contract('Token', function(accounts) {
    var _tokenInitialSupply = 100 ** 24;
    var _tokenName = 'HIRE Token';
    var _tokenDecimals = 18;
    var _tokenSymbol = 'HIRE';

    it('Creation: should return the correct totalSupply after construction', async function() {
        let instance = await Token.new({ from: accounts[0] });
        let totalSupply = await instance.totalSupply();

        assert.equal(totalSupply, _tokenInitialSupply);
    });

    it('Creation: should return the correct balance of admin after construction', async function() {
        let instance = await Token.new({ from: accounts[0] });
        let adminBalance = await instance.balanceOf.call(accounts[0]);

        assert.equal(adminBalance, _tokenInitialSupply);
    });

    it('Creation: sould return correct token meta information', async function() {
        let instance = await Token.new({ from: accounts[0] });

        let name = await instance.name.call();
        assert.strictEqual(name, _tokenName, "Name value is not as expected.");

        let decimal = await instance.decimals.call();
        assert.strictEqual(decimal.toNumber(), _tokenDecimals, "Decimals value is not as expected");

        let symbol = await instance.symbol.call();
        assert.strictEqual(symbol, _tokenSymbol, "Symbol value is not as expected");
    });

    it('Transfer: ether transfer to token address should fail.', async function() {
        let instance = await Token.new({ from: accounts[0] });
        try {
            await web3.eth.sendTransaction({ from: accounts[0], to: instance.address, value: web3.toWei("10", "Ether") });
        } catch (error) {
            return assertJump(error);
        }
        assert.fail('should have thrown exception before');
    });


    it('Transfer: should throw an error when trying to transfer more than balance', async function() {
        let instance = await Token.new({ from: accounts[0] });
        try {
            await instance.transfer(accounts[1], 101000000 * Math.pow(10, decimals));
        } catch (error) {
            return assertJump(error);
        }
        assert.fail('should have thrown before');
    });

    it('Transfer: should throw an error when trying to transfer 0 balance', async function() {
        let instance = await Token.new({ from: accounts[0] });
        try {
            await instance.transfer(accounts[1], 0);
        } catch (error) {
            return assertJump(error);
        }
        assert.fail('should have thrown before');
    });

    it('Transfer: should throw an error when trying to transfer to himself', async function() {
        let instance = await Token.new({ from: accounts[0] });
        try {
            await instance.transfer(accounts[0], 100000000 * Math.pow(10, decimals));
        } catch (error) {
            return assertJump(error);
        }
        assert.fail('should have thrown before');
    });



});