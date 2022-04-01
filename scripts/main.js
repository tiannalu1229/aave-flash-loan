const { providers, Contract, Wallet, utils, BigNumber } = require('ethers');
const { isHexString, hexConcat, hexValue } = require('ethers/lib/utils');
const { abi, address, providerAddress, privateKey } = require('./config');

async function doTest() {
    let overrides = {
        gasLimit: 10000000,
        gasPrice: utils.parseUnits('20.0', 'gwei'),
    };

    let provider = new providers.JsonRpcProvider(providerAddress);
    let wallet = new Wallet(privateKey, provider);
    // let network = "42"

    let FlashLoan = new Contract("0xC800bAD4D3aC6f7d68Df686aCF8B223F82Db61A3", abi('FlashLoan'), provider).connect(wallet);
    
    // await FlashLoan.setToken(1, "0x24a19eE5A5C8757ACDEBe542a9436D9C796d1c9E");
    // console.log(await FlashLoan.getToken(1))

    await FlashLoan.myFlashLoanCall(
        ["0xd0A1E359811322d97991E03f863a0C30C2cF029C"],
        [BigNumber.from("1000000000000000")],
        [0],
        [2,1],
        overrides);
}

async function test() {
    try {
        await doTest()
    } catch (e) {
        console.error(e)
    }
}

test()