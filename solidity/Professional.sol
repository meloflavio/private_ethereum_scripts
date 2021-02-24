pragma solidity >=0.4.22 <=0.8.1;

contract ProfessionalRegistry {
    Professional [] public registeredProfessionals;
    event ProfessionalCreated(address contractAddress);
    mapping(address => Professional []) registeredProfessionalsAddress;
    mapping(address => bool) professionalExists;
    //details
    mapping(string => string) lastDetails;
    string stringDetails;
    event lastDetailsCreated(string stringDetails);
    //details


    function createProfessional(address  _professionalAddress,  string memory _nome,  string memory _cpf, string memory _registry, string memory _email, string memory _telephone) public {
        require(!professionalExists[_professionalAddress], "Professional already exists.");
        Professional newProfessional = new Professional(msg.sender, _professionalAddress, _nome, _cpf, _registry, _email, _telephone);
        emit ProfessionalCreated(address(newProfessional));
        professionalExists[_professionalAddress] = true;

        //details
        lastDetails['nome'] = _nome;
        lastDetails['cpf'] = _cpf;
        lastDetails['registry'] = _registry;
        lastDetails['email'] = _email;
        lastDetails['telephone'] = _telephone;
        //details

        registeredProfessionalsAddress[_professionalAddress].push(newProfessional);
        registeredProfessionals.push(newProfessional);
    }
    //details
    function getLastDetails() public returns (string memory) {
        stringDetails = string(abi.encodePacked("Professional - Nome: ",lastDetails['nome'],", CPF: ",lastDetails['cpf'],", Registry: ",lastDetails['registry'],", Email: ",lastDetails['email'],", Telephone: ",lastDetails['telephone']));
        emit lastDetailsCreated(stringDetails);
        return stringDetails;
    }
    //details


    function getDeployedProfessionals() public view returns (Professional[] memory) {
        return registeredProfessionals;
    }

    function getDeployedProfessionalByAddress(address _professionalAddress) public view returns (Professional[] memory ) {
        return registeredProfessionalsAddress[_professionalAddress];
    }
}

contract Professional {

    // Owner address
    address public owner;

    /// Marriage Vows
    address public professionalAddress;
    string public nome;
    string public cpf;
    string public registry;
    string public email;
    string public telephone;
    /**
    * @dev Throws if called by any account other than the owner
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address _owner, address  _professionalAddress, string memory _nome, string memory _cpf, string memory _registry, string memory _email, string memory _telephone)  {
        owner = _owner;
        professionalAddress = _professionalAddress;
        nome = _nome;
        cpf = _cpf;
        registry = _registry;
        email = _email;
        telephone = _telephone;
    }

    function getProfessionalDetails() public view returns (
        address,  address , string memory, string memory, string memory, string memory, string memory) {
        return (
        owner,
        professionalAddress,
        nome,
        cpf,
        registry,
        email,
        telephone
        );
    }

    function setProfessionalDetails( string memory _nome,string memory _cpf, string memory _registry, string memory _email, string memory _telephone) public  {
        nome = _nome;
        cpf = _cpf;
        registry = _registry;
        email = _email;
        telephone = _telephone;
    }


}
