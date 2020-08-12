pragma solidity ^0.5.0;

import "./erc20.sol";
import "./timestamp.sol";
import "./Amount.sol";
import "./creditscore.sol";

contract FiatContract {
  function ETH(uint _id) public pure returns (uint256);
  function USD(uint _id) public pure returns (uint256);
  function EUR(uint _id) public pure returns (uint256);
  function GBP(uint _id) public pure returns (uint256);
  function updatedAt(uint _id) public pure returns (uint);
}

contract SideChannelAttack {
    
    
    FiatContract public price;
    amt_repay the_amount_balance;
    collateral coll_check;
    FuncToken SGP = new FuncToken(1000000);
    uint interest_rate_lending;
    uint interest_rate_borrow;
    uint premium;
    uint etherium_amount;
    
    function GetConversion() public{
        price = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591);
    }
    
    function eth_to_USD(uint amount_in_ether) public returns (uint){
        GetConversion();
        uint small_amt_in_usd = price.USD(0);
        return (amount_in_ether/(100*small_amt_in_usd));
    }
    
    function USD_to_eth(uint amount_in_USD) public returns (uint){
        GetConversion();
        uint small_amt_in_usd = price.USD(0);
        return (amount_in_USD*100/small_amt_in_usd);
    }

    mapping (address => bool) user_exists;
    mapping (address => Timestamp) user_accumulate;
    mapping (address => Timestamp) loan_accumulate;
    mapping (address => uint) user_loan;
    mapping (address => uint) user_money;
    mapping (address => uint) num_trans;
    mapping (address => uint) hold_collateral;
   
    constructor() public{
        etherium_amount = 0;
        premium = 33;
        interest_rate_lending = 8;
        interest_rate_borrow = 10;
    }
    
    function add_user(uint amount_in_ether) public returns (bool success) {
        
        uint amount_in_dollars = eth_to_USD(amount_in_ether);
        uint amount_to_give = (100-premium)*amount_in_dollars/100;
        bool check_if_works = SGP.GivingSGP(msg.sender, amount_to_give);
        if(check_if_works == false) return false;
        
        user_money[msg.sender] = amount_in_dollars;
        user_loan[msg.sender] = 0;
        user_accumulate[msg.sender] = new Timestamp();
        loan_accumulate[msg.sender] = new Timestamp();
        user_accumulate[msg.sender].start_time();
        user_exists[msg.sender] = true;
        etherium_amount += amount_in_ether;
        
        return true;
    }
    
    function get_balance() public returns (bool success, uint money_account_in_ether, uint loan_to_give) {
        
        require(user_exists[msg.sender] == true, "User does not exist");
        
        user_accumulate[msg.sender].stop_time();
        uint money_added = the_amount_balance.comp_amt(user_accumulate[msg.sender].get_timestamp(), user_money[msg.sender], interest_rate_lending);
        user_money[msg.sender] += money_added;
        user_accumulate[msg.sender].reset();
        
        loan_accumulate[msg.sender].stop_time();
        if(loan_accumulate[msg.sender].get_timestamp() > 1 days){
            
            SGP.AddingSupply(hold_collateral[msg.sender]);
            hold_collateral[msg.sender] = 0;
            user_loan[msg.sender] = 0;
            num_trans[msg.sender] -= 2;
            if(num_trans[msg.sender]<0) num_trans[msg.sender] = 0;
            return (false, USD_to_eth(user_money[msg.sender]), USD_to_eth(user_loan[msg.sender]));
            
        }
        uint loan_added = the_amount_balance.comp_amt(loan_accumulate[msg.sender].get_timestamp(), user_loan[msg.sender], interest_rate_borrow);
        user_loan[msg.sender] += loan_added;
        loan_accumulate[msg.sender].reset();
        
        
        // if(user_money[msg.sender] < transaction_value[msg.sender]){
        //     SGP.AddingSupply(user_money[msg.sender]);
        //     user_money[msg.sender] = 0;
        //     user_loan[msg.sender] = 0;
        //     num_trans[msg.sender] -= 2;
        //     if(num_trans[msg.sender]<0) num_trans[msg.sender] = 0;
        //     return (false, USD_to_eth(user_money[msg.sender]), USD_to_eth(user_loan[msg.sender]));
        // }
        
        user_accumulate[msg.sender].start_time();
        if(user_loan[msg.sender]>0) loan_accumulate[msg.sender].start_time();
        
        return (true, USD_to_eth(user_money[msg.sender]), USD_to_eth(user_loan[msg.sender]));
    }
    
    function add_money(uint amount_in_ether) public returns (bool success){
        
        uint amount_in_dollars = eth_to_USD(amount_in_ether);
        uint amount_to_give = (100-premium)*amount_in_dollars/100;
        
        get_balance();
    
        bool check_if_works = SGP.GivingSGP(msg.sender, amount_to_give);
        if(check_if_works == false) return false;
        etherium_amount += amount_in_ether;
        user_money[msg.sender] += amount_in_ether;
        
        return true;
        
    }
    
    
    function remove_money(uint amount_in_SGP) public returns (bool success) {
        require(amount_in_SGP + ((100)*user_money[msg.sender]/(100-premium)) >= user_loan[msg.sender], "Either no balance or pending loans do not allow you to borrow money.");
        get_balance();
        uint amount_in_dollars = 100*amount_in_SGP/(100-premium);
        uint val_in_eth = USD_to_eth(amount_in_dollars);
        require(etherium_amount>=val_in_eth, "Not enough etherium in system");
        
        user_money[msg.sender] -= amount_in_dollars;
        etherium_amount -= val_in_eth;
        
        return true;
        
    }
    
    function borrow_money(uint amount_in_ether) public returns (bool success) {
        
        uint amount_in_dollars = eth_to_USD(amount_in_ether);
        uint deposit_needed = coll_check.score(amount_in_dollars, num_trans[msg.sender], user_money[msg.sender], 1000000);    
        require(user_money[msg.sender] >= deposit_needed, "Not enough money deposited to make this transaction");
        require(user_loan[msg.sender] == 0, "A loan is already pending!");
        require(etherium_amount >= amount_in_ether, "Not enough etherium in the system");
        user_loan[msg.sender] += amount_in_dollars;
        hold_collateral[msg.sender] = deposit_needed;
        user_money[msg.sender] -= deposit_needed;
        loan_accumulate[msg.sender].start_time();
        
        return true;
        
    }
    
    function return_money(uint amount_in_ether) public returns (bool success) {
        
        get_balance();
        uint amount_in_dollars  = eth_to_USD(amount_in_ether);
        require(amount_in_dollars >= user_loan[msg.sender], "Not enough to pay back loan");
        loan_accumulate[msg.sender].stop_time();
        loan_accumulate[msg.sender].reset();
        uint paid_back = amount_in_dollars;
        if(user_loan[msg.sender]<paid_back) paid_back = user_loan[msg.sender];
        num_trans[msg.sender]++;
        user_loan[msg.sender] += amount_in_dollars;
        etherium_amount += amount_in_ether;
        user_money[msg.sender] += hold_collateral[msg.sender];
        hold_collateral[msg.sender] = 0;
        
        return true;
    }
    
}

