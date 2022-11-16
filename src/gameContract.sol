//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


//VRF Contracts imports..
import "lib/VRFContracts/ConfirmedOwner.sol";
import "lib/VRFContracts/VRFConsumerBaseV2.sol";
import "lib/VRFContracts/VRFCoordinatorV2Interface.sol";

contract gameContract is VRFConsumerBaseV2, ConfirmedOwner{

    event gameStarted (uint _gameID, uint _maxPlayers, uint _entryFee);
    event playerJoined (uint gameID, address player, uint stake);

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    uint gameId = 1;
    struct game{
        bool started;
        uint maxPlayers;
        uint entryFee;
        uint playerCount;
        uint totalStake;
    }

    struct players {
        address player;
        uint stake;
    }

    mapping (uint => game) gameDetails;
    mapping (uint => mapping (uint => players)) playerDetails;

    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;
    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 keyHash =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // For this example, retrieve 1 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1;

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    constructor (uint64 _subscriptionID) 
    VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D)//HARDCODED FOR GOERLI
    ConfirmedOwner(msg.sender){

        COORDINATOR = VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D);

        s_subscriptionId = _subscriptionID;
    }

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
        gameDetails[gameId].playerCount = 1;

        emit gameStarted(gameID, gameDetails[gameId].maxPlayers, gameDetails[gameId].entryFee);

        gameId++;
    }
 
    function joinGame (uint _gameID) external payable {
        require(gameDetails[_gameID].started == true, "Game hasn't Started Yet!");
        require(gameDetails[_gameID].playerCount <= gameDetails[_gameID].maxPlayers);
        
        require(msg.value >= gameDetails[_gameID].entryFee);

        gameDetails[_gameID].totalStake += msg.value;
        playerDetails[_gameID][gameDetails[_gameID].playerCount].player = msg.sender;
        playerDetails[_gameID][gameDetails[_gameID].playerCount].stake = msg.value;

        if(gameDetails[_gameID].playerCount == maxPlayers){
            getWinner(_gameID);
        }

        gameDetails[_gameID].playerCount++;

        emit playerJoined(_gameID, msg.sender, msg.value);
    }

    function seeGameDetails (uint _gameId) public view returns (address [] player, uint [] stake){
        for (uint i = 1; i <= gameDetails[_gameID].playerCount; i++){
            (player, stake) = (playerDetails[_gameId][i].player, playerDetails[_gameId][i].stake);
        }
    }

    function getWinner (uint _gameID) internal returns (uint winningLot) {
        requestRandomWords();
        winningLot = (lastRequestId % gameDetails[_gameID].maxPlayers) + 1;
        address winner = playerDetails[_gameID][winningLot].player;
        winner.transfer(gameDetails[_gameID].totalStake);
    }


                    /////////////////////////////////////
                    ////////// VRF HELPER FUNCTIONS /////
                    /////////////////////////////////////


    function requestRandomWords() internal returns (uint requestID) {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }
}