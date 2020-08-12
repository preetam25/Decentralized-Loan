pragma solidity ^0.5.0;

contract collateral{
    function score(uint loan_amt, uint num_trans, uint deposit, uint total_deposits) public pure returns (uint){
        uint score_val = 2**(deposit/total_deposits) + num_trans/2;
        if (score_val > 4)
         return loan_amt/3;
        else
        return (loan_amt*3)/(2*score_val);
    }
   
   
}