// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MemeSeasonX is ERC20, Ownable {
    uint256 public feeDenominator = 10000;

    // Tranfer Fees
    uint256 public marketingFees = 500;
    uint256 public liquidityFees = 200;
    uint256 public Rewardfees = 300;
    uint256 public totalFee = 1000;

    // Fees receivers
    address private bonusWallet;
    address private marketingWallet;
    address private devWallet;

    constructor(
        address _bonusWallet,
        address _marketingWallet,
        address _devWallet
    ) ERC20("Meme Season X", "Meme X") {
        bonusWallet = _bonusWallet;
        marketingWallet = _marketingWallet;
        devWallet = _devWallet;
        _mint(msg.sender, 42000000000 * 10**decimals());
    }


    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        return _memeTransfer(_msgSender(), to, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(sender, spender, amount);
        return _memeTransfer(sender, recipient, amount);
    }


    // tranfer helper
    function _memeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        uint256 amountReceived = takeFee(sender, amount);
        _transfer(sender, recipient, amountReceived);
        return true;
    }
    
    // takes all tranfer fees when any user send funds
    function takeFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {  
        // full fees
        uint256 feeAmount = (amount * totalFee) / feeDenominator;
        uint256 marketingFee = (feeAmount * marketingFees) / totalFee;
        uint256 liquidityFee = (feeAmount * liquidityFees) / totalFee;
        uint256 rewardFee = (feeAmount * Rewardfees) / totalFee;

        // Transfer each fee to its respective wallet
        _transfer(sender, bonusWallet, marketingFee);
        _transfer(sender, devWallet, liquidityFee);
        _transfer(sender, marketingWallet, rewardFee);

        return amount - feeAmount;
    }
  

    // set all tranfer fees
    function setFees(
        uint256 _marketingFees,
        uint256 _lpFees,
        uint256 _rewardFees
    ) external onlyOwner {
        marketingFees = _marketingFees;
        liquidityFees = _lpFees;
        Rewardfees = _rewardFees;

        totalFee = _marketingFees + _lpFees + _rewardFees;
    }
    
    // set all receivers address
    function setFeeReceivers(address _bonusWallet, address _marketingWallet,address _devWallet)
        external
        onlyOwner
    {
        bonusWallet = _bonusWallet;
        marketingWallet = _marketingWallet;
        devWallet = _devWallet;
    }
}
