pragma solidity =0.5.16;

import '../AegisV2ERC20.sol';

contract ERC20 is AegisV2ERC20 {
    constructor(uint _totalSupply) public {
        _mint(msg.sender, _totalSupply);
    }
}
