const solidityTestUtil = {
  evmIncreaseTime: (seconds) => new Promise((resolve, reject) =>
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [seconds],
      id: new Date().getTime()
    }, (error, result) => error ? reject(error) : resolve(result.result)))
};

var getTransactionReceiptMined = function (txnHash, interval) {
    var transactionReceiptAsync;
    interval |= 500;
    transactionReceiptAsync = function(txnHash, resolve, reject) {
        try {
            var receipt = web3.eth.getTransactionReceipt(txnHash);
            if (receipt == null) {
                setTimeout(function () {
                    transactionReceiptAsync(txnHash, resolve, reject);
                }, interval);
            } else {
                resolve(receipt);
            }
        } catch(e) {
            reject(e);
        }
    };

    return new Promise(function (resolve, reject) {
        transactionReceiptAsync(txnHash, resolve, reject);
    });
};

var HireIco = artifacts.require("./HireIco.sol");

contract('HireIco', function(accounts) {

  it("should not be halted when created", function(done) {
      HireIco.new(accounts[2], 1234, accounts[1], 8000 * Math.pow(10, 18), 8000 * Math.pow(10, 18), 120000 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      return instance.halted();
    }).then(function(isHalted) {
      assert.equal(isHalted, false, "should not be halted");
    }).then(done, done);
  });

  it("should be halted and then unhalted", function(done) {
      var hire;
      HireIco.new(accounts[0], 1234, accounts[1], 8000 * Math.pow(10, 18), 8000 * Math.pow(10, 18), 120000 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      hire = instance;
      return hire.haltFundraising({from: accounts[0]});
    }).then(function() {
      return hire.halted();
    }).then(function(isHalted) {
      assert.equal(isHalted, true, "should be halted");
      return hire.unhaltFundraising({from: accounts[0]});
    }).then(function() {
      return hire.halted();
    }).then(function(isHalted) {
      assert.equal(isHalted, false, "should be unhalted again");
    }).then(done, done);
  });

  it("should be properly created", function(done) {
    var hire;
    HireIco.new(accounts[2], 1234, accounts[1], 8000 * Math.pow(10, 18), 8000 * Math.pow(10, 18), 120000 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      hire = instance;
      return hire.totalSupply();
    }).then(function(totalSupply) {
      assert.equal(totalSupply, 0, "0 == totalSupply expected");
      return hire.paused();
    }).then(function(paused) {
      assert.equal(paused, true, "should be paused");
      return hire.preSaleStartTimestamp();
    }).then(function(preSaleStartTimestamp) {
      assert.equal(preSaleStartTimestamp, 1234, "preSaleStartTimestamp should be == 1234");
      return hire.preSaleEndTimestamp();
    }).then(function(preSaleEndTimestamp) {
      assert.equal(preSaleEndTimestamp, 1234 + (7 * 24 * 60 * 60), "preSaleEndTimestamp should == preSaleStartTimestamp + 7 days");
      return hire.wallet();
    }).then(function(wallet) {
      assert.equal(wallet, accounts[1], "incorrect wallet");
      return hire.owner();
    }).then(function(owner) {
      assert.equal(owner, accounts[2], "incorrect owner");
      return hire.totalRaised();
    }).then(function(totalRaised) {
      assert.equal(totalRaised, 0, "totalRaised should be zero");
    }).then(hire, done);
  });

  it("should handle setIcoDates properly", function(done) {
    var hire;
    HireIco.new(accounts[2], 1234, accounts[1], 8000 * Math.pow(10, 18), 8000 * Math.pow(10, 18), 120000 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      hire = instance;
      return hire.icoStartTimestamp();
    }).then(function(icoStartTimestamp) {
      assert.equal(icoStartTimestamp, 0, "0 == icoStartTimestamp expected");
      return hire.icoEndTimestamp();
    }).then(function(icoEndTimestamp) {
      assert.equal(icoEndTimestamp, 0, "0 == icoEndTimestamp expected");
      return hire.setIcoDates(1000000, 2000000, {from: accounts[2]});
    }).then(function() {
      return hire.icoStartTimestamp();
    }).then(function(icoStartTimestamp) {
      assert.equal(icoStartTimestamp, 1000000, "1000000 == icoStartTimestamp expected");
      return hire.icoEndTimestamp();
    }).then(function(icoEndTimestamp) {
      assert.equal(icoEndTimestamp, 2000000, "2000000 == icoEndTimestamp expected");
    }).then(done, done);
  });

  it("should convert 1 ETH to 1800 * 16% in PreSale", function(done) {
    var currentBlockTimeStamp = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    var hire;
    var walletInitBalance;

    HireIco.new(accounts[0], currentBlockTimeStamp - 90, accounts[5], 8000 * Math.pow(10, 18), 8000 * Math.pow(10, 18), 120000 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      walletInitBalance = web3.eth.getBalance(accounts[5]);
      hire = instance;
      return hire.sendTransaction({ from: accounts[1], value: web3.toWei(1, "ether") });
    }).then(function(result) {
      // check if Buy event was emited:
      assert.equal(result.logs.length, 1, "No event emited");
      assert.equal(result.logs[0].event, "Buy", "Buy event was not emited");
      return getTransactionReceiptMined(result.tx);
    }).then(function(result) {
      return hire.isPreSalePeriod();
    }).then(function(isPreSalePeriod) {
      assert.equal(isPreSalePeriod, true, "it should be preSale period now");
      return hire.balanceOf(accounts[1]);
    }).then(function(balanceOf) {
      assert.equal(balanceOf.toNumber(), parseInt(Math.pow(10, 18) * 450 * 1.16), "incorrect balance after investment with bonus");
      return hire.totalRaised();
    }).then(function(totalRaised) {
      assert.equal(totalRaised.toNumber(), Math.pow(10, 18), "incorrect totalRaised after investment with bonus");
      return hire.totalSupply();
    }).then(function(totalSupply) {
      assert.equal(totalSupply.toNumber(), parseInt(Math.pow(10, 18) * 450 * 1.16), "incorrect totalSupply after investment with bonus");
      var walletBalance = web3.eth.getBalance(accounts[5]);
      assert.equal(web3.eth.getBalance(hire.address), 0, "contract balance should be zero at all times");
      assert.equal(walletBalance.toNumber(), parseInt(Math.pow(10, 18)) + walletInitBalance.toNumber(), "wallet balance should have increased by 1 ETH");
    }).then(done, done);
  });
  
  it("should fail as preSale did not start yet", function(done) {
    var currentBlockTimeStamp = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    var hire;
    HireIco.new(accounts[0], currentBlockTimeStamp + 60*60, accounts[2], 8000 * Math.pow(10, 18), 8000 * Math.pow(10, 18), 120000 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      hire = instance;
      return hire.isPreSalePeriod();
    }).then(function(isPreSalePeriod) {
      assert.equal(isPreSalePeriod, false, "it should NOT be preSale period now (1)");
      return hire.sendTransaction({ from: accounts[1], value: web3.toWei(1, "ether") });
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('invalid opcode') >= 0, 'Expected throw, but got: ' + error);
    }).then(done, done);
  });

  it("should fail as preSale is over but ICO dates were not set yet", function(done) {
    var currentBlockTimeStamp = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    var hire;
    HireIco.new(accounts[0], currentBlockTimeStamp - 90, accounts[2], 8000 * Math.pow(10, 18), 8000 * Math.pow(10, 18), 120000 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      hire = instance;
      return solidityTestUtil.evmIncreaseTime(100 + 28 * 24 * 60 * 60);
    }).then(function() {
      return hire.sendTransaction({ from: accounts[1], value: web3.toWei(1, "ether") });
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('invalid opcode') >= 0, 'Expected throw, but got: ' + error);
    }).then(done, done);
  });

  it("should fail as it's halted", function(done) {
    var currentBlockTimeStamp = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    var hire;
    HireIco.new(accounts[0], currentBlockTimeStamp - 90, accounts[2], 8000 * Math.pow(10, 18), 8000 * Math.pow(10, 18), 120000 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      hire = instance;
      return hire.haltFundraising({from: accounts[0]});
    }).then(function() {
      return hire.sendTransaction({ from: accounts[1], value: web3.toWei(1, "ether") });
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('invalid opcode') >= 0, 'Expected throw, but got: ' + error);
    }).then(done, done);
  });

  it("should NOT fail as it's unhalted", function(done) {
    var currentBlockTimeStamp = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    var hire;
    HireIco.new(accounts[0], currentBlockTimeStamp - 90, accounts[2], 8000 * Math.pow(10, 18), 8000 * Math.pow(10, 18), 120000 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      hire = instance;
      return hire.unhaltFundraising({from: accounts[0]});
    }).then(function() {
      return hire.sendTransaction({ from: accounts[1], value: web3.toWei(1, "ether") });
    }).then(function(){}).catch(assert.fail).then(done, done);
  });

  it("should fail as it's zero ETH investment", function(done) {
    var currentBlockTimeStamp = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    var hire;
    HireIco.new(accounts[0], currentBlockTimeStamp - 90, accounts[2], 8000 * Math.pow(10, 18), 8000 * Math.pow(10, 18), 120000 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      hire = instance;
      return hire.sendTransaction({ from: accounts[1], value: 0 /*web3.toWei(0, "ether")*/ });
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('invalid opcode') >= 0, 'Expected throw, but got: ' + error);
    }).then(done, done);
  });

  it("should fail when target for PreSale is reached in PreSale phase", function(done) {
    var currentBlockTimeStamp = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    var hire;
    HireIco.new(accounts[0], currentBlockTimeStamp - 90, accounts[6], 2 * Math.pow(10, 18), 2 * Math.pow(10, 18), 2 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      hire = instance;
      return hire.sendTransaction({ from: accounts[1], value: web3.toWei(2, "ether") });
    }).then(function(result) {
      // check if Buy event was emited:
      assert.equal(result.logs.length, 1, "No event emited");
      assert.equal(result.logs[0].event, "Buy", "Buy event was not emited");
      // sending one more Ether:
      return hire.sendTransaction({ from: accounts[1], value: web3.toWei(1, "ether") });
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('invalid opcode') >= 0, 'Expected throw, but got: ' + error);
    }).then(done, done);
  });

  it("should fail when max target for ICO is reached in ICO phase", function(done) {
    var currentBlockTimeStamp = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    var hire;
    HireIco.new(accounts[0], currentBlockTimeStamp - 90, accounts[6], 2 * Math.pow(10, 18), 2 * Math.pow(10, 18), 3 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      hire = instance;
      // PreSale Phase:
      return hire.sendTransaction({ from: accounts[6], value: web3.toWei(1.5, "ether") });
    }).then(function(result) {
      assert.equal(result.logs.length, 1, "No event emited");
      assert.equal(result.logs[0].event, "Buy", "Buy event was not emited");
      assert.equal(result.logs[0].args.recipient, accounts[6], "Incorrect recipient");
      assert.equal(result.logs[0].args.weiAmount, parseInt(1.5 * Math.pow(10, 18)), "Incorrect number of weiAmount");
      assert.equal(result.logs[0].args.tokens, parseInt(Math.pow(10, 18) * 450 * 1.16 * 1.5), "Incorrect number of HIRE tokens");
      var icoStartTimeStamp = currentBlockTimeStamp + 28 * 24 * 60 * 60;
      var icoEndTimeStamp = icoStartTimeStamp + 1000;
      return hire.setIcoDates(icoStartTimeStamp, icoEndTimeStamp, {from: accounts[0]});
    }).then(function() {
      // Fastforward to ICO phase:
      return solidityTestUtil.evmIncreaseTime(100 + 28 * 24 * 60 * 60);
    }).then(function() {
      // sending 4 ETH, to exhaust max target (should still be fine):
      return hire.sendTransaction({ from: accounts[7], value: web3.toWei(4, "ether") });
    }).then(function(result) {
      assert.equal(result.logs.length, 1, "No event emited");
      assert.equal(result.logs[0].event, "Buy", "Buy event was not emited");
      assert.equal(result.logs[0].args.recipient, accounts[7], "Incorrect recipient");
      assert.equal(result.logs[0].args.weiAmount, 4 * Math.pow(10, 18), "Incorrect number of weiAmount");
      assert.equal(result.logs[0].args.tokens, 4 * 450 * Math.pow(10, 18), "Incorrect number of HIRE tokens");
      // sending 0.1 ETH more, should fail this time:
      return hire.sendTransaction({ from: accounts[5], value: web3.toWei(0.1, "ether") });
    }).then(assert.fail).catch(function(error) {
      assert(error.message.indexOf('invalid opcode') >= 0, 'Expected throw, but got: ' + error);
      return hire.totalSupply();
    }).then(function(totalSupply) {
      // divided by Math.pow(10, 5) to still be within JS int scope:
      assert.equal(totalSupply.div(Math.pow(10, 5)), parseInt(Math.pow(10, 13) * 450 * (1.16*1.5 + 4)), "Incorrect totalSupply");
      return hire.totalRaised();
    }).then(function(totalRaised) {
      assert.equal(totalRaised, (1.5 + 4) * Math.pow(10, 18), "Incorrect totalRaised");
    }).then(done, done);
  });

  it("should calculate proper bonuses in various days of the PreSale phase", function(done) {
    var currentBlockTimeStamp = web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    var hire;
    HireIco.new(accounts[0], currentBlockTimeStamp - 90, accounts[6], 200 * Math.pow(10, 18), 200 * Math.pow(10, 18), 300 * Math.pow(10, 18), {from: accounts[0]}).then(function(instance) {
      hire = instance;
      // PreSale Phase 1:
      return hire.sendTransaction({ from: accounts[1], value: web3.toWei(1, "ether") });
    }).then(function(result) {
      assert.equal(result.logs.length, 1, "No event emited");
      assert.equal(result.logs[0].event, "Buy", "Buy event was not emited");
      assert.equal(result.logs[0].args.recipient, accounts[1], "Incorrect recipient");
      assert.equal(result.logs[0].args.weiAmount, 1 * Math.pow(10, 18), "Incorrect number of weiAmount");
      assert.equal(result.logs[0].args.tokens, parseInt(Math.pow(10, 18) * 450 * 1.16 * 1), "Incorrect number of HIRE tokens");
      // Fastforward 2 moredays:
      return solidityTestUtil.evmIncreaseTime(7 * 24 * 60 * 60);
    }).then(function(result) {
      return hire.totalSupply();
    }).then(function(totalSupply) {
      // divided by Math.pow(10, 5) to still be within JS int scope:
      assert.equal(totalSupply.div(Math.pow(10, 5)), parseInt(Math.pow(10, 13) * 450 *
        (1.16)), "Incorrect totalSupply");
      return hire.totalRaised();
    }).then(function(totalRaised) {
      assert.equal(totalRaised, (6) * Math.pow(10, 18), "Incorrect totalRaised");
    }).then(done, done);
  });

});
