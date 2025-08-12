// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/**
 * @title SchemaForge
 * @author Huawei123r
 * @notice This contract is a registry for API schemas. It maps a human-readable
 * name for an API endpoint to its technical details, such as the URL template,
 * expected data keys, and the address of a specific parser contract.
 * This allows for a more organized and secure way to manage API integrations.
 */
contract SchemaForge is UUPSUpgradeable, OwnableUpgradeable {

    // Struct to define the schema for a specific API endpoint.
    struct ApiSchema {
        string[] urlParts;          // The static parts of the URL, e.g., ["https://api.example.com/data?id=", "&key="]
        string[] keyPlaceholders;   // The names of the keys for the dynamic parts, e.g., ["id", "apiKey"]
        string[] requiredKeys;      // A list of keys expected in the JSON response.
        address responseParser;     // The address of the contract responsible for parsing the response (e.g., a specific Sanctifier).
        bool isDefined;             // To check if a schema has been initialized.
    }

    // Mapping from a schema ID (a hash of its name) to the ApiSchema struct.
    mapping(bytes32 => ApiSchema) public schemas;

    // Event emitted when a new schema is registered or updated.
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
     * @dev Only the contract owner can call this function.
     * @param _name The human-readable name for the schema (e.g., "WeatherByCity").
     * @param _urlParts The static parts of the URL template.
     * @param _keyPlaceholders The names of the keys for the dynamic parts.
     * @param _requiredKeys The list of keys expected in the response.
     * @param _responseParser The address of the parser contract.
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
     * @param _name The name of the schema to retrieve.
     * @return The ApiSchema struct.
     */
    function getSchema(string memory _name) public view returns (ApiSchema memory) {
        bytes32 schemaId = getSchemaId(_name);
        return schemas[schemaId];
    }

    /**
     * @notice Computes the schema ID from a name.
     * @param _name The name of the schema.
     * @return The keccak256 hash of the name, used as the ID.
     */
    function getSchemaId(string memory _name) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name));
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    uint256[50] private __gap;
}
