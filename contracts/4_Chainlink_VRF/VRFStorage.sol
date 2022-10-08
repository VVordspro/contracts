// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

library VRFStorage {

    bytes32 constant VRF_STORAGE_POSITION = keccak256("VRF_STORAGE_POSITION");

    struct Layout {
        mapping(bytes32 => uint256) nonces;
        mapping(bytes32 => uint256) randomRequests;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = VRF_STORAGE_POSITION;
        assembly {
            l.slot := slot
        }
    }
}