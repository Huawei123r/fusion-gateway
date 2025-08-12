// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/**
 * @title SchemaForge
 * @author Huawei123r
 * @notice A registry for API schemas, mapping a simple name to the endpoint's technical details.
 * @dev Helps organize and secure API integrations by defining URL structures and response parsers.
 */
contract SchemaForge is UUPSUpgradeable, OwnableUpgradeable {

    // Defines the schema for a specific API endpoint.
    struct ApiSchema {
        string[] urlParts;          // Static parts of the URL
        string[] keyPlaceholders;   // Dynamic parameter names
        string[] requiredKeys;      // Keys expected in the JSON response
        address responseParser;     // Optional contract for parsing the response
        bool isDefined;
    }

    // Maps a schema name hash to the ApiSchema struct.
    mapping(bytes32 => ApiSchema) public schemas;

    event SchemaRegistered(bytes32 indexed schemaId, string name);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    /**
     * @notice Registers or updates an API schema.
     * @dev Can only be called by the owner.
     */
    function registerSchema(
        string memory _name,
        string[] memory _urlParts,
        string[] memory _keyPlaceholders,
        string[] memory _requiredKeys,
        address _responseParser
    ) public onlyOwner {
        require(_urlParts.length == _keyPlaceholders.length + 1, "SchemaForge: Invalid template structure");
        bytes32 schemaId = getSchemaId(_name);
        schemas[schemaId] = ApiSchema({
            urlParts: _urlParts,
            keyPlaceholders: _keyPlaceholders,
            requiredKeys: _requiredKeys,
            responseParser: _responseParser,
            isDefined: true
        });
        emit SchemaRegistered(schemaId, _name);
    }

    /**
     * @notice Retrieves a schema by its name.
     */
    function getSchema(string memory _name) public view returns (ApiSchema memory) {
        bytes32 schemaId = getSchemaId(_name);
        return schemas[schemaId];
    }

    /**
     * @notice Computes the schema ID (keccak256 hash) from a name.
     */
    function getSchemaId(string memory _name) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    uint256[50] private __gap;
}
