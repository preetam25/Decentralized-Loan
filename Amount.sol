pragma solidity ^0.5.0;

contract amt_repay{
    function comp_amt(uint timediff, uint principal, uint loanrate) public payable returns (uint amt){
        if (timediff < 1 minutes){
            return (principal+(loanrate*principal)/100);
        }
        else
        { uint num_minutes = timediff/(1 minutes);
            for (uint i = 0; i < num_minutes; i++) {
            principal = principal+(loanrate*principal)/100;
            }
            return principal;
        }    
    }
}