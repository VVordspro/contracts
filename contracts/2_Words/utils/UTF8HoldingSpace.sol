// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library UTF8HoldingSpace {

    function holdingSpace(
        string memory input
    ) internal pure returns(uint256) {

        uint256 char;
        uint256 len2;

        bytes memory inputBytes = bytes(input);

        while (char < inputBytes.length){
            if (inputBytes[char]>>7==0){
                char += 1;
                len2 += 2;
            } else if (inputBytes[char]>>5==bytes1(uint8(0x6))){
                char += 2;
                len2 += 2;
            } else if (inputBytes[char]>>4==bytes1(uint8(0xE))){
                char += 3;
                len2 += 3;
            } else if (inputBytes[char]>>3==bytes1(uint8(0x1E))){
                char += 4;
                len2 += 4;
            } else {
                //For safety
                char += 1;
                len2 += 2;
            }
        }
        return len2 / 2;
    }

    
    function numLines(
        string memory input,
        uint256 lenLimit
    ) internal pure returns(uint256 lineCount) {

        uint256 char;
        uint256 len2;
        uint256 lenLimit2 = lenLimit * 2;
        
        bytes memory inputBytes = bytes(input);

        if (inputBytes.length > 0) lineCount++;

        while (char < inputBytes.length) {

            if (inputBytes[char] == 0x5c && inputBytes[char+1] == 0x6e){
                lineCount ++;
                char += 2;
                len2 = 0;
                continue;
            } else if (len2 >= lenLimit2) {
                lineCount ++;
                len2 = 0;
            } 
            
            if (inputBytes[char]>>7==0){
                char += 1;
                len2 += 2;
            } else if (inputBytes[char]>>5==bytes1(uint8(0x6))){
                char += 2;
                len2 += 2;
            } else if (inputBytes[char]>>4==bytes1(uint8(0xE))){
                char += 3;
                len2 += 3;
            } else if (inputBytes[char]>>3==bytes1(uint8(0x1E))){
                char += 4;
                len2 += 4;
            } else {
                //For safety
                char += 1;
                len2 += 2;
            }
        }
    }
    
    function checkLine(
        string memory input,
        uint256 lenLimit
    ) internal pure returns(bool isFit) {
        isFit = true;

        uint256 char;
        uint256 len2;
        uint256 lenLimit2 = lenLimit * 2;

        bytes memory inputBytes = bytes(input);
    
        while (char < inputBytes.length) {
            if (len2 >= lenLimit2) {
                return false;
            } else if (inputBytes[char]>>7==0){
                char += 1;
                len2 += 2;
            } else if (inputBytes[char]>>5==bytes1(uint8(0x6))){
                char += 2;
                len2 += 2;
            } else if (inputBytes[char]>>4==bytes1(uint8(0xE))){
                char += 3;
                len2 += 3;
            } else if (inputBytes[char]>>3==bytes1(uint8(0x1E))){
                char += 4;
                len2 += 4;
            } else {
                //For safety
                char += 1;
                len2 += 2;
            }
        }
    }
    
    function checkLines(
        string[] memory input,
        uint256 lenLimit
    ) internal pure returns(bool allFit) {
        allFit = true;
        
        uint256 char;
        uint256 len2;
        uint256 lenLimit2 = lenLimit * 2;

        for(uint8 i; i < input.length; i++) {
            bytes memory inputBytes = bytes(input[i]);
    
            while (char < inputBytes.length) {
                if (len2 >= lenLimit2) {
                    return false;
                } else if (inputBytes[char]>>7==0){
                    char += 1;
                    len2 += 2;
                } else if (inputBytes[char]>>5==bytes1(uint8(0x6))){
                    char += 2;
                    len2 += 2;
                } else if (inputBytes[char]>>4==bytes1(uint8(0xE))){
                    char += 3;
                    len2 += 3;
                } else if (inputBytes[char]>>3==bytes1(uint8(0x1E))){
                    char += 4;
                    len2 += 4;
                } else {
                    //For safety
                    char += 1;
                    len2 += 2;
                }
            }

            char = 0;
            len2 = 0;
        }
    }
}