// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../0_Diamond/libraries/AppStorage.sol";
import "../3_Power/PowerInternal.sol";
import "./utils/UTF8HoldingSpace.sol";
import "./utils/StringUtils.sol";
import '@solidstate/contracts/utils/UintUtils.sol';

abstract contract WordsInternal is PowerInternal {
    using AppStorage for AppStorage.Layout;
    using AppStorage for AppStorage.Word;
    using UTF8HoldingSpace for *;
    using UintUtils for uint;
    using StringUtils for *;

    event NewWord(
        uint256 indexed tokenId,
        address indexed author
    );

    function __wordsInternal_init() internal {
        // _setMinInitialValue(10 ** 18);
        // _setMinDomValue(10 ** 17);
        // _setWithdrawableValueFraction(8000); //denominator is 10,000
        // _setVotingPowerFraction(2000); //denominator is 10,000
        // _setTimeToFullVotingPower(30 days);
        // _initBlockNumber(block.number);

        // AppStorage.Word storage t = AppStorage.layout().words[9];
        // uint256 falsePower = t.power;
        // uint256 newPower = _powerCalculator(t.value);
        // t.initialPower = newPower;
        // t.power = newPower;
    }

    function _inviteRequired() internal view returns(bool) {
        return AppStorage.layout().setting.inviteRequired;
    }

    function _nextTokenId() internal view returns(uint256) {
        return AppStorage.layout().global.nextTokenId;
    }

    function _tokenIdIncrement() internal returns(uint256) {
        return AppStorage.layout().global.nextTokenId++;
    }

    function _tags(uint256 tokenId) internal view returns(string[] memory tagsArr) {
        string memory tagsStr = AppStorage.layout().words[tokenId].info.tags;
        
        StringUtils.slice memory s = tagsStr.toSlice();                
        StringUtils.slice memory delim = " ".toSlice();                            
        tagsArr = new string[](s.count(delim)+1);                  
        for (uint i = 0; i < tagsArr.length; i++) {                              
           tagsArr[i] = s.split(delim).toString();                               
        }                                                                      
    }

    function _externalURL(uint256 tokenId) internal view returns(string memory) {
        return AppStorage.layout().words[tokenId].info.externalURL;                                                              
    }

    function _authorOf(uint256 tokenId) internal view returns(address) {
        return AppStorage.layout().words[tokenId].info.author;
    }    
    
    function _newWord(
        string[] calldata word,
        string calldata tags,
        string calldata externalURL,
        address author,
        uint256 id,
        uint256 value,
        uint256 power
    ) internal {
        AppStorage.Global storage global = AppStorage.layout().global;
        AppStorage.Word storage w = AppStorage.layout().words[id];

        require(
            word.length <= 3,
            "WordsInternal: only three lines permited for this template."
        );
        
        require(
            word[0].checkLine(33) && word[1].checkLine(33) && word[2].checkLine(66),
            "WordsInternal: word lines overflow."
        );

        (uint256 min, uint256 max) = _allowedValueRange();
        require(
            value >= min,
            "WordsInternal: minimum value error."
        );
        require(
            w.values.value <= max,
            "WordsInternal: maximum value error."
        );

        address userAddr = msg.sender;

        w.word = word;
        w.info.tags = tags;
        w.info.externalURL = externalURL;
        w.info.author = author;
        w.info.blockNumber = block.number - global.initialBlock;
        w.values.initialValue = value;
        w.values.initialPower = power;
        w.values.value = value;
        w.values.power = power;

        _increaseUserPower(userAddr, power);
        _increaseTotalPower(power);
        _increaseTotalValue(value);

        _registerWord(word, id);

        emit NewWord(id, author);
        emit UpdateValue(id, value, power, global.totalValue, global.totalPower);
    }

    function _takeBackWord(uint256 tokenId, address valueReceiver) internal {
        AppStorage.Global storage global = AppStorage.layout().global;
        AppStorage.Setting storage setting = AppStorage.layout().setting;
        AppStorage.WordValues storage wv = AppStorage.layout().words[tokenId].values;

        uint256 paidValue = wv.value;
        uint256 withdrawableValue = paidValue * setting.withdrawableValueFraction / 10000;
        uint256 power = wv.power;

        _decreaseUserPower(valueReceiver, power);
        _decreaseTotalPower(power);
        _decreaseTotalValue(paidValue);


        delete wv.value;
        delete wv.power;

        payable(valueReceiver).transfer(withdrawableValue);

        emit UpdateValue(tokenId, 0, 0, global.totalValue, global.totalPower);
    }

////////// wordhash //////////

    function _registerWord(string[] calldata word, uint256 tokenId) internal {

        for(uint8 i; i<word.length; i++){
            _registerWordHash(word[i], tokenId);
        }

        string memory temp = string.concat(word[0], '/', word[1]);
        _registerWordHash(temp, tokenId);
        _registerWordHash(string.concat(word[1], '/', word[2]), tokenId);
        temp = string.concat(temp, '/', word[2]);
        require(
            _wordHashCounter(temp) == 0,
            string.concat(
                "WordsInternal: exact same word in tokenId ", 
                _wordHashTokenId(temp, 0).toString()
            )
        );
        _registerWordHash(temp, tokenId);
        
    }

    function _wordHashCounter(string memory word) internal view returns(uint256) {
        return AppStorage.layout().wordHashes[
            keccak256(abi.encodePacked(word))
        ].wordHashCounter;
    }

    function _wordHashTokenId(
        string memory word,
        uint256 index
    ) internal view returns(uint256) {
        return AppStorage.layout().wordHashes[
            keccak256(abi.encodePacked(word))
        ].indexToId[index];
    }

    function _registerWordHash(string memory word, uint256 tokenId) internal {
        AppStorage.WordHash storage w = AppStorage.layout().wordHashes[
            keccak256(abi.encodePacked(word))
        ];

        uint256 index = w.wordHashCounter++;
        w.indexToId[index] = tokenId;
        w.idToIndex[tokenId] = index;
    }

////////// setting /////////

    function _initBlockNumber(uint256 blockNumber) internal {
        AppStorage.layout().global.initialBlock = blockNumber;
        emit UpdateVariable(bytes32(abi.encodePacked("initialBlock")), blockNumber);
    }

    // function _setNotification(
    //     string calldata notification1,
    //     string calldata notification2
    // ) internal {
    //     AppStorage.layout().setting.notification1 = notification1;
    //     AppStorage.layout().setting.notification2 = notification2;
    // }

    function _setVarStr(
        uint256 tokenId,
        string calldata key,
        string calldata varStr
    ) internal {
        bytes32 bytesKey = keccak256(abi.encodePacked(key));
        AppStorage.layout().words[tokenId].es[bytesKey].varStr = varStr;
    }

    function _setDefaultExternalURL(string calldata url) internal {
        AppStorage.layout().setting.defaultExternalURL = url;
    }

    function _setInviteRequirement(bool inviteRequired) internal {
        AppStorage.layout().setting.inviteRequired = inviteRequired;
    }
}