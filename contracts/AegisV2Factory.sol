pragma solidity =0.5.16;

import './interfaces/IAegisV2Factory.sol';
import './AegisV2Pair.sol';

contract AegisV2Factory is IAegisV2Factory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(AegisV2Pair).creationCode));

    address public feeTo;
    address public feeToSetter;

    // lock core to be called only by the allowed router
    address public allowedCaller;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'AegisV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'AegisV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'AegisV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(AegisV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IAegisV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'AegisV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'AegisV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function setAllowedCaller(address _allowedCaller) external {
        require(msg.sender == feeToSetter, "AegisV2: FORBIDDEN");
        allowedCaller = _allowedCaller;
    }
}
