// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library AppStorage {

    bytes32 constant APP_STORAGE_POSITION = keccak256("APP_STORAGE_POSITION");

    function layout() internal pure returns (Layout storage ds) {
        bytes32 position = APP_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    struct Layout {
        Setting setting;
        Global global;
        mapping(uint256 => Word) words;
        mapping(address => User) users;
        mapping(bytes32 => WordHash) wordHashes;
        mapping(uint256 => Template) templates;
    }

// global -------------------------------------
    struct Global {
        uint256 initialBlock;
        uint256 nextTokenId;
        uint256 totalValue;
        uint256 totalPower;
    }

// setting -------------------------------------
    struct Setting{
        uint256 minInitialValue;
        uint256 minDomValue;
        uint256 withdrawableValueFraction; //denominator is 10,000
        uint256 votingPowerFraction; //denominator is 10,000
        uint256 timeToFullVotingPower;
        string defaultExternalURL;
        string notification1;
        string notification2;
        bool inviteRequired;
    }

// words --------------------------------------
    struct Word {
        string[] word;
        WordInfo info;
        WordValues values;
        mapping(bytes32 => EternalStorage) es;
        uint256 domsCount;
        mapping(uint256 => Dom) doms;
    }

    struct EternalStorage {
        bool varBool;
        uint256 varUint;
        int256 varInt;
        address varAddr;
        string varStr;
    }

    struct WordInfo {
        string tags;
        string externalURL;
        address author;
        uint256 blockNumber;
        uint256 randomResult;
        uint256 templateId;
    }

    struct WordValues{
        uint256 initialValue;
        uint256 initialPower;
        uint256 value;
        uint256 power;
    }

    struct Dom{
        address dommer;
        uint256 amount;
        string mention;
    }

// User ---------------------------------------------
    struct User {
        uint256 power;
        uint256 lastVotingPowerRecorded;
        uint256 lastTransferTimestamp;
        uint256 votingPowerSpent;
    }

// WordHash ---------------------------------------------
    struct WordHash {
        mapping(uint256 => uint256) indexToId;
        mapping(uint256 => uint256) idToIndex;
        uint256 wordHashCounter;
    }

// Template ---------------------------------------------
    struct Template {
        address contAddr;
        address creator;
        uint256 price;
        string description;
        uint[] charCount;
    }

}