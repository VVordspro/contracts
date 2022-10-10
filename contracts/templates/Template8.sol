// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../VVords/0_Diamond/libraries/AppStorage.sol";
import '@solidstate/contracts/utils/UintUtils.sol';
import "@openzeppelin/contracts/utils/Base64.sol";
import "../VVords/5_Onchain_Metadata/utils/UintToFloatString.sol";
import "../VVords/5_Onchain_Metadata/utils/SVGTextValidator.sol";
import "../VVords/2_Words/utils/StringUtils.sol";

contract Template8 {
    using UintUtils for uint;
    using UintToFloatString for uint;
    using SVGTextValidator for string;
    using StringUtils for *;

    function image(uint256 tokenId) external view virtual returns (string memory) {
        AppStorage.Global storage global = AppStorage.layout().global;
        AppStorage.Setting storage setting = AppStorage.layout().setting;
        AppStorage.Word storage w = AppStorage.layout().words[tokenId];

        require(w.info.blockNumber != 0, "ERC721Metadata: URI query for nonexistent token");

        uint256 power = w.values.power;

        uint256 randomResult = w.info.randomResult;
        return _template({
            word1 : w.word[0].validate(),
            word2 : w.word[1].validate(),
            word3 : w.word[2].validate(),
            cardPower : power.floatString(18, 3),
            notification1 : setting.notification1,
            notification2 : bytes(setting.notification2).length > 0 ? setting.notification2 : 
            string.concat('First Goal : ',global.totalValue.floatString(18, 2),' of 8000 MATIC'),
            blockNumber : w.info.blockNumber.toString(),
            value : w.values.value.floatString(18, 2),
            points : randomResult % 2 == 0 ? _points(randomResult, power) : "",
            burned : w.values.value == 0
        }); 
    }

    function _template(
        string memory word1,
        string memory word2,
        string memory word3,
        string memory cardPower,
        string memory notification1,
        string memory notification2,
        string memory blockNumber,
        string memory value,
        string memory points,
        bool burned
    ) private pure returns(string memory) {      
        string memory imageString = string.concat(
            '<?xml version="1.0" encoding="utf-8"?><svg viewBox="150 0 700 1000" xmlns="http://www.w3.org/2000/svg"><defs><filter id="motion-blur-duotone" color-interpolation-filters="sRGB" x="-500%" y="-500%" width="1000%" height="1000%"><feGaussianBlur stdDeviation="7 0" edgeMode="none"/><feColorMatrix type="matrix" result="grayscale" values="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 1 0"/><feComponentTransfer result="duotone"><feFuncR type="table" tableValues="0.741 0.988"/><feFuncG type="table" tableValues="0.043 0.733"/><feFuncB type="table" tableValues="0.569 0.051"/><feFuncA type="table" tableValues="0 1"/></feComponentTransfer></filter><clipPath id="clip-path"><rect width="700" height="1000" x="150" y="0"/></clipPath><style>.cls-1{clip-path:url(#clip-path); font-family:Courier New;}.cls-2{stroke:#1d1d1b;}.cls-3{fill:none; stroke-miterlimit:10; stroke:#dadada;stroke-width:1px;}.cls-4{fill:#1b1718;opacity:0.97;}.cls-5{font-size: 70px;}.cls-6{font-size: 32px; fill:#fff; font-family:Courier New;}.cls-7{font-size: 50px; fill:#fff;}.cls-8{font-size: 35px;}.cls-9{font-size: 40px;}.cls-10{fill:#99cf29; font-size: 35px; font-family:CourierNewPSMT}</style></defs><g class="cls-1"',
            burned ?   ' style="filter: url(#motion-blur-duotone);"' : '',
            '><rect class="cls-2" x="150" y="0" width="700" height="1000"/><polyline class="cls-3" points="',
            points,
            '"/><rect class="cls-4" x="150" y="0" width="700" height="210"/><rect class="cls-4" x="150" y="800" width="700" height="200"/><text class="cls-5" x="180" y="95" style="fill:#99cf29;">VVords</text><text class="cls-6" x="180" y="155">',
            word1,
            '<tspan x="180" y="195">',
            word2,
            '</tspan><tspan x="180" y="235" style="font-size: 16px;">',
            word3,
            '</tspan></text><text class="cls-7" x="180" y="600">',
            value,
            ' Matic</text><text class="cls-8" x="180" y="685" style="fill:#dd6400;">Block<tspan style="fill:#00e1f2;"> number</tspan><tspan style="fill:#a80054;"> ',
            blockNumber,
            '</tspan></text><text class="cls-9" x="180" y="750" style="fill:#99cf29;">Voting <tspan style="fill:#dd6400;" >Power </tspan><tspan style="fill:#00e1f2;">',
            cardPower,
            '</tspan></text><text class="cls-10" x="185" y="850" >notification<tspan x="180" y="910" style="font-size: 30px;">',
            notification1,
            '<tspan  x="180" y="955">',
            notification2,
            '</tspan></tspan></text></g></svg>'
        );
        
        return string.concat('data:image/svg+xml;base64,', Base64.encode(abi.encodePacked(imageString)));
    }

    function _points(uint256 hashNum, uint256 cardPower) private pure returns(string memory points) {
        cardPower /= 10 ** 17;
        uint256 numPoints;
        while (cardPower >= 10) {
            cardPower /= 10;
            numPoints ++;
        }
        numPoints = 10 * numPoints + cardPower;
        while(numPoints > 0) {
            if(hashNum > 1000) {
                points = string.concat(
                    points,
                    ((hashNum /= 100) % 100 * 10).toString(),
                    " "
                );
                numPoints--;
            }
        }
    }
}