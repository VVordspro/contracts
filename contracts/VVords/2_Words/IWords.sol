// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IWords {

    function userPower(address userAddr) external view returns(uint256);

    function totalPower() external view returns(uint256);
}