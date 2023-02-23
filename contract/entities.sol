pragma solidity >=0.5.0 <0.6.0;

import "./token.sol";

contract Entities {
        address private owner;
    address private token;

    struct Etablisement {
        string Nom_Etablisement;
        string Type;
        string Pays;
        string Adresse;
        string Site_Web;
        uint256 ID_Agent;
    }

    struct Diplome {
        bool exist;
        uint256 id_Titulaire;
        string Nom_Etablisement_Enseignement_Superieur;
        uint256 ID_EES;
        string Pays;
        string Type_Diplome;
        string Specialite;
        string Mention;
        uint256 Date_d_obtention;
    }

    struct Etudiant {
        bool exist;
        string Nom;
        string Prenom;
        string Date_de_naisance;
        string Sexe;
        string Nationalite;
        string Statut_civil;
        string Adresse;
        string Courriel;
        string Telephone;
        string Section;
        string Sujet_PFE;
        string Entreprise_Stage_PFE;
        string NomPrenom_MaitreDuStage;
        uint256 Date_debut_stage;
        uint256 Date_fin_stage;
        string Evaluation;
    }

    struct Entreprise {
        string Nom;
        string Secteur;
        uint256 Date_Creation;
        string Classification_Taille;
        string Pays;
        string Adresse;
        string Courriel;
        string telephone;
        string Site_Web;
    }

    mapping(uint256 => Etablisement) public Etablisements;
    mapping(address => uint256) AddressEtablisements;
    mapping(uint256 => Etudiant) Etudiants;
    mapping(uint256 => Entreprise) public Entreprises;
    mapping(address => uint256) public AddressEntreprises;
    mapping(uint256 => Diplome) public Diplomes;

    function get_Etudiants(uint256 id) public view returns (Etudiant memory) {
        return Etudiants[id];
    }

    uint256 public NbEtablisements;
    uint256 public NbEtudiants;
    uint256 public NbEntreprises;
    uint256 public NbDiplomes;

    constructor(address tokenaddress) public {
        token = tokenaddress;
        owner = msg.sender;

        NbEtablisements = 0;
        NbEtudiants = 0;
        NbEntreprises = 0;
        NbDiplomes = 0;
    }

    function ajouter_etablisement(Etablisement memory e, address a) private {
        NbEtablisements += 1;
        Etablisements[NbEtablisements] = e;
        AddressEtablisements[a] = NbEtablisements;
    }

    function ajouter_entreprise(Entreprise memory e, address a) private {
        NbEntreprises += 1;
        Entreprises[NbEntreprises] = e;
        AddressEntreprises[a] = NbEntreprises;
    }

    function ajouter_etudiant(Etudiant memory e) private {
        // etablisement
        e.exist = true;
        NbEtudiants += 1;
        Etudiants[NbEtudiants] = e;
    }

    function ajouter_diplome(Diplome memory d) private {
        d.exist = true;
        NbDiplomes += 1;
        Diplomes[NbDiplomes] = d;
    }

    //
    function ajouter_etablisement(string memory nom) public {
        Etablisement memory e;
        e.nom_etablisement = nom;
        ajouter_etablisement(e, msg.sender);
    }

    function ajouter_entreprise(string memory nom) public {
        Entreprise memory e;
        e.Nom = nom;
        ajouter_entreprise(e, msg.sender);
    }

    function ajouter_etudiant(string memory Nom, string memory Prenom) public {
        uint256 id = AddressEtablisements[msg.sender];
        require(id != 0, "not etablisement");
        Etudiant memory e;
        e.Nom = Nom;
        e.Prenom = Prenom;
        ajouter_etudiant(e);
    }

    function ajouter_diplome(uint256 id_titulaire) public {
        uint256 id = AddressEtablisements[msg.sender];
        require(id != 0, "not etablisement");
        require(Etudiants[id_titulaire].exist == true, "not Etudiants");
        Diplome memory d;
        d.id_titulaire = id_titulaire;
        d.nom_etablisement = Etablisements[id].nom_etablisement;
        ajouter_diplome(d);
    }

    function evaluer(
        uint256 etudiantid,
        string memory Sujet_pfe,
        string memory Entreprise_stage_pfe,
        string memory Maitre_stage,
        uint256 Date_debut_stage,
        uint256 Date_fin_stage,
        string memory Evaluation
    ) public {
        uint256 id = AddressEntreprises[msg.sender];
        require(id != 0, "no Entreprises");
        require(Etudiants[etudiantid].exist == true, "not Etudiants");
        Etudiants[etudiantid].Sujet_pfe = Sujet_pfe;
        Etudiants[etudiantid].Entreprise_stage_pfe = Entreprise_stage_pfe;
        Etudiants[etudiantid].Maitre_stage = Maitre_stage;
        Etudiants[etudiantid].Date_debut_stage = Date_debut_stage;
        Etudiants[etudiantid].Date_fin_stage = Date_fin_stage;
        Etudiants[etudiantid].Evaluation = Evaluation;
        require(
            Token(token).allowance(owner, address(this)) >= 15,
            "token not allowed"
        );
        require(
            Token(token).transferFrom(owner, msg.sender, 15),
            "transfert fail"
        );
    }

    event verifierresult(bool, Diplome);

    function verifier(uint256 diplomeid) public returns (bool, Diplome memory) {
        require(
            Token(token).allowance(msg.sender, address(this)) >= 10,
            "token not allowed"
        );
        require(
            Token(token).transferFrom(msg.sender, owner, 10), // token transfer
            "transfert fail"
        );
        emit verifierresult(Diplomes[diplomeid].exist, Diplomes[diplomeid]);
        return (Diplomes[diplomeid].exist, Diplomes[diplomeid]);
    }
}