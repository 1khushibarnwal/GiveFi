
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 *  GiveFi — A Simple On-Chain Donation Tracker 💖
 *  ------------------------------------------------
 *  Features:
 *  ✅ Owner can add verified causes (e.g., NGOs, campaigns)
 *  ✅ Donors can donate ETH directly to causes
 *  ✅ Every donation is recorded on-chain (transparent)
 *  ✅ Anyone can view donation totals per cause
 *  
 *  ⚠️ Note: This is a simple educational version.
 *  Not audited — do NOT deploy to mainnet yet!
 */

contract GiveFi {
    address public owner;

    constructor() {
        owner = msg.sender; // Deployer becomes the owner
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // Each cause is verified by the owner
    struct Cause {
        string name;
        address payable wallet;
        uint256 totalDonations;
        bool verified;
    }

    // Mapping cause ID → Cause
    mapping(uint256 => Cause) public causes;
    uint256 public causeCount;

    // Mapping donor → total donated
    mapping(address => uint256) public donorTotal;

    // Events
    event CauseAdded(uint256 causeId, string name, address wallet);
    event DonationReceived(address donor, uint256 causeId, uint256 amount);

    // Add a verified cause (only by owner)
    function addCause(string calldata _name, address payable _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid wallet address");

        causeCount++;
        causes[causeCount] = Cause(_name, _wallet, 0, true);

        emit CauseAdded(causeCount, _name, _wallet);
    }

    // Donate ETH to a verified cause
    function donate(uint256 _causeId) external payable {
        Cause storage cause = causes[_causeId];
        require(cause.verified, "Cause not found or not verified");
        require(msg.value > 0, "Donation amount must be greater than 0");

        // Transfer ETH to cause's wallet
        (bool sent, ) = cause.wallet.call{value: msg.value}("");
        require(sent, "Donation transfer failed");

        // Track total donations
        cause.totalDonations += msg.value;
        donorTotal[msg.sender] += msg.value;

        emit DonationReceived(msg.sender, _causeId, msg.value);
    }

    // View cause details
    function getCause(uint256 _causeId)
        external
        view
        returns (string memory name, address wallet, uint256 total, bool verified)
    {
        Cause memory c = causes[_causeId];
        return (c.name, c.wallet, c.totalDonations, c.verified);
    }

    // Allow contract to receive ETH directly (optional)
    receive() external payable {}
}
