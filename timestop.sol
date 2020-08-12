pragma solidity ^0.5.0;

contract Timestamp{
    uint start;
    uint stop;
    function reset() public{
        start = 0;
        stop = 0;
    }
    function start_time() public{
        start = now;
    }
    function stop_time() public{
        stop = now;
    }
    function get_timestamp() public view returns (uint){
        return (stop - start);
    }
    
}
