// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./lib/TransferHelper.sol";

contract SolTest is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    string public name;

    string public symbol;

    mapping(address => bool) public isWhiteListed;

    address public dev;

    uint256 public fee; // 手续费费率，用GWei表示

    address public factory;

    // todo：实现只有factory地址可以访问
    modifier onlyFactory() {
        require(msg.sender == factory, "CALLER_MUST_BE_FACTORY");
        _;
    }

    /// @notice Swap's log.
    /// @param fromToken token's address.
    /// @param sender Who swap
    /// @param fromAmount Input amount.
    event Swap(address fromToken, address sender, uint256 fromAmount);

    event SwapCrossChain(address fromToken, address sender, uint256 fromAmount);

    event AddWhiteList(address contractAddress);

    event RemoveWhiteList(address contractAddr);

    event SetFee(uint256 fee);

    event WithdrawETH(uint256 balance);

    event Withdtraw(address token, uint256 balance);

    event SetDev(address _dev);

    event TransferFactoryTo(address _fac);

    modifier noExpired(uint256 deadLine) {
        require(deadLine >= block.timestamp, "EXPIRED");
        _;
    }

    modifier onlyWhitelisted() {
        require(isWhiteListed[msg.sender], "ONLY WHITELISTED");
        _;
    }

    constructor(
        address _dev,
        uint256 _fee,
        address _owner,
        address _factory
    ) {
        name = "SOL Interview Test";
        symbol = "SOLIT";
        require(_dev != address(0), "DEV_CAN_T_BE_0");
        require(_owner != address(0), "OWNER_CAN_T_BE_0");
        require(_factory != address(0), "FACTORY_CAN_T_BE_0");
        dev = _dev;
        fee = _fee;
        factory = _factory;
        transferOwnership(_owner);
    }

    function addWhiteList(address contractAddr) public onlyOwner {
        isWhiteListed[contractAddr] = true;
        // todo: 实现设置白名单，只有owner可以操作
    }

    function removeWhiteList(address contractAddr) public onlyOwner {
        isWhiteListed[contractAddr] = false;
        // todo: 实现删除白名单地址，只有owner可以操作
    }

    // todo: 实现函数能够接收主网币
    // todo: 交易不能超过deadline
    // todo: 实现防止重入漏洞
    /// @param fromToken token's address. 源币的合约地址
    /// @param fromTokenAmount 从用户地址转走fromToken的数量
    /// @param approveTarget contract's address which will excute calldata 执行交易的目标合约地址
    /// @param deadLine Deadline 时间戳，超过这个时间戳就表示交易执行失败，将revert
    function swap(
        address fromToken,
        uint256 fromTokenAmount,
        address approveTarget,
        uint256 deadLine
    ) external payable noExpired(deadLine) nonReentrant onlyWhitelisted {
        // todo: 实现只有白名单地址可以访问
        // todo: 实现fromToken地址不能为0
        require(fromToken != address(0), "F_TOKEN_CAN_T_BE_0");

        uint256 _fromTokenAmount = fromTokenAmount; // 实际收到的fromToken币的数量
        uint256 _ethAmount = msg.value; // 收到的eth的数量

        TransferHelper.safeTransferFrom(
            fromToken,
            msg.sender,
            address(this),
            _fromTokenAmount
        );
        // todo: 实现从调用者的钱包地址，向本合约转账fromToken，数量fromTokenAmount；将实际获得到的fromToken的数量赋给_fromTokenAmount
        // todo: 实现将获得的eth数量，赋给变量_ethAmount

        // uint256 feeAmount = 0;
        uint256 feeAmount = (_fromTokenAmount * fee) / 100 gwei; // 手续费的数量
        // todo: 计算出手续费，_fromTokenAmount*fee，赋给变量feeAmount

        // todo: 给approveTarget地址授权转走fromAmount数量的fromToken
        TransferHelper.safeApprove(fromToken, approveTarget, _fromTokenAmount);

        // todo: 将feeAmount数量的fromToken转给dev地址
        address _dev = dev;
        TransferHelper.safeTransfer(fromToken, _dev, feeAmount);

        // todo: 将得到的eth转给dev地址
        TransferHelper.safeTransferETH(_dev, _ethAmount);
    }
}
