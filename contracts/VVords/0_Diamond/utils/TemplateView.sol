// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "../libraries/AppStorage.sol";
import "../../../templates/interfaces/ITemplate.sol";

abstract contract TemplateView {

    function _templateAddress() internal view returns (address) {
        require(
            msg.sender == address(this),
            "TemplateView: fallback is forbidden for external call."
        );
        require(
            msg.sig == ITemplate.checkIfRenderable.selector ||
            msg.sig == ITemplate.renderImage.selector,
            "only template view function is allowed"
        );
        uint256 tokenId = abi.decode(msg.data[4:], (uint256));
        return AppStorage.layout().templates[AppStorage.layout().words[tokenId].info.templateId].contAddr;
    }
}