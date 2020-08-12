pragma solidity ^0.5.0;

contract FuncToken {
    
    uint public totalSupply;
//string public constant symbol = “FUNC”;
//string public constant name = “Func Token”;   
    address public initial_owner;
    mapping (address => uint256) private balances;

    mapping (address => mapping (address => uint256)) private allowances;

    // uint256 private totalSupply;              //How many decimals to show. 
 

    constructor(uint supplyStart) public {
         totalSupply = supplyStart;
         balances[msg.sender] = totalSupply;       // Give the creator all initial tokens
         initial_owner = msg.sender;
              }
    event Transfer(address _from, address _to, uint256 _value);
    event Approval(address _from,address _to, uint256 _value); 
    
     function transfer(address _to, uint256 _value) public returns (bool success) {
         require(balances[msg.sender] >= _value);
         balances[msg.sender] -= _value;
         balances[_to] += _value;
         emit Transfer(msg.sender, _to, _value);
         return true;
     }
 
     function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
         uint256 allowance = allowances[_from][msg.sender];
         require(balances[_from] >= _value && allowance >= _value);
         balances[_to] += _value;
         balances[_from] -= _value;
         if (allowance < 10000) {  //max_value allowed
             allowances[_from][msg.sender] -= _value;
         }
         emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
         return true;
     }
     
     function GivingSGP(address _to, uint256 _value) public returns (bool success){
         require(balances[initial_owner] >= _value, "Not enough tokens in circulation");
         balances[_to] += _value;
         balances[initial_owner] -= _value;
         emit Transfer(initial_owner, _to, _value);
         return true;
     }
 
     function AddingSupply(uint256 _value) public returns (bool success){
         balances[initial_owner] += _value;
         return true;
     }
 
     function balanceOf(address _owner) public view returns (uint256 balance) {
         return balances[_owner];
     }
 
     function approve(address _spender, uint256 _value) public returns (bool success) {
         allowances[msg.sender][_spender] = _value;
         emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
         return true;
     }
 
     function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
         return allowances[_owner][_spender];
     }
     
 }

// https://blog.eduonix.com/web-programming-tutorials/create-erc-20-token-ethereum-solidity/