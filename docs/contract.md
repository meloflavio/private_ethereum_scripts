# Contract.sh (Opcional)
Esse script foi desenvolvido com o objetivo de demostrar o funcionamento de um contrato inteligente com a rede blockchain privada da plataforma Ethereum criada com esta ferramenta.

Como nos arquivos principais o script contém alguns parâmetros:
1. GETHPATH, esse deve informar o a localização da ferramenta geth, pode ser deixada em branco se o esquema de arquivos dessa ferramenta não for alterado.
1. VERSIONGETH, esse parâmetro deve ser o mesmo que o utilizado nos scripts para criação da rede.
1. SOLCVERSION, define a versão do compilador da linguagem solidity. Padrão: 'v0.8.1'
1. CONTRACT, define o arquivo do contrato inteligente a ser compilado. Padrão: Professional.sol

Para executar este script e compilar o contrato inteligente digite no terminal dentro da pasta solidity do projeto:

````shell script 
./contract.sh                       #Compila e prepara o contrato para ser utilizado na rede blockchain
````
Este script primeiramente verefica o sistema operacional para montar a url do compilador de contratos solidity e dá permissão de execução a este arquivo após o download ser concluido.

Após o download o contrato é compilado gerando dois arquivos, uma abi e outro bin.

Para utilizá-los dentro da blockchain, estes precisaram ser transformados em variáveis javascripts. Dessa forma, o script pega o conteudo destes arquivos compilados e cria variáveis javascript que podem ser importadas no console da ferramenta geth.

Caso os parâmetros da ferramenta geth estejam corretos o console é iniciado, caso contrário utilize a ferramenta geth do seu computador para acessar o console atráves do comando:

````shell script 
./PATH_GETH/geth attach http://localhost:8545                       #Concecta-se com o servidor RPC do geth e abre um console de comandos, o serivor localhos:8545 é o valor padrão
````

Dentro no console digite a seguinte sequencia de comandos;

Comandos dentro do geth 
1. Carregar os arquivos compilados da api
````
loadScript('ProfessionalAbi.js')

loadScript('ProfessionalBin.js')
````
2. Criar variáveis com o conteudo dos contratos compilados
````
var comp = "0x" + ProfessionalBin

var abi = ProfessionalAbi
````
3. Definir valor de gas necessário para o deploy do contrato e a conta padrão para realizar as transações
````
eth.defaultAccount = eth.coinbase
var gas = eth.estimateGas({from: eth.coinbase, data: comp})

````
4. Utilizar a função contract para criar um objeto javascript com a interface de uma contrato da plataforma Ethereum.
````
var factory =  eth.contract(abi) 
#Isso permite que você interaja com contratos inteligentes como se fossem objetos JavaScript.
````
5. Criamos uma nova instância do contrato e o enviamos para mineração.
````
var professionalContract = factory.new({data: comp, gas: gas}, function(e, contract) {
    if(!e) {
      if(!contract.address) {
        console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");

      } else {
        console.log("Contract mined! Address: " + contract.address);
        instance = web3.eth.contract(abi).at(contract.address);
        console.log("Current val: " + instance.get.call());

        gas = instance.set.estimateGas()
        console.log("Gas: " + gas);
        instance.set.call({gas: gas}, function(error, result) {

          console.log("RESULT: " + result);
          console.log("ERROR: " + error);
          console.log("Current ---" + instance.get.call());

          if(!error) {
              console.log("RESULT ---" + result);
          } else {
              console.log("ERROR ----" + error);
          }
        });


      }
    } else {
      console.log(e);
    }
});
````
Neste momento devemos aguardar o término da mineração e a mensagem que informa o endereço em que o contrato foi registrado.
````
Contract mined! Address: 0x0000000000000000 #Exemplo de retorno
````
Com a confirmação da mineração podemos utilizar a variavel contrato em que gardamos a referencia do smart contract para interagir com ele.
Assim, podemos executar o metodo setProfessionalDetails:
````
professionalContract.setProfessionalDetails(eth.accounts[0],"Profissional 1","00000000000","123CRMTO","professional@gmail.com","63 99999-9999")
````
Esse método não retorna nenhuma informação e mesmo que chamemos o metodo getProfessionalDetails, não será retornado nada na tela. Isso ocorre, porque não é possível obter o valor de retorno de uma função, devemos criar os eventos relevantes no contrato inteligente para que retornem os valores que queremos.

Nosso contrato de exemplo temos então o seguinte evento "showDetails" responsável por nos entregar as informações do contato quando executado o método "getDetails".


````solidity
contract Professional {


    event showDetails(string stringDetails);

    function getDetails() public {
        stringDetails = string(abi.encodePacked("Professional - Nome: ",nome,", CPF: ",cpf,", Registry: ",registry,", Email: ",email,", Telephone: ",telephone));
        emit showDetails(stringDetails);
    }
    
````

Executando o método "getDetails" gardamos o hash da transação em uma variável : 
````
transactionHash = professionalContract.getDetails()
````

E para vizualisarmos o retorno do evento precisamos acessar as informações da transação.

````
eth.getTransactionReceipt(transactionHash).logs[0].data
````
A informação retornada está codificada conforme a especificação ABI do contrato, muitas das API's ao serem utilizadas já fazem a decodificação como não estamos utilizando nenhuma API com essa função para decodificarmos facilmente a informação podemos entrar na pagina:
https://adibas03.github.io/online-ethereum-abi-encoder-decoder/#/decode. E colarmos o retorno do ultimo comando indicando que o que está codificado é uma string. Veremos assim o resultado:

````
Professional - Nome: Profissional 1, CPF: 00000000000, Registry: 123CRMTO, Email: professional@gmail.com, Telephone: 63 99999-9999
````