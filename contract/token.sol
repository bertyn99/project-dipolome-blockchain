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
        require(_balances[msg.sender] >= value, "Insufficient balance");// check if the balance of the sender is sufficent
       
        _balances[msg.sender] -= value;//r
        _balances[to] += value;  
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public  returns (bool) {
          
        require(_allowed[from][msg.sender]<=value, "You arent allowed to this amount");
        require(_balances[from] >= value, "Insufficient balance");// check if the balance of the sender is sufficent
      
        _balances[from] -= value;//
        _balances[to] += value;  
        _allowed[from][msg.sender]-=value;// reduce the amount the sender can use
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

    constructor( )public{
        _name="BertToken";
        _symbol="BT";
        _decimals=0;
        _totalSupply=1000;
        _balances[msg.sender]=_totalSupply;
    }

    // Fonction pour acheter des tokens avec de l'Ether
    function acheterTokens() public payable {
        require(msg.value > 0, "Le montant envoyé doit être supérieur à 0");
        uint256 montant = msg.value * tauxEther;
        require(montant <= _totalSupply - _balances[msg.sender], "La vente est terminée");
        _balances[msg.sender] += montant;
        _balances[address(this)] -= montant;
        emit Transfer(address(this), msg.sender, montant);
    }

    // Fonction pour payer les frais de vérification
    function payerVerification(uint256 montant) public returns (bool) {
        require(_balances[msg.sender] >= montant + fraisVerification, "Fonds insuffisants");
        _balances[msg.sender] -= montant + fraisVerification;
        _balances[address(this)] += montant + fraisVerification;
        emit Transfer(msg.sender, address(this), fraisVerification);
        emit Transfer(msg.sender, address(this), montant);
        return true;
    }

    // Fonction pour payer les frais d'évaluation
    function payerEvaluation(uint256 montant) public returns (bool) {
        require(_entreprises[msg.sender], "Seules les entreprises autorisées peuvent utiliser cette fonction");
        require(_balances[msg.sender] >= montant + fraisEvaluation, "Fonds insuffisants");
        _balances[address(this)] += montant + fraisEvaluation;
        emit Transfer(msg.sender, address(this), fraisEvaluation);
        emit Transfer(msg.sender, address(this), montant);
        return true;
    }

    // Fonction pour autoriser une entreprise à utiliser la fonction payerEvaluation
    function autoriserEntreprise(address entreprise) public {
        require(msg.sender == owner, "Seul le propriétaire du contrat peut utiliser cette fonction");
        _entreprises[entreprise] = true;
    }

    // Fonction pour révoquer l'autorisation d'une entreprise à utiliser la fonction payerEvaluation
    function rejeterEntreprise(address entreprise) public {
        require(msg.sender == owner, "Seul le propriétaire du contrat peut utiliser cette fonction");
        _entreprises[entreprise] = false;
    }


}

