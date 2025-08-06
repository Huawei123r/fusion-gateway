// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/**
 * @title LoreHooks
 * @author Gemini
 * @notice This contract is an optional module for the Fusion Gateway that allows
 * for the creation of narrative triggers and lore-rich events based on external data.
 * It can be used to invoke dynamic on-chain events in response to specific patterns
 * or values found in API responses.
 */
contract LoreHooks is UUPSUpgradeable, OwnableUpgradeable {

    // Event emitted when a specific lore-based condition is met.
    event LoreTriggered(
        bytes32 indexed triggerId,
        string narrative,
        string rawData
    );

    // Struct to define a lore trigger condition.
    struct LoreTrigger {
        string keyword;             // The keyword to search for in the data.
        string narrativeTemplate;   // The narrative to emit when the keyword is found.
        bool isDefined;
    }

    // Mapping from a trigger ID to its conditions.
    mapping(bytes32 => LoreTrigger) public triggers;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    /**
     * @notice Defines a new lore trigger.
     * @dev Only the contract owner can call this function.
     * @param _name A unique name for the trigger (e.g., "HighRainfallWarning").
     * @param _keyword The specific string to look for in the data.
     * @param _narrativeTemplate The story snippet to be emitted.
     */
    function setTrigger(string memory _name, string memory _keyword, string memory _narrativeTemplate) public onlyOwner {
        bytes32 triggerId = keccak256(abi.encodePacked(_name));
        triggers[triggerId] = LoreTrigger({
            keyword: _keyword,
            narrativeTemplate: _narrativeTemplate,
            isDefined: true
        });
    }

    /**
     * @notice Attempts to invoke a lore event by checking input data against all registered triggers.
     * @param _data The data to check for trigger keywords.
     * @param _triggerName The specific trigger to check against.
     */
    function invokeLore(string memory _data, string memory _triggerName) public {
        bytes32 triggerId = keccak256(abi.encodePacked(_triggerName));
        LoreTrigger memory trigger = triggers[triggerId];

        if (trigger.isDefined) {
            // This is a simple check. A more advanced implementation could use more complex pattern matching.
            if (bytes(_data).length > 0 && contains(bytes(_data), bytes(trigger.keyword))) {
                emit LoreTriggered(triggerId, trigger.narrativeTemplate, _data);
            }
        }
    }

    /**
     * @notice Checks if a smaller byte array is contained within a larger one.
     * @param _haystack The byte array to search within.
     * @param _needle The byte array to search for.
     * @return True if the needle is found, false otherwise.
     */
    function contains(bytes memory _haystack, bytes memory _needle) internal pure returns (bool) {
        if (_needle.length == 0) {
            return true;
        }
        if (_needle.length > _haystack.length) {
            return false;
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
                return true;
            }
        }
        return false;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    uint256[50] private __gap;
}
