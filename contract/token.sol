pragma solidity >=0.5.0 <0.6.0;

 contract  ERC20Basic {
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    function totalSupply() public view returns (uint256); 
    function balanceOf(address who) public view returns (uint256); 
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public  returns (bool) {} 
    function approve(address spender, uint256 value) public  returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
 
}

contract StandardToken is ERC20Basic{
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowed;
    uint256 public _totalSupply;

    function totalSupply()public view returns(uint256){
        return _totalSupply;
    }
    function balanceOf(address who) public view returns(uint256){
        return _balances[who];
    }

    function transfer(address to, uint256 value)public  returns (bool){
        require(_balances[msg.sender] >= value, "Insufficient balance");
       
        _balances[msg.sender] -= value;//r
        _balances[to] += value;  
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public  returns (bool) {
          
        require(_allowed[from][msg.sender]<=value, "You arent allowed to this amount");
        require(_balances[from] >= value, "Insufficient balance");
      
        _balances[from] -= value;//
        _balances[to] += value;  
        _allowed[from][msg.sender]-=value;
        return true;
    } 

    function approve(address spender, uint256 value) public  returns (bool){
        require(_allowed[msg.sender][spender] == 0, "You arent allowed to spnd");
        _allowed[msg.sender][spender] = value;
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256){
        return _allowed[owner][spender];
    }
    

}

contract MyToken is StandardToken {
    string public _name;
    string public _symbol;
    uint32 public _decimals;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _entreprises;
    uint256 public constant tauxEther = 100;
    uint256 public constant fraisVerification = 10;
    uint256 public constant fraisEvaluation = 15;

    constructor( )public{
        _name="BertToken";
        _symbol="BT";
        _decimals=0;
        _totalSupply=1000;
        _balances[msg.sender]=_totalSupply;
    }


}

