// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OrderBaseSwap {
    error AddressZeroDetected();
    error ZeroValueNotAllowed();
    error InsufficientFunds();
    error OrderIsNotActive();
    error RequestedAmountExceedsAvailableToken();

    struct Order {
        address depositor;
        address depositToken;
        uint256 depositAmount;
        address tokenDesired;
        uint256 amountDesired;
        bool isActive;
    }

    uint256 public orderCount;
    mapping(address => mapping(address => uint256)) public deposits;
    mapping(uint256 => Order) public orders;
    mapping(address => mapping(address => uint256)) public prices;

    event DepositSuccessful(
        address indexed depositor,
        address indexed token,
        uint256 amount,
        address tokenDesired,
        uint256 amountDesired
    );

    event SwapSuccessful(
        address indexed buyer,
        address indexed token,
        uint256 amount,
        address tokenDesired,
        uint256 totalCost
    );

    constructor() {}

    function depositTokens(
        address _depositToken,
        uint256 _amount,
        address _tokenDesired,
        uint256 _amountDesired
    ) external {
        if (msg.sender == address(0)) {
            revert AddressZeroDetected();
        }

        if (_amount <= 0) {
            revert ZeroValueNotAllowed();
        }

        uint256 _userTokenBalance = IERC20(_depositToken).balanceOf(msg.sender);

        if (_userTokenBalance < _amount) {
            revert InsufficientFunds();
        }

        IERC20(_depositToken).transferFrom(msg.sender, address(this), _amount);

        orders[orderCount] = Order({
            depositor: msg.sender,
            depositToken: _depositToken,
            depositAmount: _amount,
            tokenDesired: _tokenDesired,
            amountDesired: _amountDesired,
            isActive: true
        });

        prices[_depositToken][_tokenDesired] = (_amountDesired * 1e18) / _amount;

        deposits[msg.sender][_depositToken] += _amount;

        orderCount++;

        emit DepositSuccessful(
            msg.sender,
            _depositToken,
            _amount,
            _tokenDesired,
            _amountDesired
        );
    }
}
