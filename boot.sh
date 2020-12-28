#!/bin/bash
set -e

OPERATIONTYPE=start
NETWORKID=1288
VERSION=1.9.20-979fc968
BOOTNODEDATADIR=$HOME/.ethereum/private/boot
BOOTNODEKEY=8b7aaa22a34451deac5d53b511cc66a5607c048bfd689ab711a8845cfd254421
BOOTNODEIP=192.168.1.115
BOOTNODEPORT=30301



UNZIP="tar -xvzf"


while getopts v:o:b:d:k:p:n: flag
do
    case "${flag}" in
        v) VERSION=${OPTARG};;
        o) OPERATIONTYPE=${OPTARG};;
        b) BOOTNODEIP=${OPTARG};;
        d) BOOTNODEDATADIR=${OPTARG};;
        k) BOOTNODEKEY=${OPTARG};;
        p) BOOTNODEPORT=${OPTARG};;
        n) NETWORKID=${OPTARG};;
    esac
done

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    OS='linux'
    EXT='tar.gz'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS='darwin'
    EXT='tar.gz'
else 
    OS='windows'
    EXT='zip'
    UNZIP="unzip"
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
    if [  -d "$BOOTNODEDATADIR" ]; then
        echo 'Genesis iniciada'
    else
        $FILE/geth --datadir=$BOOTNODEDATADIR init genesis.json 
        sleep 3
    fi
    $FILE/geth --nousb --datadir=$BOOTNODEDATADIR --nodekeyhex=$BOOTNODEKEY --networkid $NETWORKID  --nat extip:$BOOTNODEIP --port $BOOTNODEPORT>boot.log
elif [[ "$OPERATIONTYPE" == "stop" ]]; then
    pkill -f "port $BOOTNODEPORT"
fi
