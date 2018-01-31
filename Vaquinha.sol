pragma solidity ^0.4.2;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Vaquinha {
    address manager;
    address icoContract;
    uint quota;                 //fixed amound each member has to send -- future upgrade: make it dynamic
    uint endDate;               //deadline of token-sale - ether returned to investors after this date
    uint amountRequired;        //minimum amount reuired to join the ICO
    uint numOfMembers = 0;
    //future upgrade: manager bonus & bonus to who runs function buyTokens
    
    mapping (uint => address) members;
    mapping (address => uint) invested;  //quantity of quotas an address has invested
    
    modifier isManager() {
        require(msg.sender == manager);
        _;
    }
    
    //how many days should the contract wait before buying tokens
    function Vaquinha (uint _amountRequired, 
                       uint _quota, 
                       address _icoContract, 
                       uint _daysToBuy) 
    public {
        require(_amountRequired > 0 && _quota > 0 && _daysToBuy > 0 && _icoContract != 0x0);
        
        manager = msg.sender; //set ownership

        amountRequired = _amountRequired;
        quota = _quota;
        icoContract = _icoContract;
        endDate = now + _daysToBuy * 1 days;
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
        
        invested[msg.sender]++;
    }
    
    function withdraw() public returns(bool) {
        uint amount = 0;

        if (invested[msg.sender] > 0) {
            amount = invested[msg.sender] * quota;
            assert(this.balance >= amount);
            
            invested[msg.sender] = 0;
            
            //remove from members list:
            //find member's ID. If it isn't the last ID, then move last one to 
            //this position and decrement total number of members
            for (uint id = 0; id <= numOfMembers; id++) {
                if (members[id] == msg.sender) {
                    break;
                }
            }
            
            if (id == numOfMembers) {
                members[id] = 0x0;
            } else {
                members[id] = members[numOfMembers];
            }
            
            numOfMembers--;
            
            msg.sender.transfer(amount);
            
            return true;
        }
        return false;
    }
    
    function buyTokens() public {
        require(icoContract != 0x0 && now >= endDate);
        
    }
    
    function getIcoTokens() public isManager {
        
    }
    
    function getMyTokens() public {
        
    }
    
    function refundMembers() private {
        uint amount;
        
        for(uint i; i <= numOfMembers; i++) {
            amount = invested[members[i]] * quota;
            if (amount > 0 && this.balance >= amount) {
                members[i].transfer(amount);
            }
        }
    }
    
    function endContract() public isManager {
        refundMembers();
        selfdestruct(manager); //bonus?
    }
}
