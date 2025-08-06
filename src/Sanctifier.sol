// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/**
 * @title Sanctifier
 * @author Gemini
 * @notice This contract is responsible for parsing and sanitizing data returned
 * by the FusionLinker. It provides utility functions to extract values from
 * JSON responses and ensure they are safe to use in other contracts.
 *
 * NOTE: On-chain JSON parsing is a complex and gas-intensive operation.
 * This implementation provides a very basic and limited parser for demonstration
 * purposes. A production-ready version would require a more sophisticated
 * and gas-efficient parsing library or native pre-compiled contracts for JSON manipulation.
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
     * @notice Parses a simple, flat JSON string to extract the value of a given key.
     * @dev This function is intentionally simple and has significant limitations.
     * It does not support nested objects, arrays, or escaped characters.
     * It is designed to work with simple key-value pairs like `{"key":"value"}`.
     * @param _json The JSON string to parse.
     * @param _key The key to find within the JSON string.
     * @return The value associated with the key.
     */
    function extractString(string memory _json, string memory _key) public pure returns (string memory) {
        bytes memory jsonBytes = bytes(_json);
        bytes memory keyBytes = bytes(_key);

        // Construct the search pattern: "key":"
        bytes memory searchPattern = new bytes(keyBytes.length + 4);
        searchPattern[0] = '"';
        for (uint i = 0; i < keyBytes.length; i++) {
            searchPattern[i + 1] = keyBytes[i];
        }
        searchPattern[keyBytes.length + 1] = '"';
        searchPattern[keyBytes.length + 2] = ':';
        searchPattern[keyBytes.length + 3] = '"';


        // Find the starting position of the pattern
        uint256 startIndex = find(jsonBytes, searchPattern);
        if (startIndex == jsonBytes.length) {
            return ""; // Pattern not found
        }

        // Find the end of the value (the next double quote)
        uint256 endIndex = 0;
        for (uint i = startIndex + searchPattern.length; i < jsonBytes.length; i++) {
            if (jsonBytes[i] == '"') {
                endIndex = i;
                break;
            }
        }

        if (endIndex == 0) {
            return ""; // End of value not found
        }

        // Extract the value
        bytes memory result = new bytes(endIndex - (startIndex + searchPattern.length));
        for (uint j = 0; j < result.length; j++) {
            result[j] = jsonBytes[startIndex + searchPattern.length + j];
        }

        return string(result);
    }

    /**
     * @notice Finds the first occurrence of a smaller byte array within a larger one.
     * @param _haystack The byte array to search within.
     * @param _needle The byte array to search for.
     * @return The starting index of the needle, or the length of the haystack if not found.
     */
    function find(bytes memory _haystack, bytes memory _needle) internal pure returns (uint) {
        if (_needle.length == 0) {
            return 0;
        }
        if (_needle.length > _haystack.length) {
            return _haystack.length;
        }

        for (uint i = 0; i <= _haystack.length - _needle.length; i++) {
            bool found = true;
            for (uint j = 0; j < _needle.length; j++) {
                if (_haystack[i + j] != _needle[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return i;
            }
        }

        return _haystack.length;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    uint256[50] private __gap;
}
