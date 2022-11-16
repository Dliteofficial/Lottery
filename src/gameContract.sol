//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract gameContract {

    event gameStarted (uint _gameID, uint _maxPlayers, uint _entryFee);

    uint gameId;
    struct game{
        bool started;
        uint maxPlayers;
        uint entryFee;
        uint playerCount;
    }

    mapping (uint => game) gameDetails;
    mapping (uint => mapping (address => uint)) playerStake;

    //This function allows you to create a new game for
    //users to partake in...
    //@dev _maxPlayers represents the highest number of people who can
    // participate in game
    //@dev _entryFee records the amount of ETH that a user needs to join the game in wei
    function startGame (uint _maxPlayers, uint _entryFee) public{
        require(gameDetails[gameId].started == false, "Game with this ID has been Initialized!");
        
        gameDetails[gameId].started = true;
        gameDetails[gameId].maxPlayers = _maxPlayers;
        gameDetails[gameId].entryFee = _entryFee;

        emit gameStarted(gameID, gameDetails[gameId].maxPlayers, gameDetails[gameId].entryFee);

        gameId++;
    }
 
    function joinGame (uint _gameID) external payable {
        require(gameDetails[_gameID].started == true, "Game hasn't Started Yet!");
        require(gameDetails[_gameId].playerCount <= gameDetails[_gameID].maxPlayers);
    }

    function seePlayersStake (uint _gameId) public view returns (address [] player, uint [] stake){
        
    }
}