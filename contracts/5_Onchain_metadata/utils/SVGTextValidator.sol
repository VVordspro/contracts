// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library SVGTextValidator {

    function validate(string memory input) internal pure returns(string memory output) {
        bytes memory inBytes = bytes(input);
        bool has;
        for (uint16 i; i < inBytes.length; i++) {
            if (inBytes[i] == 0x26){
                has = true;
            }
        }
        if(!has) {
            return input;
        } else {
            bytes memory outBytes;
            for (uint16 i; i < inBytes.length; i++) {
                outBytes = bytes.concat(outBytes, inBytes[i]);
                if(inBytes[i] == 0x26) {
                    outBytes = bytes.concat(outBytes, "amp;");
                }
            }
            return string(outBytes);
        }
    }
}