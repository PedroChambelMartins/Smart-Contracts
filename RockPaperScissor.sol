pragma solidity ^0.6.0;

contract RockPaperScissors {

    struct Player {
        address payable addr;
        bytes32 commit;
        uint choice;
        bool hasRevealed;
    }
    
    Player[2] public players;
    uint public numPlayers;
    uint public reward;
    uint[3][3] rules;
    uint startTime;

    constructor() public {
        numPlayers = 0;
        reward = 0;
        
        //rock == 0 
        //paper == 1
        //scissors == 2
        //c0 and c1 are choices of players 0 and 1, respectively
        //rules [c0][c1] = winning player (0 or 1) or tie (2)
        rules[0][0] = 2;
        rules[0][0] = 2;
        rules[0][1] = 1;
        rules[0][2] = 0;
        rules[1][0] = 0;
        rules[1][1] = 2;
        rules[1][2] = 1;
        rules[2][0] = 1;
        rules[2][1] = 0;
        rules[2][2] = 2;
        
        startTime = now;
    }
    
    //function to be removed (should be executed on the client side)
    function generateBind(uint choice, uint nonce) public pure returns (bytes32) {
        return sha256(abi.encodePacked(choice,nonce));
    }
    
    function playerInput(bytes32 commitment) public payable returns (bool) {
        if(numPlayers < 2 && msg.value >= 1000) {
            reward += 1000;
            players[numPlayers].addr = msg.sender;
            players[numPlayers].commit = commitment;
            players[numPlayers].hasRevealed = false;
            numPlayers = numPlayers + 1;
            
            if(msg.value > 1000) {
                msg.sender.transfer(msg.value-1000);
            }
            return true;
        } else {
            msg.sender.transfer(msg.value);
            return false;
        }
    }
    
    function revealChoice(uint choice, uint nonce) public returns (bool) {
        if (numPlayers < 2)
            return false;

        uint p;
        if(msg.sender == players[0].addr) {
            p = 0;
        } else if(msg.sender == players[1].addr) {
            p = 1;
        } else {
            return false;
        }
        
        if(sha256(abi.encodePacked(choice,nonce)) == players[p].commit 
           && !players[p].hasRevealed) {
            players[p].choice = choice;
            players[p].hasRevealed = true;
            return true;
        } else {
            return false;
        }
    }
    
    function finalize() public returns (int32) {
        if(players[0].hasRevealed && players[1].hasRevealed) {
            uint p0 = players[0].choice;
            uint p1 = players[1].choice;
        
            if(rules[p0][p1] == 0) {
                players[0].addr.transfer(reward);
                return 0;
            } else if(rules[p0][p1] == 1) {
                players[1].addr.transfer(reward);
                return 1;
            } else {
                players[0].addr.transfer(reward/2);
                players[1].addr.transfer(reward/2);
                return 2;            
            }
        } else if((now > startTime + 1 days) 
                  && (players[0].hasRevealed || players[1].hasRevealed)) {
            uint pRevealed = 0;
            if(players[1].hasRevealed) {
                pRevealed = 1;
            }
            
            players[pRevealed].addr.transfer(reward);
            return int32(pRevealed);
        } else {
            return -1;
        }
    }
}
