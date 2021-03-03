// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <=0.8.1;

contract Profissional {

    event showDetails(string stringDetails);
    string stringDetails;
    // Owner address
    address public owner;

    /// Marriage Vows
    address public profissionalAddress;
    string public nome;
    string public cpf;
    string public registroMedico;
    string public email;
    string public telefone;

    constructor()  {
        owner = msg.sender;
    }

    function getDetails() public {
        stringDetails = string(abi.encodePacked("Profissional - Nome: ",nome,", CPF: ",cpf,", Registro medico: ",registroMedico,", E-mail: ",email,", Telefone: ",telefone));
        emit showDetails(stringDetails);
    }

    function getProfissionalDetails() public view returns (
        address,  address , string memory, string memory, string memory, string memory, string memory) {
        return (
        owner,
        profissionalAddress,
        nome,
        cpf,
        registroMedico,
        email,
        telefone
        );
    }

    function setProfissionalDetails( address _profissionalAddress, string memory _nome,string memory _cpf, string memory _registroMedico, string memory _email, string memory _telefone) public  {
        profissionalAddress = _profissionalAddress;
        nome = _nome;
        cpf = _cpf;
        registroMedico = _registroMedico;
        email = _email;
        telefone = _telefone;
    }
}
