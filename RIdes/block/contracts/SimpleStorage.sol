// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RideHailingPlatform {
    address public owner;
    uint256 public rideCost; // Cost of each ride in tokens
    uint256 public driverBalance; // Balance to cover driver expenses

    enum RideStatus { Requested, Accepted, InProgress, Completed, Canceled }

    struct Ride {
        address driver;
        address payable passenger;
        RideStatus status;
        string startLocation;
        string endLocation;
        uint256 startTime;
        uint256 endTime;
    }

    Ride[] public rides;

    mapping(address => uint256) public userWallets; // User wallet balances
    mapping(address => uint256) public driverWallets; // Driver wallet balances
    mapping(address => uint256) public companyWallet; // Company wallet balance
    mapping(address => uint256[]) public userTransactions; // User transaction history
    mapping(address => uint256[]) public driverTransactions; // Driver transaction history

    event RideRequested(address indexed passenger, uint256 indexed rideId);
    event RideAccepted(uint256 indexed rideId);
    event RideCompleted(uint256 indexed rideId);
    event RideCanceled(uint256 indexed rideId);
    event FundsAdded(address indexed account, uint256 amount);

    constructor(uint256 costPerRide) {
        owner = msg.sender;
        rideCost = costPerRide;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    function addFundsToUserWallet() public payable {
        userWallets[msg.sender] += msg.value;
        emit FundsAdded(msg.sender, msg.value);
    }

    function addFundsToDriverWallet() public payable {
        driverWallets[msg.sender] += msg.value;
        emit FundsAdded(msg.sender, msg.value);
    }

    function addFundsToCompanyWallet() public payable onlyOwner {
        companyWallet[msg.sender] += msg.value;
        emit FundsAdded(msg.sender, msg.value);
    }

    function requestRide(string memory start, string memory end) external {
        require(userWallets[msg.sender] >= rideCost, "Insufficient funds in user wallet");

        uint256 rideId = rides.length;
        rides.push(Ride(address(0), payable(msg.sender), RideStatus.Requested, start, end, 0, 0));
        emit RideRequested(msg.sender, rideId);
    }

    function acceptRide(uint256 _rideId) external {
        require(_rideId < rides.length, "Invalid ride ID");
        require(msg.sender != rides[_rideId].passenger, "You cannot accept your own ride");
        require(rides[_rideId].status == RideStatus.Requested, "Ride is not available for acceptance");
        require(driverWallets[msg.sender] >= rideCost, "Insufficient funds in driver wallet");

        rides[_rideId].driver = msg.sender;
        rides[_rideId].status = RideStatus.Accepted;
        rides[_rideId].startTime = block.timestamp; // Record start time

        // Deduct ride cost from passenger wallet
        userWallets[rides[_rideId].passenger] -= rideCost;

        emit RideAccepted(_rideId);
    }

    function completeRide(uint256 _rideId) external {
        require(_rideId < rides.length, "Invalid ride ID");
        require(msg.sender == rides[_rideId].driver, "Only the driver can complete the ride");
        require(rides[_rideId].status == RideStatus.InProgress, "Ride is not in progress");

        rides[_rideId].status = RideStatus.Completed;
        rides[_rideId].endTime = block.timestamp; // Record end time

        // Calculate payment to the driver
        uint256 paymentToDriver = rideCost - (rideCost / 10); // Driver gets 90% of the ride cost
        driverWallets[msg.sender] += paymentToDriver;
        driverBalance -= paymentToDriver; // Deduct company's share

        // Record transactions
        userTransactions[rides[_rideId].passenger].push(paymentToDriver);
        driverTransactions[msg.sender].push(paymentToDriver);

        emit RideCompleted(_rideId);
    }

    function cancelRide(uint256 _rideId) external {
        require(_rideId < rides.length, "Invalid ride ID");
        require(msg.sender == rides[_rideId].passenger, "Only the passenger can cancel the ride");
        require(rides[_rideId].status == RideStatus.Requested, "Ride cannot be canceled");

        rides[_rideId].status = RideStatus.Canceled;

        // Refund the passenger
        userWallets[msg.sender] += rideCost;

        emit RideCanceled(_rideId);
    }

    // functions for managing driver wallet, company wallet, and more.
}
