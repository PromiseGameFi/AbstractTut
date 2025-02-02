//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract RecursionTest {
    //Struct to track user balances and transaction history
    struct UserAccount {
        uint256 balance;
        uint256 lastDepositAmount;
        uint256 depositCount;
        bool isActive;
        mapping(uint256 => uint256) depositHistory;
    }

    //Mapping to store user accounts
    mapping(address => UserAccount) private userAccounts;

    //Price calculation variables
    uint256 public basePrice;
    uint256 public priceMultiplier;
    uint256 public MAX_DEPOSIT_MULTIPLIER= 5;

    //Events for tracking key contract actions
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event priceUpdate(uint256 newBaseprice);

    //Owner of the contract
    address public owner;

    //Modifier to restrict owner-only function
    modifier onlyOwner{
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(uint256 _initialBasePrice) {
        owner = msg.sender;
        basePrice = _initialBasePrice;
        priceMultiplier = 1;
    }

    //Vulnerabe withdrawal function with potential for recursive attack
    function withdraw(uint256 amount) external {
        UserAccount storage userAccount = userAccounts[msg.sender];

        //check balance and calculate the widrawal price
        require(userAccount.balance >= amount, "Insufficient Funds");

        // calculate dynamic withdrawal price
        uint256 WithdrawalPrice = calculateWithdrawalPrice(amount);

        //Vulnerable point: external call before state change
        (bool success, ) = msg.sender.call{value: amount - WithdrawalPrice}("");
        require(success, "Withdrwal transfer failed");

        //Decrement balance after the external call
        userAccount.balance -= amount;
        userAccount.depositCount--;
        
    }

    

    //Calculate deposit bonus based on complex logic
    function calculateDepositBonus(uint256 amount) private view returns (uint256) {
        uint256 bonusMultiplier = (amount / basePrice) * priceMultiplier;
        return bonusMultiplier > MAX_DEPOSIT_MULTIPLIER
            ? amount * MAX_DEPOSIT_MULTIPLIER
            : amount * bonusMultiplier;
    }


    //Calculate withdrawal price with dynamic price
    function calculateWithdrawalPrice(uint256 amount) private view returns (uint256) {
        uint256 baseWithdrawalFee = (amount * priceMultiplier)/100;
        return baseWithdrawalFee > amount/ 10 ? amount / 10 : baseWithdrawalFee;
    }

    //Function for Owner to Update base price and multiplier
    function updatePriceStructure(uint256 _newBasePrice, uint256 _newMultiplier) external onlyOwner {
        basePrice = _newBasePrice;
        priceMultiplier = _newMltilier;

        emit PriceUpdate(_newBasePrice)
    }

    //Fallback function to handle potential recursive calls
    receive() external payable {
        //Simple reentrancy guard or logging could be added here
    }

    //Function to get user account details (for testing)
    function getUserAccountDetails() external view returns (
        uint256 balance,
        uint256 lastDeposit,
        uint256 depositCount
    ){
        UserAccount storage userAccounts[msg.sender];
        return(
            userAccount.balance,
            userAccount.lastDepositAmount,
            userAccount.depositCount
        ):
    }
}