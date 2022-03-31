const { contract } = require('@openzeppelin/test-environment');

const { BigNumber } = require('ethers')

const FlashLoan = contract.fromArtifact('FlashLoan');

module.exports = {
    "deployer": async function (owner) {
        var flashLoan = await FlashLoan.new(
            "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
            "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506",
            "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f",
            "0xc35DADB65012eC5796536bD9864eD8773aBc74C4",
            "0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5");

        return {
            "flashLoan": flashLoan
        }
    }
}
