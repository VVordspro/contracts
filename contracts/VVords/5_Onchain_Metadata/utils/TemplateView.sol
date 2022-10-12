// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "../../../templates/interfaces/ITemplate.sol";

abstract contract TemplateView is Proxy {

    function generateImage(uint256 tokenId)
        internal
        view
        returns(string memory)
    {
        (bool success, bytes memory data) = address(this).staticcall(
            abi.encodeWithSelector(
                ITemplate.image.selector,
                tokenId
            )
        );

        require(success, "unable to generate the template");
        return(abi.decode(data, (string)));
    }

    function _beforeFallback() internal view override {
        require(
            msg.sender == address(this),
            "TemplateView: fallback is forbidden for external call."
        );
        (bytes4 imgSelector, ) = 
            abi.decode(msg.data, (bytes4, uint256));

        require(
            imgSelector == ITemplate.image.selector,
            "only image() view function  is allowed"
        );
    }
}