// Human token smart contract.
// Developed by Phenom.Team <info@phenom.team>
pragma solidity ^0.4.18;

/**
 *   @title SafeMath
 *   @dev Math operations with safety checks that throw on error
 */

library SafeMath {

    function mul(uint a, uint b) internal constant returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint a, uint b) internal constant returns(uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal constant returns(uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal constant returns(uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 *   @title ERC20
 *   @dev Standart ERC20 token interface
 */

contract ERC20 {
    
    mapping(address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;

    function totalSupply() public constant returns (uint);
    function balanceOf(address _owner) constant returns (uint);
    function transfer(address _to, uint _value) returns (bool);
    function transferFrom(address _from, address _to, uint _value) returns (bool);
    function approve(address _spender, uint _value) returns (bool);
    function allowance(address _owner, address _spender) constant returns (uint);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

}


contract HumanToken is ERC20 {
    using SafeMath for uint;
    string public name = "Human";
    string public symbol = "Human";
    uint public decimals = 18;
    uint private _totalSupply; 
    // Owner address
    address public owner;
     
    // Allows execution by the contract owner only
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    event Burn(address indexed _from, uint amount);

   /**
    *   @dev Contract constructor function sets owner address and inits total supply
    *   @param _owner        owner address
    */
    function HumanToken(address _owner) public {
       owner = _owner;
       _totalSupply = 46000000*1e18;
       balances[owner] = _totalSupply;
       Transfer(address(0), owner, _totalSupply);
    }

   /**
    *   @dev Burns a specific amount of tokens
    *   @param _amount       the number of tokens to be burned
    */
    function burn(uint _amount) public {
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[address(0)] = balances[address(0)].add(_amount);
        Burn(msg.sender, _amount);
        Transfer(msg.sender, address(0), _amount);
    }

    /**
    * Get Total Supply
    */
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

   /**
    *   @dev Get balance of tokens holder
    *   @param _holder        holder's address
    *   @return               balance of investor
    */
    function balanceOf(address _holder) constant returns (uint) {
         return balances[_holder];
    }

   /**
    *   @dev Send coins
    *   throws on any error rather then return a false flag to minimize
    *   user errors
    *   @param _to           target address
    *   @param _amount       transfer amount
    *
    *   @return true if the transfer was successful
    */
    function transfer(address _to, uint _amount) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

   /**
    *   @dev An account/contract attempts to get the coins
    *   throws on any error rather then return a false flag to minimize user errors
    *
    *   @param _from         source address
    *   @param _to           target address
    *   @param _amount       transfer amount
    *
    *   @return true if the transfer was successful
    */
    function transferFrom(address _from, address _to, uint _amount) public returns (bool) {
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
     }


   /**
    *   @dev Allows another account/contract to spend some tokens on its behalf
    *   throws on any error rather then return a false flag to minimize user errors
    *
    *   also, to minimize the risk of the approve/transferFrom attack vector
    *   approve has to be called twice in 2 separate transactions - once to
    *   change the allowance to 0 and secondly to change it to the new allowance
    *   value
    *
    *   @param _spender      approved address
    *   @param _amount       allowance amount
    *
    *   @return true if the approval was successful
    */
    function approve(address _spender, uint _amount) public returns (bool) {
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

   /**
    *   @dev Function to check the amount of tokens that an owner allowed to a spender.
    *
    *   @param _owner        the address which owns the funds
    *   @param _spender      the address which will spend the funds
    *
    *   @return              the amount of tokens still avaible for the spender
    */
    function allowance(address _owner, address _spender) constant returns (uint) {
        return allowed[_owner][_spender];
    }

    /** 
    *   @dev Allows owner to transfer out any accidentally sent ERC20 tokens
    *
    *   @param tokenAddress  token address
    *   @param tokens        transfer amount
    *
    *
    */
    function transferAnyTokens(address tokenAddress, uint tokens) 
        public
        onlyOwner 
        returns (bool success) {
        return ERC20(tokenAddress).transfer(owner, tokens);
    }
}