pragma solidity >=0.5.0 <0.6.2;

abstract contract ERC20Basic {
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    function totalSupply() public view virtual returns (uint256); 
    function balanceOf(address who) public view virtual returns (uint256); 
    function transfer(address to, uint256 value) public virtual returns (bool);
    function transferFrom(address from, address to, uint256 value) public virtual  returns (bool) {} 
    function approve(address spender, uint256 value) public virtual returns (bool);
    function allowance(address owner, address spender) public view virtual returns (uint256);
 
}

contract StandardToken is ERC20Basic{
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowed;
    uint256 public _totalSupply;

    event Transfer(address _addr, address _to, uint256 _value);
    event Approval(address _owner, address _spender, uint256 _value);

    function totalSupply()public view override returns(uint256){
        return _totalSupply;
    }
    function balanceOf(address who) public view override returns(uint256){
        return _balances[who];
    }

    function transfer(address to, uint256 value)public override returns (bool){
        require(_balances[msg.sender] >= value, "Insufficient balance");
       
        _balances[msg.sender] -= value;//r
        _balances[to] += value;  
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
          
        require(_allowed[from][msg.sender]<=value, "You arent allowed to this amount");
        require(_balances[from] >= value, "Insufficient balance");
      
        _balances[from] -= value;//
        _balances[to] += value;  
        _allowed[from][msg.sender]-=value;
        emit Transfer(from, to, value);
        return true;
    } 

    function approve(address spender, uint256 value) public override returns (bool){
        require(_allowed[msg.sender][spender] == 0, "You arent allowed to spnd");
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowed[owner][spender];
    }

}

contract MyToken is StandardToken {
    string public _name;
    string public _symbol;
    uint32 public _decimals;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _entreprises;
    uint256 public constant etherRate = 100;
    uint256 public constant verificationCosts = 10;
    uint256 public constant evaluationCosts = 15;

    constructor( )public{
        _name="schoolToken";
        _symbol="ST";
        _decimals=0;
        _totalSupply=1000;
        _balances[msg.sender]=_totalSupply;
    }
    
    function acheterTokens(uint256 nbToken) public payable {
        require(nbToken > 0, "Le montant envoyé doit être supérieur à 0");
        uint256 amount = nbToken * etherRate;
        require(amount <= _totalSupply - _balances[msg.sender], "La vente est terminée");
        _balances[msg.sender] += amount;
        _balances[address(this)] -= amount;
        emit Transfer(address(this), msg.sender, amount);
    }

    function payerVerification(uint256 amount) public returns (bool) {
        require(_balances[msg.sender] >= amount + verificationCosts, "Fonds insuffisants");
        _balances[msg.sender] -= amount + verificationCosts;
        _balances[address(this)] += amount + verificationCosts;
        emit Transfer(msg.sender, address(this), verificationCosts);
        emit Transfer(msg.sender, address(this), amount);
        return true;
    }

    function payerEvaluation(uint256 amount) public returns (bool) {
        require(_entreprises[msg.sender], "Seules les entreprises autorisées peuvent utiliser cette fonction");
        require(_balances[msg.sender] >= amount + evaluationCosts, "Fonds insuffisants");
        _balances[address(this)] += amount + evaluationCosts;
        emit Transfer(msg.sender, address(this), evaluationCosts);
        emit Transfer(msg.sender, address(this), amount);
        return true;
    }

}

