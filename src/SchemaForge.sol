// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title SchemaForge
 * @author Gemini
 * @notice This contract is a registry for API schemas. It maps a human-readable
 * name for an API endpoint to its technical details, such as the URL template,
 * expected data keys, and the address of a specific parser contract.
 * This allows for a more organized and secure way to manage API integrations.
 */
contract SchemaForge is Ownable {

    // Struct to define the schema for a specific API endpoint.
    struct ApiSchema {
        string urlTemplate;         // The URL, potentially with placeholders (e.g., "https://api.example.com/data?id={id}")
        string[] requiredKeys;      // A list of keys expected in the JSON response.
        address responseParser;     // The address of the contract responsible for parsing the response (e.g., a specific Sanctifier).
        bool isDefined;             // To check if a schema has been initialized.
    }

    // Mapping from a schema ID (a hash of its name) to the ApiSchema struct.
    mapping(bytes32 => ApiSchema) public schemas;

    // Event emitted when a new schema is registered or updated.
    event SchemaRegistered(bytes32 indexed schemaId, string name);

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Registers or updates an API schema.
     * @dev Only the contract owner can call this function.
     * @param _name The human-readable name for the schema (e.g., "WeatherByCity").
     * @param _urlTemplate The URL template for the API endpoint.
     * @param _requiredKeys The list of keys expected in the response.
     * @param _responseParser The address of the parser contract.
     */
    function registerSchema(
        string memory _name,
        string memory _urlTemplate,
        string[] memory _requiredKeys,
        address _responseParser
    ) public onlyOwner {
        bytes32 schemaId = getSchemaId(_name);
        schemas[schemaId] = ApiSchema({
            urlTemplate: _urlTemplate,
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
}
