// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RODEs {
    address public owner;
    
    enum RideStatus { Requested, Accepted, InProgress, Completed, Canceled }

    struct Ride {
        address driver;
        address passenger;
        uint256 fare;
        RideStatus status;
        string startLocation;
        string endLocation;
        uint256 startTime;
        uint256 endTime;
    }

    Ride[] public rides;
    
    mapping(address => uint256[]) public driverRides;
    mapping(address => uint256[]) public passengerRides;

    event RideRequested(address indexed passenger, uint256 indexed rideId);
    event RideAccepted(uint256 indexed rideId);
    event RideCompleted(uint256 indexed rideId);
    event RideCanceled(uint256 indexed rideId);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    function requestRide(string memory start, string memory end) external payable {
        require(msg.value > 0, "Payment is required to request a ride");
        uint256 rideId = rides.length;
        rides.push(Ride(msg.sender, address(0), msg.value, RideStatus.Requested, start, end, 0, 0));
        passengerRides[msg.sender].push(rideId);
        emit RideRequested(msg.sender, rideId);
    }

    function acceptRide(uint256 _rideId) external {
        require(_rideId < rides.length, "Invalid ride ID");
        require(msg.sender != rides[_rideId].driver, "You cannot accept your own ride");
        require(rides[_rideId].status == RideStatus.Requested, "Ride is not available for acceptance");

        rides[_rideId].driver = msg.sender;
        rides[_rideId].status = RideStatus.Accepted;
        rides[_rideId].startTime = block.timestamp; // Record start time
        driverRides[msg.sender].push(_rideId);

        emit RideAccepted(_rideId);
    }

    function completeRide(uint256 _rideId) external {
        require(_rideId < rides.length, "Invalid ride ID");
        require(msg.sender == rides[_rideId].driver, "Only the driver can complete the ride");
        require(rides[_rideId].status == RideStatus.InProgress, "Ride is not in progress");

        rides[_rideId].status = RideStatus.Completed;
        rides[_rideId].endTime = block.timestamp; // Record end time

        // Calculate and transfer payment to the driver
        payable(msg.sender).transfer(rides[_rideId].fare);

        emit RideCompleted(_rideId);
    }

    function cancelRide(uint256 _rideId) external {
        require(_rideId < rides.length, "Invalid ride ID");
        require(msg.sender == rides[_rideId].passenger, "Only the passenger can cancel the ride");
        require(rides[_rideId].status == RideStatus.Requested, "Ride cannot be canceled");

        rides[_rideId].status = RideStatus.Canceled;

        // Refund the passenger
        payable(msg.sender).transfer(rides[_rideId].fare);

        emit RideCanceled(_rideId);
    }

    function getRideDetails(uint256 _rideId) external view returns (Ride memory) {
        require(_rideId < rides.length, "Invalid ride ID");
        return rides[_rideId];
    }
}
