Comandos dentro do geth 
````
loadScript('ProfessionalRegistryAbi.js')

loadScript('ProfessionalRegistryBin.js')

var comp = "0x" + ProfessionalRegistryBin


var abi = ProfessionalRegistryAbi

var gas = eth.estimateGas({from: eth.coinbase, data: comp})

var factory =  eth.contract(abi)

eth.defaultAccount = eth.coinbase


var contrato = factory.new({data: comp, gas: gas}, function(e, contract) {
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
        
contrato.createProfessional(eth.accounts[0],"Profissional 1","00000000000","123CRMTO","professional@gmail.com","63 99999-9999")
transactionHash = contrato.getLastDetails()
eth.getTransactionReceipt(transactionHash).logs[0].data
  let receipt = await web3.eth.getTransactionReceipt(transactionHash)
   const decodedLogs = abiDecoder.decodeLogs(receipt.logs);
   console.log(decodedLogs)
````
https://adibas03.github.io/online-ethereum-abi-encoder-decoder/#/decode
