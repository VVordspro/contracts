// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 * ========================= VERSION_1.0.0 ==============================
 *   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
 *   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
 *   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
 *   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
 *   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
 * ======================================================================
 *  ================ Open source smart contract on EVM =================
 *   ============== Verify Random Function by ChainLink ===============
 */

import "./utils/Swapper.sol";
import "./VRFInternal.sol";
import "../0_diamond/libraries/AppStorage.sol";

contract VRF is VRFInternal, Swapper {

    function init() external {
        //initial swap
        swap_MATIC_LINK677(vrfFee, 10 ** 17);
    }

    function linkBalance() public view returns(uint256) {
        return _linkBalance();
    }

    function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
        require(
            msg.sender == vrfCoordinator, 
            "Only VRFCoordinator can fulfill"
        );
        _fulfillRandomness(requestId, randomness);

        AppStorage.Word storage word = AppStorage.layout().words[_tokenId(requestId)];
        swap_MATIC_LINK677(word.values.initialValue / 10);
    }
}    