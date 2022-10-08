// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/VRFRequestIDBase.sol";
import "../0_diamond/libraries/AppStorage.sol";
import "./VRFStorage.sol";

abstract contract VRFInternal is VRFRequestIDBase {

    uint256 constant USER_SEED_PLACEHOLDER = 0;
    address constant vrfCoordinator = 0x3d2341ADb2D31f1c5530cDC622016af293177AE0; // on polygon mainnet
    LinkTokenInterface constant LINK = LinkTokenInterface(0xb0897686c545045aFc77CF20eC7A532E3120E0F1); // on polygon mainnet
    bytes32 constant keyHash = 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da;
    uint256 constant public vrfFee = 0.0001 * 10 ** 18; // 0.0001 LINK (Varies by network)
    
    event NewRandomResult(uint256 tokenId, uint256 randomness);

    function _linkBalance() internal view returns(uint256) {
        return LINK.balanceOf(address(this));
    }

    function requestRandomness(uint256 tokenId) internal {
        VRFStorage.Layout storage vrf = VRFStorage.layout();

        LINK.transferAndCall(vrfCoordinator, vrfFee, abi.encode(keyHash, USER_SEED_PLACEHOLDER));
        uint256 vRFSeed = makeVRFInputSeed(
            keyHash, 
            USER_SEED_PLACEHOLDER, 
            address(this), 
            vrf.nonces[keyHash]++
        );
        bytes32 requestId = makeRequestId(keyHash, vRFSeed);
        vrf.randomRequests[requestId] = tokenId;
    }

    function _tokenId(bytes32 requestId) internal view returns(uint256) {
        return VRFStorage.layout().randomRequests[requestId];
    }

    function _fulfillRandomness(bytes32 requestId, uint256 randomness) internal {
        _newRandomResult(VRFStorage.layout().randomRequests[requestId], randomness);
    }

    function _newRandomResult(uint256 tokenId, uint256 randomness) private {
        AppStorage.layout().words[tokenId].info.randomResult = randomness;
        emit NewRandomResult(tokenId, randomness);
    }
}