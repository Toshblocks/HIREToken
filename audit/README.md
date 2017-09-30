# HireMatch Crowdsale Contract Audit

Status: Work in progress

Commits [eeb0b74](https://github.com/MLG-Blockchain/HIREToken/commit/eeb0b74cfe4291f190725cd8340a8ab66df0a8f8)

<br />

### SafeMath Contract

mul, div, sub, add functions should be defined as constants

<br />

### BasicToken Contract

* **CRITICAL** - In `transfer(...)` function, there should be a check that transaction sender has minimum `_value` balance and `_value` is not zero.

* **CRITICAL** - In `transfer(...)` function, amount is not being deducted from sender's balance! This allows any one to transfer any amount without ever reducing their own balance.

* **LOW IMPORTANCE** - In `tranferFrom(...)` function is not being used and should be removed.

* **LOW IMPORTANCE** - `totalSupply` function name and signature should strictly match with `function totalSupply() constant returns (uint totalSupply)` else token will not be ERC20 compliant.

<br />

### StandardToken Contract
* **LOW IMPORTANCE** - `transferFrom` function name and signature should strictly match with `function transferFrom(address _from, address _to, uint _value) returns (bool success)` else token will not be ERC20 compliant.

* **HIGH IMPORTANCE** - In `transferFrom` function 
      `balances[_from] = balances[_from].sub(_value);`
      `balances[_to] = balances[_to].add(_value);`
      `allowed[_from][msg.sender] = _allowance.sub(_value);`

  Allowance subtraction should be made before addition to prevent a **re-entrancy attack**. We recommend re-ordering these lines.

* **MEDIUM IMPORTANCE** - In `transferFrom` function, there should be a check that `_value` is not zero.

* **LOW IMPORTANCE** - `approve` function name and signature should strictly match with `function approve(address _spender, uint _value) returns (bool success)` else token will not be ERC20 compliant.

* **LOW IMPORTANCE** - `allowance` function name and signature should strictly match with `function allowance(address _owner, address _spender) constant returns (uint remaining)` else token will not be ERC20 compliant.


<br />

### Token Contract
* **LOW IMPORTANCE** - In `Token` constructor magic numbers are used. Define a constant or take as argument. Also, value is incorrect.

<br />

### TokenSale Contract
* **LOW IMPORTANCE** - In `Token` constructor magic numbers are used. Define a constant or take as argument.

* **LOW IMPORTANCE** - Functions which are not modifying Blockchain state should have **constant** modifier like `getTokenAddress`.

* **LOW IMPORTANCE** - Does `icoTokenRaised` denotes all tokens distributed during Presale and ICO? If not, in `isPreSalePeriod` function, this should be removed - `icoTokenRaised = presaleTokenRaised`.

* **LOW IMPORTANCE** - Function `isPreSalePeriod` is marked as **constant** even though it is modifying variables.

* **LOW IMPORTANCE** - Function `startICO` should return true/false.

* **MEDIUM IMPORTANCE** - In `calculateTokens` function, ` require(remainingTokens >= 0)` should be ` require(remainingTokens > 0)`. Remaining tokens should be greater than 0.

* **MEDIUM IMPORTANCE** -Investors investing more than 1000 Ethers should recieve 20% bonus. Is this bonus for PreSale period only? If no, modify `calculateTokens` function.

* **MEDIUM IMPORTANCE** - In `calculateTokens` function, there is no `return` statement.

* **CRITICAL IMPORTANCE** - In `buyTokens` function, this statement `token.transfer(_recipient, _value)` will not work after `transfer(...)` function is fixed as mentioned in **BasicToken Contract** section.

* **CRITICAL IMPORTANCE** - Once ICO starts, there is no way its state will change from *PreSale* to something else. This is because `isCrowdSaleStatePreSale` and `isCrowdSaleStateICO` are not checking if state has changed or they should be avoided and only `isPreSalePeriod` and `isICOPeriod` should be used. It is Recommended that all state changes are thoroughly checked.


<br />
