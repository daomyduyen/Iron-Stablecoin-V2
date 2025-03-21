// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract IronStablecoinV2 is ERC20, ReentrancyGuard {
    address public owner;
    mapping(address => uint256) public collateralDeposits; // Lưu số ETH thế chấp
    uint256 public collateralizationRatio = 150; // 150% thế chấp
    uint256 public liquidationThreshold = 120; // Ngưỡng thanh lý 120%

    event Minted(address indexed user, uint256 amount);
    event Burned(address indexed user, uint256 amount);
    event Liquidated(address indexed user, uint256 amountCollateral, uint256 amountBurned);
    event Withdrawn(address indexed user, uint256 amount);

    constructor() ERC20("Iron Stablecoin V2", "IRONv2") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    function depositCollateral() external payable nonReentrant {
        require(msg.value > 0, "Must deposit ETH");
        collateralDeposits[msg.sender] += msg.value;
    }

    function mint(uint256 amount) external nonReentrant {
        uint256 requiredCollateral = (amount * collateralizationRatio) / 100;
        require(collateralDeposits[msg.sender] >= requiredCollateral, "Insufficient collateral");

        _mint(msg.sender, amount);
        emit Minted(msg.sender, amount);
    }

    function burn(uint256 amount) external nonReentrant {
        require(balanceOf(msg.sender) >= amount, "Not enough stablecoin");

        uint256 collateralToReturn = (amount * 100) / collateralizationRatio;
        require(collateralDeposits[msg.sender] >= collateralToReturn, "Not enough collateral to withdraw");

        _burn(msg.sender, amount);
        payable(msg.sender).transfer(collateralToReturn);
        collateralDeposits[msg.sender] -= collateralToReturn;

        emit Burned(msg.sender, amount);
        emit Withdrawn(msg.sender, collateralToReturn);
    }

    function liquidate(address user) external nonReentrant {
        uint256 userCollateral = collateralDeposits[user];
        uint256 userDebt = balanceOf(user);

        uint256 requiredCollateral = (userDebt * liquidationThreshold) / 100;
        require(userCollateral < requiredCollateral, "User is still collateralized");

        uint256 liquidationAmount = userDebt / 2;
        uint256 collateralToLiquidate = (liquidationAmount * 100) / collateralizationRatio;

        _burn(user, liquidationAmount);
        payable(msg.sender).transfer(collateralToLiquidate / 2);
        payable(owner).transfer(collateralToLiquidate / 2);
        collateralDeposits[user] -= collateralToLiquidate;

        emit Liquidated(user, collateralToLiquidate, liquidationAmount);
    }

    function getCollateral(address user) external view returns (uint256) {
        return collateralDeposits[user];
    }
}
