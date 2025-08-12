// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/**
 * @title Sanctifier
 * @author Huawei123r
 * @notice This contract is responsible for parsing and sanitizing data returned
 * by the FusionLinker. It provides utility functions to extract values from
 * JSON responses and ensure they are safe to use in other contracts.
 *
 * NOTE: On-chain JSON parsing is a complex and gas-intensive operation.
 * This implementation provides a basic parser for simple, flat JSON objects.
 * It does not support nested objects or arrays.
 */
contract Sanctifier is UUPSUpgradeable, OwnableUpgradeable {

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }



    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    /**
     * @notice Parses a simple, flat JSON string to extract a string value for a given key.
     * @param _json The JSON string to parse.
     * @param _key The key to find.
     * @return The string value associated with the key.
     */
    function extractString(string memory _json, string memory _key) public pure returns (string memory) {
        uint256 startIndex = findKey(_json, _key);
        if (startIndex == 0) {
            return ""; // Key not found
        }

        // Find the opening quote of the value
        uint256 valueStartIndex = findNextChar(_json, '"', startIndex);
        if (valueStartIndex == 0) {
            return ""; // Malformed JSON
        }
        valueStartIndex++; // Move past the quote

        // Find the closing quote of the value
        uint256 valueEndIndex = findNextChar(_json, '"', valueStartIndex);
        if (valueEndIndex == 0) {
            return ""; // Malformed JSON
        }

        return substring(_json, valueStartIndex, valueEndIndex);
    }

    /**
     * @notice Parses a simple, flat JSON string to extract a uint value for a given key.
     * @param _json The JSON string to parse.
     * @param _key The key to find.
     * @return The uint value associated with the key.
     */
    function extractUint(string memory _json, string memory _key) public pure returns (uint256) {
        uint256 startIndex = findKey(_json, _key);
        if (startIndex == 0) {
            return 0; // Key not found
        }

        // Find the start of the number
        uint256 valueStartIndex = findNextNumericChar(_json, startIndex);
        if (valueStartIndex == 0) {
            return 0; // Malformed JSON
        }

        // Find the end of the number
        uint256 valueEndIndex = findNextNonNumericChar(_json, valueStartIndex);
        if (valueEndIndex == 0) {
            valueEndIndex = bytes(_json).length;
        }

        return parseInt(substring(_json, valueStartIndex, valueEndIndex));
    }

    // Internal helper functions

    function findKey(string memory _json, string memory _key) internal pure returns (uint256) {
        bytes memory jsonBytes = bytes(_json);
        bytes memory keyBytes = bytes(_key);
        bytes memory pattern = new bytes(keyBytes.length + 2);
        pattern[0] = '"';
        for (uint i = 0; i < keyBytes.length; i++) {
            pattern[i + 1] = keyBytes[i];
        }
        pattern[keyBytes.length + 1] = '"';

        uint256 keyIndex = find(jsonBytes, pattern);
        if (keyIndex == jsonBytes.length) {
            return 0;
        }

        return keyIndex + pattern.length;
    }

    function find(bytes memory _haystack, bytes memory _needle) internal pure returns (uint) {
        uint256 needleLength = _needle.length;
        if (needleLength == 0) return 0;
        for (uint i = 0; i <= _haystack.length - needleLength; i++) {
            bool found = true;
            for (uint j = 0; j < needleLength; j++) {
                if (_haystack[i + j] != _needle[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return i;
        }
        return _haystack.length;
    }

    function findNextChar(string memory _s, bytes1 _c, uint256 _startIndex) internal pure returns (uint256) {
        bytes memory sBytes = bytes(_s);
        for (uint i = _startIndex; i < sBytes.length; i++) {
            if (sBytes[i] == _c) {
                return i;
            }
        }
        return 0;
    }

    function findNextNumericChar(string memory _s, uint256 _startIndex) internal pure returns (uint256) {
        bytes memory sBytes = bytes(_s);
        for (uint i = _startIndex; i < sBytes.length; i++) {
            if (sBytes[i] >= '0' && sBytes[i] <= '9') {
                return i;
            }
        }
        return 0;
    }

    function findNextNonNumericChar(string memory _s, uint256 _startIndex) internal pure returns (uint256) {
        bytes memory sBytes = bytes(_s);
        for (uint i = _startIndex; i < sBytes.length; i++) {
            if (sBytes[i] < '0' || sBytes[i] > '9') {
                return i;
            }
        }
        return 0;
    }

    function substring(string memory _s, uint256 _startIndex, uint256 _endIndex) internal pure returns (string memory) {
        bytes memory sBytes = bytes(_s);
        bytes memory result = new bytes(_endIndex - _startIndex);
        for (uint i = _startIndex; i < _endIndex; i++) {
            result[i - _startIndex] = sBytes[i];
        }
        return string(result);
    }

    function parseInt(string memory _s) internal pure returns (uint256) {
        bytes memory b = bytes(_s);
        uint256 result = 0;
        for (uint i = 0; i < b.length; i++) {
            if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
            }
        }
        return result;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    uint256[50] private __gap;
}
