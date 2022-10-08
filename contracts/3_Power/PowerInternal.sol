// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../0_diamond/libraries/AppStorage.sol";

abstract contract PowerInternal {

    event Dom(
        uint256 indexed tokenId,
        address indexed dommer,
        uint256 dommerPower,
        int256 value,
        int256 votingPower,
        string mention
    );

    event UpdateVariable(
        bytes32 indexed varName,
        uint256 value
    );

    event UpdateValue(
        uint256 indexed tokenId,
        uint256 value,
        uint256 power,
        uint256 totalValue,
        uint256 totalPower
    );

    event Withdraw(
        uint256 amount, 
        address receiver
    );


    function _dom(
        uint256 id,
        address tokenOwner,
        uint256 value,
        string calldata mention
    ) internal {
        AppStorage.Global storage global = AppStorage.layout().global;
        AppStorage.Setting storage setting = AppStorage.layout().setting;
        AppStorage.Word storage word = AppStorage.layout().words[id];

        require(
            value >= setting.minDomValue,
            "WordsInternal: minimum value error."
        );

        uint256 power = _powerCalculator(value * (10000 - setting.withdrawableValueFraction) / 10000);

        word.values.value += value;
        word.values.power += power;
        word.doms[word.domsCount++] = AppStorage.Dom(msg.sender, value, mention);

        _increaseUserPower(tokenOwner, power);
        _increaseTotalPower(power);
        _increaseTotalValue(value);

        emit UpdateValue(
            id, 
            word.values.value, 
            word.values.power, 
            global.totalValue, 
            global.totalPower
        );

        emit Dom(id, msg.sender, _userPower(msg.sender), int(value), 0, mention);
    }

////////// power ///////////
    

    function _powerDetails(address userAddr) internal view returns(
        uint256 stakingTime,
        uint256 userLastTransferTimestamp,
        uint256 timeToFullVotingPower,
        uint256 userLastVotingPowerRecorded,
        uint256 votingPowerSpent
    ) {
        AppStorage.Setting storage setting = AppStorage.layout().setting;
        AppStorage.User storage user = AppStorage.layout().users[userAddr];

        stakingTime = block.timestamp - user.lastTransferTimestamp;
        userLastTransferTimestamp = user.lastTransferTimestamp;
        timeToFullVotingPower = setting.timeToFullVotingPower;
        userLastVotingPowerRecorded = user.lastVotingPowerRecorded;
        votingPowerSpent = user.votingPowerSpent;
    }


    function _userVotingPower(address userAddr) internal view returns(uint256 votingPower) {
        AppStorage.Setting storage setting = AppStorage.layout().setting;
        AppStorage.User storage user = AppStorage.layout().users[userAddr];

        uint256 votingPowerMax = user.power * setting.votingPowerFraction / 10000;

        uint256 stakingTime = block.timestamp - user.lastTransferTimestamp;

        votingPower = votingPowerMax * stakingTime / setting.timeToFullVotingPower;

        votingPower += user.lastVotingPowerRecorded;
        votingPower -= user.votingPowerSpent;
        
        if(votingPower > votingPowerMax){
            votingPower = votingPowerMax;
        }
    }

    function _updateVotingPower(address userAddr) internal {
        AppStorage.User storage user = AppStorage.layout().users[userAddr];
        user.lastVotingPowerRecorded = _userVotingPower(userAddr) + user.votingPowerSpent;
        user.lastTransferTimestamp = block.timestamp;
    } 

    function _spendVotingPower(address userAddr, uint256 spendingAmount) internal {
        AppStorage.User storage user = AppStorage.layout().users[userAddr];
        _updateVotingPower(userAddr);
        uint256 votingPower = _userVotingPower(userAddr);
        require(spendingAmount <= votingPower);
        user.votingPowerSpent += spendingAmount;
    } 
    
    function _userVotingPowerMax(address userAddr) internal view returns(uint256 votingPowerMax) {
        AppStorage.Setting storage setting = AppStorage.layout().setting;
        AppStorage.User storage user = AppStorage.layout().users[userAddr];

        votingPowerMax = user.power * setting.votingPowerFraction / 10000;
    }

    function _cardPower(uint256 tokenId) internal view returns(uint256) {
        return AppStorage.layout().words[tokenId].values.power;
    }

    function _userPower(address userAddr) internal view returns(uint256) {
        return AppStorage.layout().users[userAddr].power;
    }

    function _totalPower() internal view returns(uint256) {
        return AppStorage.layout().global.totalPower;
    }

    function _increaseUserPower(address userAddr, uint256 amount) internal {
        _updateVotingPower(userAddr);
        AppStorage.layout().users[userAddr].power += amount;
    }

    function _increaseTotalPower(uint256 amount) internal {
        AppStorage.layout().global.totalPower += amount;
    }

    function _decreaseUserPower(address userAddr, uint256 amount) internal {
        _updateVotingPower(userAddr);
        AppStorage.layout().users[userAddr].power -= amount;
    }

    function _decreaseTotalPower(uint256 amount) internal {
        AppStorage.layout().global.totalPower -= amount;
    }

    function _powerCalculator(uint256 value) internal view returns(uint256 power) {
        // uint256 supply = _nextTokenId();
        // uint8 divisor = 1;
        // while(supply > 10) {
        //     supply /= 10;
        //     divisor *= 5;
        // }
        // power = value / divisor * 100;

        power = value * 8/10 *
            AppStorage.layout().global.totalPower /
            address(this).balance;
            
    }


/////////// value ///////////

    function _allowedValueRange() internal view returns(uint256 min, uint256 max) {
        AppStorage.Setting storage setting = AppStorage.layout().setting;
        AppStorage.Global storage global = AppStorage.layout().global;
        min = setting.minInitialValue;
        max = (global.nextTokenId + 1) * 10 ** 18;
    }

    function _increaseTotalValue(uint256 amount) internal {
        AppStorage.layout().global.totalValue += amount;
    }

    function _decreaseTotalValue(uint256 amount) internal {
        AppStorage.layout().global.totalValue -= amount;
    }

    function _withdraw(uint256 amount, address receiver) internal {
        payable(receiver).transfer(amount);
        emit Withdraw(amount, receiver);
    }

////////// setting /////////

    function _setMinInitialValue(uint256 minInitialValue) internal {
        AppStorage.layout().setting.minInitialValue = minInitialValue;
        emit UpdateVariable(bytes32(abi.encodePacked("minInitialValue")), minInitialValue);
    }

    function _setMinDomValue(uint256 minDomValue) internal {
        AppStorage.layout().setting.minDomValue = minDomValue;
        emit UpdateVariable(bytes32(abi.encodePacked("minDomValue")), minDomValue);
    }

    function _setTimeToFullVotingPower(uint256 timeToFullVotingPower) internal {
        AppStorage.layout().setting.timeToFullVotingPower = timeToFullVotingPower;
        emit UpdateVariable(bytes32(abi.encodePacked("timeToFullVotingPower")), timeToFullVotingPower);
    }

    function _setWithdrawableValueFraction(uint256 fractoin) internal {
        AppStorage.layout().setting.withdrawableValueFraction = fractoin;
        emit UpdateVariable(bytes32(abi.encodePacked("withdrawableValueFraction")), fractoin);
    }

    function _setVotingPowerFraction(uint256 fractoin) internal {
        AppStorage.layout().setting.votingPowerFraction = fractoin;
        emit UpdateVariable(bytes32(abi.encodePacked("votingPowerFraction")), fractoin);
    }
}