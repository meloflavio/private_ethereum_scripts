pragma solidity >=0.4.22 <=0.8.1;


contract Professional {


    event showDetails(string stringDetails);
    string stringDetails;

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

    constructor()  {
        owner = msg.sender;
    }

    function getDetails() public {
        stringDetails = string(abi.encodePacked("Professional - Nome: ",nome,", CPF: ",cpf,", Registry: ",registry,", Email: ",email,", Telephone: ",telephone));
        emit showDetails(stringDetails);
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

    function setProfessionalDetails( address _professionalAddress, string memory _nome,string memory _cpf, string memory _registry, string memory _email, string memory _telephone) public  {
        professionalAddress = _professionalAddress;
        nome = _nome;
        cpf = _cpf;
        registry = _registry;
        email = _email;
        telephone = _telephone;
    }


}
