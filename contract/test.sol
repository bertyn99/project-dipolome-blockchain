pragma solidity ^0.8.0;

// Interface du token ERC20 standard
interface ERC20Basic {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    // Ajout de fonctions personnalisées
    function acheterTokens() external payable;
    function payerVerification(uint256 montant) external returns (bool);
    function payerEvaluation(uint256 montant) external returns (bool);
}

// Implémentation du contrat
contract MonToken is ERC20Basic {
    string public constant name = "Mon Token";
    string public constant symbol = "MTK";
    uint8 public constant decimals = 18;
    uint256 private constant _totalSupply = 1000000 * (10 ** uint256(decimals)); // total supply de 1 million de tokens
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _entreprises; // Mapping des adresses des entreprises autorisées
    uint256 public constant tauxEther = 100; // 1 ether = 100 jetons
    uint256 public constant fraisVerification = 10; // 10 jetons par vérification
    uint256 public constant fraisEvaluation = 15; // 15 jetons par évaluation
    
    // Constructeur, crée tous les tokens et attribue le total supply à l'adresse du créateur
    constructor() {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    // Fonction qui renvoie le total supply de tokens
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    // Fonction qui renvoie le solde de tokens d'une adresse donnée
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    // Fonction de transfert de tokens d'une adresse à une autre
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    // Fonction qui renvoie le montant de tokens qu'une adresse donnée est autorisée à dépenser pour une autre adresse
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    // Fonction d'autorisation de dépense de tokens par une adresse tierce
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
// Fonction pour transférer des tokens depuis un compte autorisé
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "Fonds insuffisants ou autorisation insuffisante");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
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

    // Evénement pour notifier les transferts de tokens
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Evénement pour notifier les approbations de comptes autorisés à dépenser des tokens depuis un compte donné
    event Approval(address indexed owner, address indexed spender, uint256 value);
}