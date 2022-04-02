#!/bin/bash
set -e

#Define parâmetros iniciais
OPERATIONTYPE=start
NETWORKID=1288
VERSION=1.9.20-979fc968
NODETYPE=node
DATADIR=""
MYNODEPORT=30303

BOOTNODEKEY=8b7aaa22a34451deac5d53b511cc66a5607c048bfd689ab711a8845cfd254421
BOOTNODEIP=127.0.0.1
BOOTNODEPORT=30301
BOOTNODEID=4e87faaa0ed677c3ec389f3ac37f8b0e366876f73e72764e3518031daca322768befb783be5c4aea4200f3439f4361571e860c38776142094adc35913964096b


UNZIP="tar -xvzf"
IPC=''

#Define flags para substituir os parâmetros iniciais
while getopts t:v:n:d:k:i:p:b:o:m: flag
do
    case "${flag}" in
        t) NODETYPE=${OPTARG};;
        v) VERSION=${OPTARG};;
        n) NETWORKID=${OPTARG};;
        d) DATADIR=${OPTARG};;
        k) BOOTNODEKEY=${OPTARG};;
        i) BOOTNODEIP=${OPTARG};;
        p) BOOTNODEPORT=${OPTARG};;
        b) BOOTNODEID=${OPTARG};;
        o) OPERATIONTYPE=${OPTARG};;
        m) MYNODEPORT=${OPTARG};;
    esac
done

#Se datadir não definido pela flag, define datadir padrão
if [[ "$DATADIR" == "" ]]; then
DATADIR=$HOME/.ethereum/local/$NODETYPE
fi

#Define password e chave privada do nó de aplicacao ou minerador
accountFile=".accountpassword"
privateFile=".privatekey"
if [[ "$NODETYPE" == "mine"* ]]; then
#    accountFile=".accountpassword2"
#    privateFile=".privatekey2"
    MYNODEPORT=$(($MYNODEPORT+10))
fi

#Verificar sistema operacional e definir url das ferramentas da plataforma Ethereum e metodo de descompressão
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    OS='linux'
    EXT='tar.gz'
    GREP='grep -oP'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS='darwin'
    EXT='tar.gz'
    GREP='egrep -o'
else 
    OS='windows'
    EXT='zip'
    UNZIP='unzip'
    GREP='grep -oP'
    IPC='--ipcdisable'
fi

#Monta URL do arquivo binário
FILE=geth-alltools-$OS-amd64-$VERSION
FILEEXT=$FILE.$EXT
URL=https://gethstore.blob.core.windows.net/builds/$FILEEXT

#Verifica se o arquivo binário ká existe se não inicia download
if [  -f "$FILEEXT" ]; then
    echo 'Arquivo encontrado'
else
    curl -O $URL  
fi
if [  -d "$FILE" ]; then
    echo 'Arquivo descomprimido'
else
    $UNZIP $FILEEXT   
fi


if [[ "$OPERATIONTYPE" == "start" ]]; then



    #Verifica se o blocco inicial foi criado, caso contrário o inicia
    if [  -d "$DATADIR" ]; then
        echo 'Genesis iniciada'
    else
        $FILE/geth --datadir=$DATADIR init genesis.json 
        sleep 3
    fi


    #Se não é nó de boot, pega o endereço da carteira base do nó
    if [[ "$NODETYPE" != "boot" ]]; then
      output=$($FILE/geth  --verbosity=0 --datadir=$DATADIR account list)  #lista todas as contas do nó
      if [[ "$output" == "Account #0"* ]]; then   #verifica se tem alguma conta no retorno da chamada anterior
          echo 'Conta #0 presente'
      else
          $FILE/geth --datadir=$DATADIR account import --password $accountFile $privateFile #importa a conta quando não
                                                                                            # existe nenhuma conta
          output=$($FILE/geth  --verbosity=0 --datadir=$DATADIR account list) #lista todas as contas do nó, agora com o
                                                                              # endereço da conta importada
      fi
      sleep 3
      adressAccount=$(echo $output | $GREP "\{([^}]+)\}" | $GREP "\w+")  #retira apenas os endereços da conta
      adressAccount=$(echo $adressAccount | cut -d' ' -f1) #seleciona apenas o primeiro endereço
    fi

    sleep 3

    #Verifica qual o nó vai ser iniciado e executa o comando referente a esse nó
    if [[ "$NODETYPE" == "node"* ]]; then
        $FILE/geth --nousb --datadir=$DATADIR --syncmode 'full' --bootnodes "enode://$BOOTNODEID@$BOOTNODEIP:$BOOTNODEPORT" --networkid $NETWORKID --port $MYNODEPORT --http --http.addr 'localhost' --http.port 8545  --http.api admin,eth,miner,net,txpool,personal,web3  --allow-insecure-unlock --unlock $adressAccount  --password .accountpassword
    elif [[ "$NODETYPE" == "mine"* ]]; then
        $FILE/geth --nousb --datadir=$DATADIR --bootnodes "enode://$BOOTNODEID@$BOOTNODEIP:$BOOTNODEPORT" --networkid $NETWORKID --port $MYNODEPORT     --syncmode="fast"  --miner.gasprice "0" --miner.etherbase $adressAccount --mine --miner.threads 8 --unlock $adressAccount --password .accountpassword
    elif [[ "$NODETYPE" == "boot" ]]; then
        $FILE/geth --nousb --datadir=$DATADIR  --nodekeyhex=$BOOTNODEKEY --networkid $NETWORKID --nat extip:$BOOTNODEIP --port $BOOTNODEPORT
    fi
    sleep 3
elif [[ "$OPERATIONTYPE" == "stop" ]]; then
    pkill -f "port $MYNODEPORT"
fi
