const { accounts, contract } = require('@openzeppelin/test-environment');
const FlashLoan = contract.fromArtifact('FlashLoan');
const { deployer } = require('./share/deployer');

var deployed = await deployer(owner);
this.factoryInstance = deployed.factoryInstance;
var flashLoan = new FlashLoan();

const ethers = require('ethers');
const BigNumber = ethers.BigNumber;

describe('add margin test', function () {

    const [owner] = accounts;

    it('byte test', async function () {

        var i = await flashLoan.executeOperation(123);
        console.log(i);
    })
})