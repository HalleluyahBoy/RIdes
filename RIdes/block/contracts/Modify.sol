// SPDX-License-Identifier: MIT
// Contract for saving driver and passenger,
// in this contract an account, it'll require an account, from both parties(driver and passenger)
// the account will be funded with token and crypto
// the contract will also be rewarding drivers initially for signing up and referral


pragma solidity ^0.8.0;

contract platfo {
    address public owner;

    // Enum to represent the status of a ride
    enum RideStatus { Requested, Accepted, InProgress, Completed, Canceled }

    // Struct to represent a ride
    struct Ride {
        address driver;
        address passenger;
        uint256 fare;
        RideStatus status;
    }

    Ride[] public rides;

    // Mapping to keep track of rides for each driver and passenger
    mapping(address => uint256[]) public driverRides;
    mapping(address => uint256[]) public passengerRides;

    // Events to log important contract actions
    event RideRequested(address indexed passenger, uint256 indexed rideId);
    event RideAccepted(uint256 indexed rideId);
    event RideCompleted(uint256 indexed rideId);
    event RideCanceled(uint256 indexed rideId);

    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict access to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    // Function for passengers to request a ride
    function requestRide() external payable {
        require(msg.value > 0, "Payment is required to request a ride");
        rides.push(Ride(msg.sender, address(0), msg.value, RideStatus.Requested));
        uint256 rideId = rides.length - 1;
        passengerRides[msg.sender].push(rideId);
        emit RideRequested(msg.sender, rideId);
    }

    // Function for drivers to accept a ride request
    function acceptRide(uint256 _rideId) external {
        require(_rideId < rides.length, "Invalid ride ID");
        require(msg.sender != rides[_rideId].driver, "You cannot accept your own ride");
        require(rides[_rideId].status == RideStatus.Requested, "Ride is not available for acceptance");

        rides[_rideId].driver = msg.sender;
        rides[_rideId].status = RideStatus.Accepted;
        driverRides[msg.sender].push(_rideId);

        emit RideAccepted(_rideId);
    }

    // Function for drivers to mark a ride as completed and get paid
    function completeRide(uint256 _rideId) external {
        require(_rideId < rides.length, "Invalid ride ID");
        require(msg.sender == rides[_rideId].driver, "Only the driver can complete the ride");
        require(rides[_rideId].status == RideStatus.InProgress, "Ride is not in progress");

        rides[_rideId].status = RideStatus.Completed;

        // Calculate and transfer payment to the driver
        payable(msg.sender).transfer(rides[_rideId].fare);

        emit RideCompleted(_rideId);
    }

    // Function for passengers to cancel a ride and get a refund
    function cancelRide(uint256 _rideId) external {
        require(_rideId < rides.length, "Invalid ride ID");
        require(msg.sender == rides[_rideId].passenger, "Only the passenger can cancel the ride");
        require(rides[_rideId].status == RideStatus.Requested, "Ride cannot be canceled");

        rides[_rideId].status = RideStatus.Canceled;

        // Refund the passenger
        payable(msg.sender).transfer(rides[_rideId].fare);

        emit RideCanceled(_rideId);
    }

    // functions for handling additional features like rating drivers, handling disputes, etc.
}
