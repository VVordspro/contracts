// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface ITemplate {
    function image(uint256 tokenId) external view returns (string memory);
}