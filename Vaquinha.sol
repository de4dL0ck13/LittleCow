pragma solidity ^0.4.2;

contract Vaquinha {
    address manager;
    address icoContract;
    uint quota;                 //fixed amound each member has to send -- future upgrade: make it dynamic
    uint buyDate;
    uint amountRequired;        //minimum amount reuired to join the ICO
    uint numOfMembers = 0;
    
    mapping (uint => address) members;
    mapping (address => uint) invested;
    
    modifier isManager() {
        require(msg.sender == manager);
        _;
    }
    
    //how many days should the contract wait before buying tokens
    function Vaquinha (uint _amountRequired, uint _quota, address _icoContract, uint _daysToBuy) public {
        //set ownership
        manager = msg.sender;

        amountRequired = _amountRequired;
        quota = _quota;
        icoContract = _icoContract;
        buyDate = now + _daysToBuy * 1 days;
    }
    
    function getIcoContract() public view returns (address) {
        return icoContract;
    }
    
    function setIcoContract(address _contract) public isManager() {
        require(_contract != 0x0);
        icoContract = _contract;
    }
    
    function sendFunds() public payable {
        require(msg.value == quota); //one is only allowed to invest a fixed amount
        
        if (invested[msg.sender] == 0) { //new investor
            numOfMembers++;
            members[numOfMembers] = msg.sender;
        }
        
        invested[msg.sender] += msg.value;
    }
    
    function withdraw() public returns(bool) {
    }
}
