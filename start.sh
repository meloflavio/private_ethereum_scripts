#!/bin/bash
set -e

OPERATION=start
TYPENODE=boot
DATADIR=$PWD/$TYPENODE
MYNODEPORT=30303

NETWORKID=1288
VERSION=1.9.20-979fc968

BOOTNODEKEY=8b7aaa22a34451deac5d53b511cc66a5607c048bfd689ab711a8845cfd254421
BOOTNODEIP=192.168.1.114
BOOTNODEPORT=30301
BOOTNODEID=4e87faaa0ed677c3ec389f3ac37f8b0e366876f73e72764e3518031daca322768befb783be5c4aea4200f3439f4361571e860c38776142094adc35913964096b



UNZIP="tar -xvzf"


while getopts o:t:d:m:n:v:k:i:p:b flag
do
    case "${flag}" in
        o) OPERATIONTYPE=${OPTARG};;
        t) TYPENODE=${OPTARG};;
        d) DATADIR=${OPTARG};;
        m) MYNODEPORT=${OPTARG};;
        n) NETWORKID=${OPTARG};;
        v) VERSION=${OPTARG};;
        k) BOOTNODEKEY=${OPTARG};;
        i) BOOTNODEIP=${OPTARG};;
        p) BOOTNODEPORT=${OPTARG};;
        b) BOOTNODEID=${OPTARG};;
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
if [  -d "$DATADIR" ]; then
    echo 'Genesis iniciada'
else
    $FILE/geth --datadir=$DATADIR init genesis.json
    sleep 3
fi


    $FILE/geth --datadir=$DATADIR --nodekeyhex=$BOOTNODEKEY --networkid $NETWORKID  --nat extip:$BOOTNODEIP --port $BOOTNODEPORT >boot.log
