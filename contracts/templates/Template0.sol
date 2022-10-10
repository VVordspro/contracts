// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Base64.sol";
import "../VVords/0_Diamond/libraries/AppStorage.sol";
import "./utils/SVGTextValidator.sol";

contract Template0 {
    using SVGTextValidator for string;

    function image(uint256 tokenId) public view returns (string memory) {
        AppStorage.Word storage w = AppStorage.layout().words[tokenId];

        require(w.info.blockNumber != 0, "ERC721Metadata: URI query for nonexistent token");

        return string.concat('data:image/svg+xml;base64,', Base64.encode(abi.encodePacked(
            _template({
                word1 : w.word[0].validate(),
                word2 : w.word[1].validate(),
                word3 : w.word[2].validate()
            })
        )));
    }

    function _template(
        string memory word1,
        string memory word2,
        string memory word3
    ) private pure returns(string memory) {      
        return string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1000" viewBox="0 0 1000 1000"><style>@font-face {font-family: "C";src: url("data:font/woff2;charset=utf-8;base64,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") format("woff2"); font-weight: 500; font-style: normal; font-display: swap;}.f { width: 100%; height: 100%; }.b { fill: whitesmoke; }.a { animation: o 2s ease-out forwards; }@keyframes o { 10% { opacity: 1; } 100% { opacity: 0; } }tspan { fill: black; font-family: "C"; font-size: 50px; text-anchor: middle; }.small { font-size: 25px;  }</style><rect class="b f" /><svg y="455" overflow="visible"><text><tspan x="500">',
            word1,
            '</tspan><tspan x="500" dy="1em">',
            word2,
            '</tspan><tspan class="small" x="500" dy="4em">',
            word3,
            '</tspan></text></svg><rect class="b f a" /></svg>'
        );
    }
}