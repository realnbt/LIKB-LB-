// SPDX-License-Identifier: NU GPLv3

pragma solidity ^0.8.8;

contract LIKB {
    // Token information
    string public name = "LIKB";
    string public symbol = "LB";
    uint8 public decimals = 18; // 18 decimals is the standard for BEP-20 tokens

    // Total supply of tokens
    uint256 public totalSupply;

    // Mapping of token balances for each address
    mapping(address => uint256) public balanceOf;

    // Mapping of allowances for each address to spend tokens on behalf of another address
    mapping(address => mapping(address => uint256)) public allowance;

    // Mapping to keep track of confirmed owners
    mapping(address => bool) public confirmedOwners;

    // Address of the contract owner
    address public owner;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipConfirmation(address indexed owner);

    // Modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Modifier to restrict access to only confirmed owners
    modifier onlyConfirmedOwner() {
        require(confirmedOwners[msg.sender], "Not a confirmed owner");
        _;
    }

    // Contract constructor
    constructor() {
        totalSupply = 100000000000 * 10**uint256(decimals);
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        confirmedOwners[msg.sender] = true;

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // Transfer tokens from sender to recipient
    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    // Approve spender to spend tokens on behalf of the owner
    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // Transfer tokens from one address to another on behalf of the owner
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    // Mint new tokens and assign to the recipient
    function mint(address to, uint256 value) external onlyOwner {
        require(to != address(0), "Invalid recipient address");
        balanceOf[to] += value;
        totalSupply += value;
        emit Mint(to, value);
        emit Transfer(address(0), to, value);
    }

    // Burn tokens from the caller's balance
    function burn(uint256 value) external {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        totalSupply -= value;
        emit Burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
    }

    // Transfer ownership of the contract to a new address
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        confirmedOwners[newOwner] = false;
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Confirm ownership by the pending owner
    function confirmOwnership() external {
        require(msg.sender == owner, "Only pending owner can confirm ownership");
        confirmedOwners[msg.sender] = true;
        emit OwnershipConfirmation(msg.sender);
    }
}
