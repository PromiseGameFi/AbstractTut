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