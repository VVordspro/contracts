// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "../../VVords/0_Diamond/libraries/AppStorage.sol";
import "../interfaces/ITemplate.sol";

library TemplateView {

    function templateAddress() internal view returns (address) {
        require(
            msg.sender == address(this),
            "TemplateView: fallback is forbidden for external call."
        );
        require(
            msg.sig == ITemplate.checkIfRenderable.selector ||
            msg.sig == ITemplate.renderImage.selector,
            "only template view function is allowed"
        );
        uint256 tokenId = abi.decode(msg.data[4:36], (uint256));
        return AppStorage.layout().templates[AppStorage.layout().words[tokenId].info.templateId].contAddr;
    }

    function renderImage(uint256 tokenId)
        internal
        view
        returns(string memory)
    {
        (bool success, bytes memory data) = address(this).staticcall(
            abi.encodeWithSelector(
                ITemplate.renderImage.selector,
                tokenId
            )
        );

        require(success, "unable to generate the template");
        return(abi.decode(data, (string)));
    }

    function checkIfRenderable(uint256 tokenId, string[] calldata word)
        internal
        view
    {
        (bool success, ) = address(this).staticcall(
            abi.encodeWithSelector(
                ITemplate.checkIfRenderable.selector,
                tokenId,
                word
            )
        );

        require(success, "unable check the template");
    }
}