'use strict';

const assertJump = require('./helpers/assertJump');
var StandardTokenMock = artifacts.require('./helpers/StandardTokenMock.sol');
contract('StandardToken', function(accounts) {

    it('should return the correct totalSupply after construction', async function() {
        let token = await StandardTokenMock.new(accounts[0], 100);
        let totalSupply = await token.totalSupply();

        assert.equal(totalSupply, 100);
    });


    it('should return correct balances after transfer', async function() {
        let token = await StandardTokenMock.new(accounts[0], 100);
        await token.transfer(accounts[1], 100);
        let balance0 = await token.balanceOf(accounts[0]);
        assert.equal(balance0, 0);

        let balance1 = await token.balanceOf(accounts[1]);
        assert.equal(balance1, 100);
    });

    it('should return false when trying to transfer more than balance', async function() {
        let token = await StandardTokenMock.new(accounts[0], 100);
        let status = await token.transfer.call(accounts[1], 101);
        assert.equal(status, false);
    });

    it('should return correct balances after transfering from another account', async function() {
        let token = await StandardTokenMock.new(accounts[0], 100);
        await token.approve(accounts[1], 100);
        await token.transferFrom(accounts[0], accounts[2], 100, { from: accounts[1] });

        let balance0 = await token.balanceOf(accounts[0]);
        assert.equal(balance0, 0);

        let balance1 = await token.balanceOf(accounts[2]);
        assert.equal(balance1, 100);

        let balance2 = await token.balanceOf(accounts[1]);
        assert.equal(balance2, 0);
    });


});