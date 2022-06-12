//Raffle
//Enter the lottery (paying some amount)
//Pick a random winner (verifiably random)
//Winner to be selected every X minutes -> completely automated
//Chainlink Oracle -> Randomness, Automates Execution (Chainlink Keeper)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error Raffle_NotEnoughETHEntered();

contract Raffle is VRFConsumerBaseV2{
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;

    event RaffleEnter(address indexed player);

    constructor(
        address vrfCoordinatorV2, 
        uint256 entranceFee, 
        bytes32 gasLane,
        uint64 subscriptionId
    ) VRFConsumerBaseV2(vrfCoordinatorV2){
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
    }

    function enterRaffle() public payable{
        if(msg.value < i_entranceFee){revert Raffle_NotEnoughETHEntered();}

        s_players.push(payable(msg.sender));

        emit RaffleEnter(msg.sender);
    }

    function requestRandomWinner() external {
        //Chainlink VRF is a 2 transaction process
        i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {

    }

    function getEntranceFee() public view returns(uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns(address) {
        return s_players[index];
    }
}

