# Scripts para automação da criação e configuração de uma rede Privada da Ethereum Blockchain
Este projeto contem scripts para a criação e configuração de uma rede blockchain privada utilizando a plataforma Ethereum. Pode ser utilizado nos sistemas operacionais Linux, MacOs e Windows, para este último primeiramente instale ou git através da url https://git-scm.com/download/win ou caso utilize o windows 10 o mais indicado seria ativar o Subsistema do Windows para Linux (WSL) seguindo as instruções oficias em https://docs.microsoft.com/pt-br/windows/wsl/install-win10.

Os principais componentes do projeto são:
1. genesis.json
1. start.sh
1. password.txt
1. private.txt

Estes arquivos estão pre configurados para o funcionamento de uma rede privada com 2 carteiras pré financiadas e servidor HTTP-RPC ativado. Para utilizar o script sigua os passos.

OBS: Para um tutorial em vídeo acesse: https://youtu.be/x76MluZ_cAQ
OBS: [Para um tutorial de interação com os _smart contracts](docs/contract.md)
# Alterar Genesis.json (Opcional)
Para iniciar uma nova cadeia precisamos definir o bloco inicial com algumas configurações que indicaram como novos blocos serão inseridos, dentre estas definições destacamos:
1. “config”: a configuração da blockchain.
1. “chainId”: identificador utilizado na proteção contra ataque de repetição. Por exemplo, se uma ação é validada combinando certo valor que depende do ID da cadeia, os atacantes não podem obter facilmente o mesmo valor com um ID diferente.
1. “coinbase”: é um endereço onde todas as recompensas coletadas com a validação de bloco bem-sucedida serão transferidas. Uma recompensa é uma soma da recompensa de mineração e dos reembolsos da execução de transações de contrato. Como é um bloco de gênese, o valor desse bloco pode ser qualquer coisa. Para todos os próximos blocos, o valor será um endereço definido pelo mineiro que validou esse bloco.
1. "difficulty": dificuldade de mineração, para desenvolvimento e testes defina esse valor baixo para que você não precise esperar muito pelos blocos de mineração.
1. “gasLimit”: o limite do custo do gás por bloco.
1. “nonce” -  O nonce é o número de transações enviadas de um determinado endereço. É usado em combinação com mixhash para provar que uma quantidade suficiente de computação foi realizada neste bloco.
1. “mixHash” - Um hash de 256 bits que, combinado com o nonce , prova que uma quantidade suficiente de computação foi realizada no bloco. A combinação de nonce e mixhash deve satisfazer uma condição matemática.
1. “parentHash” - O hash do cabeçalho do bloco pai. Isso é meio que um ponteiro para o bloco pai necessário para formar uma cadeia real de blocos. Um bloco de gênese não possui um bloco pai, portanto, o resultado será apenas neste caso igual a 0.
1. “alloc”: esse parâmetro é usado para pré-financiar alguns endereços com ether. Ele contém dois parâmetros, o endereço que deve ser um hash de 160 bits e o número de ether com o qual uma conta deve ser financiada. 

A seguir temos o arquivo genesis funcional com duas contas já pré-financiadas para não ser necessário criar uma conta manualmente e colocá-la para minerar a fim de ter fundos para realizar transações.
````json
{
  "config": {
    "chainId": 1288,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "ethash": {}
  },
  "nonce": "0x0",
  "timestamp": "0x5f527daa",
  "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "gasLimit": "0x2fefd8ffffffffff",
  "difficulty": "0x80000",
  "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "0x0000000000000000000000000000000000000000",
  "alloc": {
    "40ebd26453a3a3ec06df9b1cf6cb17355d95e78d": {
      "balance": "0x200000000000000000000000000000000000000000000000000000000000000"
    },
    "fd96fcc76da5e04604270bac93cd0e2acdcd670d": {
      "balance": "0x200000000000000000000000000000000000000000000000000000000000000"
    }
  },
  "number": "0x0",
  "gasUsed": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000"
}
````
Este arquivo pode ser alterado de acordo com sua necessidade.
# 1. Iniciar BootNode
Um passo importante para o correto funcionamento de uma rede privada conectada por vários nós e a definição de um nó central o qual os demais se ligarão.  Nomeamos o script para criação deste nó como boot.sh. 

Para a execução deste e dos próximos nós faz necessária a definição de alguns parâmetros referentes à conexão da rede. Todos os parâmetros estão definidos no início do arquivo boot.sh que podem ser editados ou passados por parâmetro na chamada dos scripts, os referentes ao nó do boot e os parâmetros utilizados para alterar seus valores ao executar a função são:

