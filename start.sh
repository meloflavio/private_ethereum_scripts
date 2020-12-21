#!/bin/bash
set -e
OPERATIONTYPE=start
NETWORKID=1228800
VERSION=1.9.20-979fc968
NODETYPE=node
DATADIR=$HOME/.ethereum/private/mine
MYNODEPORT=30303
BOOTNODEDATADIR=$HOME/.ethereum/private/boot
BOOTNODEKEY=8b7aaa22a34451deac5d53b511cc66a5607c048bfd689ab711a8845cfd254421
BOOTNODEIP=192.168.1.114
BOOTNODEPORT=30301
BOOTNODEID=4e87faaa0ed677c3ec389f3ac37f8b0e366876f73e72764e3518031daca322768befb783be5c4aea4200f3439f4361571e860c38776142094adc35913964096b


UNZIP="tar -xvzf"
IPC=''
DATADIR="$HOME/."$(echo $DATADIR |cut -d'.' -f 2)
while getopts v:t:o:i:d:p:b:r:n: flag
do
    case "${flag}" in
        v) VERSION=${OPTARG};;
        t) NODETYPE=${OPTARG};;
        o) OPERATIONTYPE=${OPTARG};;
        i) BOOTNODEIP=${OPTARG};;
        d) DATADIR=${OPTARG};;
        p) MYNODEPORT=${OPTARG};;
        b) BOOTNODEID=${OPTARG};;
        r) BOOTNODEPORT=${OPTARG};;
        n) NETWORKID=${OPTARG};;
    esac
done



accountFile=".accountpassword"
privateFile=".privatekey"
if [[ "$NODETYPE" == *"e2" ]]; then
    accountFile=".accountpassword2"
    privateFile=".privatekey2"
    DATADIR=$DATADIR"2"
    MYNODEPORT=$(($MYNODEPORT+10))
fi

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

FILE=geth-alltools-$OS-amd64-$VERSION
FILEEXT=$FILE.$EXT
URL=https://gethstore.blob.core.windows.net/builds/$FILEEXT
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
    if [  -d "$DATADIR" ]; then
        echo 'Genesis iniciada'
    else
        $FILE/geth --datadir=$DATADIR init genesis.json 
        sleep 3
    fi

    output=$($FILE/geth  --verbosity=0 --datadir=$DATADIR account list)
    
    echo $output
    if [[ "$output" == "Account #0"* ]]; then
        echo 'Conta #0 presente'
    else
        $FILE/geth --datadir=$DATADIR account import --password $accountFile $privateFile
        output=$($FILE/geth  --verbosity=0 --datadir=$DATADIR account list)
    fi
    sleep 3
    adressAccount=$(echo $output | $GREP "\{([^}]+)\}" | $GREP "\w+")
    echo $NETWORKID
    if [[ "$NODETYPE" == "node"* ]]; then
        $FILE/geth --nousb --datadir=$DATADIR  --rpc --rpcapi "eth,web3,net,admin,debug,personal,miner" --allow-insecure-unlock
    elif [[ "$NODETYPE" == "mine"* ]]; then
        $FILE/geth --nousb --datadir=$DATADIR --bootnodes "enode://$BOOTNODEID@$BOOTNODEIP:$BOOTNODEPORT" --networkid $NETWORKID --port $MYNODEPORT     --syncmode="full"  --gasprice "0"  --etherbase $adressAccount --unlock $adressAccount --password $accountFile --mine --miner.threads 1
    fi
    sleep 3
elif [[ "$OPERATIONTYPE" == "stop" ]]; then
    pkill -f "port $MYNODEPORT"
fi
