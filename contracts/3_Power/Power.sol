// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../0_diamond/libraries/LibDiamond.sol";
import "../1_ERC1155SolidState/enumerable/ERC1155EnumerableInternal.sol";
import "./PowerInternal.sol";
import "../2_words/WordsInternal.sol";
import "../4_Chainlink_VRF/VRFInternal.sol";


contract Power is ERC1155EnumerableInternal, PowerInternal, VRFInternal {

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    function dom(
        uint256 tokenId,
        string calldata mention
    ) public payable {
        _dom(
            tokenId,
            AppStorage.layout().words[tokenId].info.author,
            msg.value,
            mention
        );
    }

////////// power //////////

    function powerDetails(address userAddr) public view returns(
        uint256 stakingTime,
        uint256 userLastTransferTimestamp,
        uint256 timeToFullVotingPower,
        uint256 userLastVotingPowerRecorded,
        uint256 votingPowerSpent
    ) {
        return _powerDetails(userAddr);
    }

    function userPower(address userAddr) public view returns(uint256) {
        return _userPower(userAddr);
    }

    function userVotingPower(address userAddr) public view returns(uint256) {
        return _userVotingPower(userAddr);
    }

    function userVotingPowerMax(address userAddr) public view returns(uint256) {
        return _userVotingPowerMax(userAddr);
    }

    function totalPower() public view returns(uint256) {
        return _totalPower();
    }

    function spendVotingPower(address userAddr, uint256 spendingAmount) public onlyOwner {
        _spendVotingPower(userAddr, spendingAmount);
    }

    function updateVotingPower(address userAddr) public {
        _updateVotingPower(userAddr);
    }

///////// value //////////

    function allowedValueRange() public view returns(uint256 min, uint256 max) {
        return _allowedValueRange();
    }


// setting --------------------------------------------------

    function contractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function setMinInitialValue(uint256 amount) public onlyOwner {
        _setMinInitialValue(amount);
    }

    function setMinDomValue(uint256 amount) public onlyOwner {
        _setMinDomValue(amount);
    }

    function setWithdrawableValueFraction(uint256 fractoin) public onlyOwner {
        _setWithdrawableValueFraction(fractoin);
    }

    function withdraw(uint256 amount, address receiver) public onlyOwner {
        _withdraw(amount, receiver);
    }
}