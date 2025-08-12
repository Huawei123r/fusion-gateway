// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/**
 * @title LoreHooks
 * @author Huawei123r
 * @notice An optional module for creating on-chain events from external data.
 * @dev Can be used to trigger events based on keywords in API responses.
 */
contract LoreHooks is UUPSUpgradeable, OwnableUpgradeable {

    event LoreTriggered(
        bytes32 indexed triggerId,
        string narrative,
        string rawData
    );

    // Defines a trigger condition
    struct LoreTrigger {
        string keyword;
        string narrativeTemplate;
        bool isDefined;
    }

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
     * @dev Can only be called by the owner.
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
     * @notice Checks input data against a specific trigger.
     */
    function invokeLore(string memory _data, string memory _triggerName) public {
        bytes32 triggerId = keccak256(abi.encodePacked(_triggerName));
        LoreTrigger memory trigger = triggers[triggerId];

        if (trigger.isDefined) {
            // A more advanced implementation could use complex pattern matching.
            if (bytes(_data).length > 0 && contains(bytes(_data), bytes(trigger.keyword))) {
                emit LoreTriggered(triggerId, trigger.narrativeTemplate, _data);
            }
        }
    }

    /**
     * @notice Checks if a byte array contains a subarray.
     * @return True if the needle is found, false otherwise.
     */
    function contains(bytes memory _haystack, bytes memory _needle) internal pure returns (bool) {
        uint256 needleLength = _needle.length;
        if (needleLength == 0) {
            return true;
        }
        if (needleLength > _haystack.length) {
            return false;
        }
        for (uint i = 0; i <= _haystack.length - needleLength; i++) {
            bool found = true;
            for (uint j = 0; j < needleLength; j++) {
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
