// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../0_Diamond/libraries/LibDiamond.sol";
import "../1_ERC1155SolidState/enumerable/ERC1155EnumerableInternal.sol";
import "./WordsInternal.sol";
import "../4_Chainlink_VRF/VRFInternal.sol";

/**
 *                                   .___      
 *      ___  _____  _____________  __| _/______
 *      \  \/ /\  \/ /  _ \_  __ \/ __ |/  ___/
 *       \   /  \   (  <_> )  | \/ /_/ |\___ \ 
 *        \_/    \_/ \____/|__|  \____ /____  >
 *                                    \/    \/ 
 */

contract Words is ERC1155EnumerableInternal, WordsInternal, VRFInternal {

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    function init() public {
        __wordsInternal_init();
    }
    
    function tokenTags(uint256 tokenId) public view returns(string[] memory) {
        return _tags(tokenId);
    }

    function tokenExternalURL(uint256 tokenId) public view returns(string memory) {
        return _externalURL(tokenId);
    }

    function wordHashCounter(string memory word) public view returns(uint256) {
        return _wordHashCounter(word);
    }

    function wordHashTokenId(
        string memory word,
        uint256 index
    ) public view returns(uint256) {
        return _wordHashTokenId(word, index);
    }

    function nextTokenId() public view returns(uint256) {
        return _nextTokenId();
    }

    function mintVVord1155(
        string[] calldata word, 
        string calldata tags,
        string calldata externalURL,
        address to
    ) public payable {
        uint256 paidAmount = msg.value;

        uint256 tokenId = _tokenIdIncrement();

        uint256 power = _powerCalculator(paidAmount);
        
        _safeMint(to, tokenId, power, "");

        _newWord(word, tags, externalURL, to, tokenId, paidAmount, power);

        requestRandomness(tokenId);
    }

    function burnVVord(address account, uint256 id, uint256 amount) public {
        require(
            account == msg.sender || _isApprovedForAll(account, msg.sender) ||
            msg.sender == LibDiamond.diamondStorage().contractOwner,
            "Word: access denyed"
        );
        _burn(account, id, amount);
        if(_totalSupply(id) == 0) {
            _takeBackWord(id, account);
        }
    }

    function dom(
        uint256 tokenId,
        string calldata mention
    ) public payable {
        _dom(
            tokenId,
            _authorOf(tokenId),
            msg.value,
            mention
        );
    }

    function setVarStr(
        uint256 tokenId,
        string calldata key,
        string calldata varStr
    ) public {
        require(msg.sender == _authorOf(tokenId), "access denied");
        _setVarStr(tokenId, key, varStr);
    }


// setting --------------------------------------------------

    // function setNotification(
    //     string calldata notification1,
    //     string calldata notification2
    // ) public onlyOwner {
    //     _setNotification(notification1, notification2);
    // }

    function setDefaultExternalURL(string calldata url) public onlyOwner {
        _setDefaultExternalURL(url);
    }

    function setInviteRequirement(bool inviteRequired) public onlyOwner {
        setInviteRequirement(inviteRequired);
    }
}