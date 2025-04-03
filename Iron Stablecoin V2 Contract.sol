// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract IronStablecoinV2 is ERC20, ReentrancyGuard {
    using SafeMath for uint256;

    address public owner;
    mapping(address => uint256) public collateralDeposits;
    mapping(address => uint256) public debt;
    
    uint256 public constant COLLATERAL_RATIO = 150; // 150% thế chấp
    uint256 public constant LIQUIDATION_THRESHOLD = 120; // Ngưỡng thanh lý 120%
    uint256 public constant LIQUIDATOR_REWARD = 50; // 50% tài sản thế chấp

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Minted(address indexed user, uint256 amount);
    event Burned(address indexed user, uint256 amount);
    event Liquidated(address indexed user, uint256 amountCollateral, uint256 amountBurned);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor() ERC20("Iron Stablecoin V2", "IRONv2") {
        owner = msg.sender;
    }

    function depositCollateral() external payable nonReentrant {
        require(msg.value > 0, "Must deposit ETH");
        collateralDeposits[msg.sender] = collateralDeposits[msg.sender].add(msg.value);
        emit Deposited(msg.sender, msg.value);
    }

    function mint(uint256 amount) external nonReentrant {
        uint256 requiredCollateral = amount.mul(COLLATERAL_RATIO).div(100);
        require(collateralDeposits[msg.sender] >= requiredCollateral, "Insufficient collateral");

        debt[msg.sender] = debt[msg.sender].add(amount);
        _mint(msg.sender, amount);
        emit Minted(msg.sender, amount);
    }

    function burn(uint256 amount) external nonReentrant {
        require(balanceOf(msg.sender) >= amount, "Not enough stablecoin");

        uint256 collateralToReturn = amount.mul(100).div(COLLATERAL_RATIO);
        require(collateralDeposits[msg.sender] >= collateralToReturn, "Not enough collateral to withdraw");
        require(address(this).balance >= collateralToReturn, "Contract does not have enough ETH");

        _burn(msg.sender, amount);
        debt[msg.sender] = debt[msg.sender].sub(amount);
        collateralDeposits[msg.sender] = collateralDeposits[msg.sender].sub(collateralToReturn);
        payable(msg.sender).transfer(collateralToReturn);

        emit Burned(msg.sender, amount);
        emit Withdrawn(msg.sender, collateralToReturn);
    }

    function liquidate(address user) external nonReentrant {
        uint256 userCollateral = collateralDeposits[user];
        uint256 userDebt = debt[user];

        uint256 requiredCollateral = userDebt.mul(LIQUIDATION_THRESHOLD).div(100);
        require(userCollateral < requiredCollateral, "User is still collateralized");

        uint256 liquidationAmount = userDebt.mul(50).div(100); // 50% debt
        uint256 collateralToLiquidate = liquidationAmount.mul(100).div(COLLATERAL_RATIO);

        require(address(this).balance >= collateralToLiquidate, "Not enough ETH in contract");

        _burn(user, liquidationAmount);
        debt[user] = debt[user].sub(liquidationAmount);
        collateralDeposits[user] = collateralDeposits[user].sub(collateralToLiquidate);

        payable(msg.sender).transfer(collateralToLiquidate);

        emit Liquidated(user, collateralToLiquidate, liquidationAmount);
    }

    function withdrawCollateral(uint256 amount) external nonReentrant {
        require(collateralDeposits[msg.sender] >= amount, "Insufficient collateral");

        uint256 maxWithdrawable = collateralDeposits[msg.sender].sub(
            debt[msg.sender].mul(COLLATERAL_RATIO).div(100)
        );

        require(amount <= maxWithdrawable, "Withdrawal would break collateral ratio");
        require(address(this).balance >= amount, "Contract does not have enough ETH");

        collateralDeposits[msg.sender] = collateralDeposits[msg.sender].sub(amount);
        payable(msg.sender).transfer(amount);

        emit Withdrawn(msg.sender, amount);
    }

    function getCollateralRatio(address user) external view returns (uint256) {
        if (debt[user] == 0) return type(uint256).max;
        return collateralDeposits[user].mul(100).div(debt[user]);
    }

    function getCollateral(address user) external view returns (uint256) {
        return collateralDeposits[user];
    }

    function getDebt(address user) external view returns (uint256) {
        return debt[user];
    }
}
