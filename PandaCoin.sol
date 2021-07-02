//SPDX-License-Identifier: UNLICENSED

//indicate to solidity which version we are using
pragma solidity ^0.8.2;

contract PandaCoin {
    //define a mapping, allow you to use a series of records, use an address to reference each record and map an integer
    mapping(address => uint) public balances;   //call this balances
    
    //For example, outer address is owner of token: 0x9812827409018209 
    //-> 0x21562371919847 => 10000 (this person can spend 10000 on your behalf)
    //-> 0x48184728349348 => 20000 (this person can spend 20000 on your behalf)
    //-> 0x64185701283403 => 30000 (this person can spend 30000 on your behalf)
    mapping(address => mapping(address => uint)) public allowance;  //nested mapping that takes intgers and calls this allowance
    

    uint public totalSupply = 10000 * 10 ** 18;    
    //want 10000 tokens, 1 token displayed = 10 ** 18, whereby "**" means power in solidity
    string public name = "My Token";    
    string public symbol = "PDA";   
    uint public decimals = 18;  //define the smallest fraction of token to transfer
    
    //emit an event-> data packages that is emitted from smart contracts and be consumed outside of smart contracts
    //smart contracts can emit events but cannot read pass events, wallets and external software listen to events instead
    //name of event: Transfer, indexed means to filter this event outside the blockchain, get event for from field to recipient with transferred tokens
    
    event Transfer(address indexed from, address indexed to, uint value);   //declaring the event
    event Approval(address indexed owner, address indexed spender, uint value); //declaring the event
    
    constructor() {     //code that is executed only once when smart contract is deployed
    
    //'msg.sender' is a built-in function by solidity, to get the address that sends the transaction
    //whoever deploy contract will receive all tokens, the sender of the transactions
    
        balances[msg.sender] = totalSupply;
    }
    
    //pass the address into the function 'balanceOf' with the name called owner
    //'view' to make it read only function
    //return an integer
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
     /* TRANSFERRING TOKENS */
     
    //to transfer tokens from one address to another address
    //the function name 'transfer' is not random but required function mentioned in bp20 standard
    //has 2 arguments- recipient address and how much tokens (in fractions-> 1 * 10 ** 18) to transfer
    //public and return boolean value, no 'view' keyword as it's not read-only but modify data on the blockchain
    
    function transfer(address to, uint value) public returns (bool) {   
        
        //'require' statement test a logical condition, 
        //whether the tokens of sender is more or equal to the value that we want to transfer 
        //if true then execute, otherwise error message 'balance too low' and transaction is cancelled
        
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;      //update the balance mapping
        balances[msg.sender] -= value;  //update the balance of sender  
        emit Transfer(msg.sender, to, value);   //emitting the event (from field, recipient, transferred tokens)
        return true;    //specification of bep20 token, have to return a boolean value
    }
    
    /* DELEGATED TOKEN TRANSFERS */
    
    //to allow one address to spend tokens on behalf of another address
    //instead of sending tokens directly to address of smart contract, you allow smart contract to spend tokens on your behalf and then the contract from its code pulls the tokens from your address to its own address
    
    //function to set delegated transfers:
    
    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(balanceOf(from) >= value, 'balance too low');   //make sure owner has enough tokens 
        require(allowance[from][msg.sender] >= value, 'allowance too low'); //to check the sender of this transaction is an approved spender by the 'from' address
        balances[to] += value;  //balances of the recipient increments in value
        balances[from] -= value;    //balances of the owner of token decrease in value;
        emit Transfer(from, to, value);     //emit Transfer event but NOT from 'msg.sender' because 'msg.sender' is allowed spender but not the token owner
        return true;
    }
    
    //function to set allowance with declared variables:

    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;     //meaning that 'spender' is allowed to spend how much 'value' that belongs to 'msg.sender'
        emit Approval(msg.sender, spender, value);  //emitting the event (address of owner, spender, value)
        return true;
    }
}