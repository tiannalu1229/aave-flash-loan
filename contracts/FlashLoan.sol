pragma solidity >=0.4.22 <0.9.0;

import "@aave/protocol-v2/contracts/flashloan/interfaces/IFlashLoanReceiver.sol";
import {ILendingPoolAddressesProvider} from '@aave/protocol-v2/contracts/interfaces/ILendingPoolAddressesProvider.sol';
import "@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

//aave主网：0x7d2768de32b0b80b7a3454c06bdac94a69ddc7a9
//aave测试网：
contract FlashLoan is IFlashLoanReceiver {

    address sender = 0x0bb328ABb7a2d948532Ab098e80aa5936993055a;
    uint constant deadline = 10 days;

    ILendingPoolAddressesProvider public immutable override ADDRESSES_PROVIDER;
    ILendingPool public immutable override LENDING_POOL;

    mapping(uint8 => address) private indexToToken;

    IUniswapV2Router02 immutable uniswapRouter;
    IUniswapV2Router02 immutable sushiRouter;

    IUniswapV2Factory immutable uniswapFactory;
    IUniswapV2Factory immutable sushiFactory;

    constructor (
        address _uniswapRouter,
        address _sushiRouter,
        address _uniswapFactory,
        address _sushiFactory,
        address provider
    ) public {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        sushiRouter = IUniswapV2Router02(_sushiRouter);
        uniswapFactory = IUniswapV2Factory(_uniswapFactory);
        sushiFactory = IUniswapV2Factory(_sushiFactory);
        ADDRESSES_PROVIDER = ILendingPoolAddressesProvider(provider);
        LENDING_POOL = ILendingPool(ILendingPoolAddressesProvider(provider).getLendingPool());
    }

    function getLendPool() external view returns (address) {
        return address(LENDING_POOL);
    }

    function myFlashLoanCall(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        bytes calldata params
    ) external {
        address receiverAddress = address(this);

        address onBehalfOf = address(this);
        uint16 referralCode = 0;

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            premiums,
            onBehalfOf,
            params,
            referralCode
        );
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        
        uint8[] memory p;

        uint8 dexPath = uint8(params[0]);
        address exchangeToken = indexToToken[uint8(params[1])];

        require(exchangeToken == 0x24a19eE5A5C8757ACDEBe542a9436D9C796d1c9E, "no token");

        return swapToken(uint8(params[0]), assets[0], exchangeToken, amounts[0]);
    }

    /**
        param: 
            param = 1，在uniswap v2中将asset换成exchangeToken，后在sushiswap中将exchangeToken换成asset
            param = 2，在sushiswap中将asset换成exchangeToken，后在uniswap v2中将exchangeToken换成asset
        amount：asset数量
    **/
    function swapToken(
        uint8 dexPath,
        address asset,
        address exchangeToken,
        uint256 amount
    ) internal returns (bool) {

        bytes memory data;
        address[] memory path1 = new address[](2);   //交换路径
        path1[0] = asset;
        path1[1] = exchangeToken;

        address[] memory path2 = new address[](2);   //交换路径
        path2[0] = exchangeToken;
        path2[1] = asset;

        IERC20 tokenA = IERC20(asset);
        IERC20 tokenE = IERC20(exchangeToken);

        uint[] memory amountRequired1;
        uint amountReceived1;
        uint[] memory amountRequired2;
        uint amountReceived2;

        if (dexPath == 1) {

            tokenA.approve(address(uniswapRouter), amount);
            amountRequired1 = UniswapV2Library.getAmountsOut(address(uniswapFactory), amount, path1);   //交换出ET的数量
            require(amountRequired1[amountRequired1.length - 1] > 0, "amountRequired1 is not exist");
            amountReceived1 = uniswapRouter.swapExactTokensForTokens(amount, amountRequired1[amountRequired1.length - 1], path1, msg.sender, now + deadline)[1];
            
            require(amountReceived1 > 0, "amountReceived1");
            tokenE.approve(address(sushiRouter), amountReceived1);
            amountRequired2 = UniswapV2Library.getAmountsOut(address(sushiFactory), amountReceived1, path2);   //交换出ET的数量
            require(amountRequired2[amountRequired2.length - 1] > 0, "amountRequired2 is not exist");
            amountReceived2 = sushiRouter.swapExactTokensForTokens(amountReceived1, amountRequired2[amountRequired2.length - 1], path2, msg.sender, now + deadline)[1];
            
        } else {
            tokenA.approve(address(sushiRouter), amount);
            amountRequired1 = UniswapV2Library.getAmountsOut(address(uniswapFactory), amount, path1);   //交换出ET的数量
            amountReceived1 = sushiRouter.swapExactTokensForTokens(amount, amountRequired1[amountRequired1.length - 1], path1, msg.sender, now + deadline)[1];

            tokenE.approve(address(uniswapRouter), amountReceived1);
            amountRequired2 = UniswapV2Library.getAmountsOut(address(sushiFactory), amountReceived1, path2);   //交换出ET的数量
            amountReceived2 = uniswapRouter.swapExactTokensForTokens(amountReceived1, amountRequired2[amountRequired2.length - 1], path2, msg.sender, now + deadline)[1];
        }

        if (amountReceived2 <= amount + amount / 1000) {
            return false;
        }
        require(false, "finish swap");

        tokenA.transfer(sender, amountReceived2 - amount + amount / 1000);

        require(false, "swapToken");

        return true;
    }

    function getToken(uint8 index) external view returns (address) {
        return indexToToken[index];
    }

    function setToken(uint8 index, address token) external {
        indexToToken[index] = token;
    }
}