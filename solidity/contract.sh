#!/bin/bash
set -e
VERSIONGETH=1.9.20-979fc968
GETHPATH=''
SOLCVERSION='v0.8.1'
FILENAME=''
EXT=''
CONTRACT=Professional.sol
#Verificar sistema operacional e definir url do compilador solc
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    OS='linux'
    FILENAME='solc-static-linux'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS='darwin'
    FILENAME='solc-macos'
else
    OS='windows'
    FILENAME='solc-windows'
    EXT=".exe"
fi



#Verifica se o arquivo binário ká existe se não inicia download
if [  -f "solc"$EXT ]; then
    echo 'Arquivo encontrado'
else
    curl -s https://api.github.com/repos/ethereum/solidity/releases | \
    grep -E "browser_download_url(.+)"$SOLCVERSION/$FILENAME$EXT | \
    cut -d : -f 2,3 \
    | tr -d \" \
    | xargs -I{} wget -O solc$EXT {}

    chmod +x solc$EXT
fi


./solc --bin --abi --optimize -o compiled $CONTRACT --overwrite

for FILE in compiled/* ; do
FILENAMEEXT=$(echo $FILE| cut -d'/' -f 2)
FILENAME=$(echo $FILENAMEEXT| cut -d'.' -f 1)
COMPILEDEXT=$(echo $FILENAMEEXT| cut -d'.' -f 2)
  if [[ $FILE == *".bin"  ]]; then
    echo "var "$FILENAME"Bin=\"`cat $FILE`\""  > $FILENAME"Bin.js"
  elif [[ $FILE == *".abi" ]]; then
    echo "var "$FILENAME"Abi=`cat $FILE`" > $FILENAME"Abi.js"
  fi
done


if [[ "$GETHPATH" == "" ]]; then
GETHPATH=../geth-alltools-$OS-amd64-$VERSIONGETH/geth
fi

$GETHPATH attach http://localhost:8545


