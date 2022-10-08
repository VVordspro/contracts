// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IERC1155, ERC1155Base, ERC1155BaseInternal } from './base/ERC1155Base.sol';
import { IERC1155Enumerable, ERC1155Enumerable } from './enumerable/ERC1155Enumerable.sol';
import { ERC1155EnumerableInternal } from './enumerable/ERC1155EnumerableInternal.sol';
import { IERC1155Metadata, ERC1155Metadata } from './metadata/ERC1155Metadata.sol';
import { ISolidStateERC1155 } from './ISolidStateERC1155.sol';
import { IERC2981 } from '../0_Diamond/interfaces/IERC2981.sol';
import { LibDiamond } from '../0_Diamond/libraries/LibDiamond.sol';
// import { WordsInternal } from '../2_words/WordsInternal.sol';
import { Pausable } from '@solidstate/contracts/security/Pausable.sol';


/**
 * @title SolidState ERC1155 implementation
 */
contract ERC1155SolidState is
    ISolidStateERC1155,
    ERC1155Base,
    ERC1155Enumerable,
    ERC1155Metadata,
    IERC2981,
    Pausable
    // WordsInternal
{
    function init() external {
        // _setName("VVords");
        // _setSymbol("VV");

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC1155).interfaceId] = true;
        ds.supportedInterfaces[type(IERC1155Enumerable).interfaceId] = true;
        ds.supportedInterfaces[type(IERC1155Metadata).interfaceId] = true;
    }

    function pause() public {
        LibDiamond.enforceIsContractOwner();
        _pause();
    }

    function unpause() public {
        LibDiamond.enforceIsContractOwner();
        _unpause();
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        public
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        return (address(this), (salePrice * 7) / 100);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        override(ERC1155BaseInternal, ERC1155EnumerableInternal)
        whenNotPaused
    {
        //     super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        // if(from != address(0)) {
        //     _updateVotingPower(from);
        // }
        // if(to != address(0)) {
        //     _updateVotingPower(to);
        // }
        // if(from != address(0) && to != address(0)) {
        //     uint256 idsPower;
        //     for(uint256 i; i < ids.length; i++) {
        //         idsPower += _cardPower(ids[i]);
        //     }
        //     _decreaseUserPower(from, idsPower);
        //     _increaseUserPower(to, idsPower);
        // }
    }

    function supportsInterface(bytes4 interfaceId)
        external
        view
        override
        returns (bool)
    {}
}