1. VERSION (-v): Versão do arquivo binário do Ethereum a ser instalado.
1. NETWORKID (-n): Deve ser o mesmo do arquivo genesis.
1. BOOTNODEDATADIR (-d): Pasta no computador em que  os arquivos da rede serão armazenados. Por padrão: $HOME/.ethereum/private/boot.
1. BOOTNODEKEY (-k): Um nó de inicialização pede uma chave hexadecimal e através dela será gerado um ID  descrito com um esquema de URL chamado “enode” para conexão de outros nós, deixamos esse valor pré-definido para podermos ter certeza da url de conexão que será utilizado pelos demais nós. Esse valor pode ser gerado pelo comando: bootnode -genkey bootnode.key.
1. BOOTNODEIP (-b): O IP da máquina em que será instanciado o bootnode.
1. BOOTNODEPORT (-p): A porta em que o boot node deverá expor à rede. Por padrão 30301.

Atenção aos parâmetros BOOTNODEIP e BOOTNODEPORT, esses devem estar corretamente configurados para sua máquina.

Para executar o script e crirar o boot node digite no terminal dentro da diretorio do projeto:

````shell script 
./start.sh -t boot                       #iniciar com todos os parâmetros padrões
````
Adicionalmente, podem ser alterados os parâmetros por linha de comando adicionando a flag correspondente ao paramentro, exemplo para alterar o BOOTNODEID:
````shell script  
./start.sh -t boot -b 192.168.0.177      #iniciar alterando ip do bootnode
````

A saída esperada escrita no log, indicando que a rede foi inicializada e qual é o endereço de conexão (enode) de novos nós.
````
INFO [09-24|18:00:36.897] Started P2P networking self=enode://4e87faaa0ed677c3ec389f3ac37f8b0e366876f73e72764e3518031daca322768befb783be5c4aea4200f3439f4361571e860c38776142094adc35913964096b@192.168.1.114:30301
````

# 2. Iniciar um nó de aplicação e nó minerador

Com o bootnode criado, podemos integrar à redes mais dois tipos de nós, o de aplicação (responsável por externar um api a qual será utilizado para inserção e consulta dos dados da blockchain) e outro nó para mineração dos dados enviados para serem inseridos na rede.

Os arquivos criados para este fim são o start.sh (script executável), .accountpassword (contendo a senha da carteira a ser pré-alocada) e .privatekey (chave privada da carteira pré-alocada). A senha e a chave privadas foram pré definidas já que estamos importando uma conta ao invés de criar uma nova, já que para pré-financiar uma conta devemos colocá-la no arquivo genesis.json antes de iniciarmos a rede. 

Os parâmetros definidos para o script start.sh presentes no início do arquivo foram:
1. NODETYPE (-t) (aceitando dois tipos: 'node' para um nó de aplicação, este definido por padrão, e 'miner' para um nó minerador).
1. OPERATIONTYPE (-o) (aceita os comandos 'start' e 'stop' para, respectivamente, iniciar e parar a rede blockchain ).
1. MYNODEPORT (-p) (Porta em que será executada a rede no computador que está iniciando o nó. Por padrão: 30303).
1. DATADIR (-d) (Pasta no computador em que  os arquivos da rede serão armazenados. Por padrão: $HOME/.ethereum/private/node.
1. BOOTNODEIP (-i) (deve ser o ip da máquina que está rodando o bootnode)
1. BOOTNODEID (-b) (deve ser o id criado pela execução do bootnode, se não foi alterado o BOOTNODEKEY este já está configurado)
1. BOOTNODEPORT (-r) (porta em que está sendo executado bootnode, por padrão: 30301)
1. NETWORKID (-n) (é o mesmo chainId do arquivo genesis.json)

Certifique-se que os parâmetros do BOOTNODE são os mesmos utilizado na execução do boot.sh.

Execute o nó de aplicação com o comando:

`````shell script
./start.sh -t node
`````
Com o nó de aplicação iniciado, espera-se a linha indica que o servidor HTTP foi ativado.
````
INFO [09-24|18:10:56.117] HTTP server started   endpoint=127.0.0.1:8545 cors= vhosts=localhost
````

Execute o nó minerador com o comando:

`````shell script
./start.sh -t mine 
`````

Se estiver executando estes dois nós na mesma maquina, ao executar o nó minerador certifique-se de alterar o MYNODEPORT para não gerar conflito entre os nós.

`````shell script
./start.sh -t mine -p 30304
`````
Com o nó minerador iniciado, espera-se a linha que indica o início do trabalho de mineração indicado pela saída “Commit new mining work”.

````
INFO [09-24|18:15:13.672] Commit new mining work   nunber=1 sealhash="c8ecb8...6394dc" uncles=0 txs=0 gas=0 fess=0 elapsed="216.9μs"
````
