const FlashLoan = artifacts.require("FlashLoan");

/**
  mainnet:
    aave provider:     0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5
    uniswapV2Factory:  0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f
    uniswapV2Router02: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    sushiFactory:      0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac
    sushiRouter:       0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F
  kovan:
    aave provider:     0x88757f2f99175387aB4C6a4b3067c77A695b0349
    uniswapV2Factory:  0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    uniswapV2Router02: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    sushiFactory:      0xc35DADB65012eC5796536bD9864eD8773aBc74C4
    sushiRouter:       0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
**/
module.exports = function (deployer) {
  deployer.deploy(
    FlashLoan,
    "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506",
    "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f",
    "0xc35DADB65012eC5796536bD9864eD8773aBc74C4",
    "0x88757f2f99175387aB4C6a4b3067c77A695b0349");
};
