// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

import {SchemaForge} from "./SchemaForge.sol";

/**
 * @title FusionLinker
 * @author Huawei123r
 * @notice This contract is the core HTTP fetcher for the Fusion Gateway framework.
 * It provides a standardized interface for other smart contracts to request data
 * from external HTTPS APIs. It is designed to be modular and reusable.
 */
contract FusionLinker is UUPSUpgradeable, OwnableUpgradeable {

    // Struct to hold a key-value pair for dynamic URL construction.
    struct KeyValuePair {
        string key;
        string value;
    }

    // Event to be emitted when an API response is received.
    event ResponseReceived(
        uint256 indexed requestId,
        uint256 statusCode,
        string responseBody
    );

    // A counter to ensure unique request IDs.
    uint256 private nextRequestId;
    SchemaForge public schemaForge;

    // Struct to hold the details of each request.
    struct Request {
        address initiator;
        string url;
        bytes body; // Added for POST requests
    }

    // Mapping from request ID to the request details.
    mapping(uint256 => Request) public requests;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, address _schemaForgeAddress) public virtual initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        schemaForge = SchemaForge(_schemaForgeAddress);
    }

    /**
     * @notice Constructs a URL from a schema and a set of key-value pairs.
     */
    function constructUrl(string memory _schemaName, KeyValuePair[] memory _params) public view returns (string memory) {
        SchemaForge.ApiSchema memory schema = schemaForge.getSchema(_schemaName);
        require(schema.isDefined, "FusionLinker: Schema not found");
        require(schema.keyPlaceholders.length == _params.length, "FusionLinker: Incorrect number of parameters");

        string memory constructedUrl = schema.urlParts[0];
        for (uint i = 0; i < _params.length; i++) {
            // This is a simple check. A more robust implementation would check all keys.
            require(keccak256(abi.encodePacked(schema.keyPlaceholders[i])) == keccak256(abi.encodePacked(_params[i].key)), "FusionLinker: Invalid parameter key");
            constructedUrl = string(abi.encodePacked(constructedUrl, _params[i].value, schema.urlParts[i + 1]));
        }
        return constructedUrl;
    }

    /**
     * @notice Initiates an HTTP GET request using a schema.
     */
    function fetch(string memory _schemaName, KeyValuePair[] memory _params) public returns (uint256) {
        string memory url = constructUrl(_schemaName, _params);
        uint256 requestId = nextRequestId++;
        requests[requestId] = Request({
            initiator: msg.sender,
            url: url,
            body: ""
        });

        _handleResponse(requestId, 200, '{"success": true, "data": "mock_get_response"}');
        return requestId;
    }

    /**
     * @notice Initiates an HTTP POST request using a schema.
     */
    function post(string memory _schemaName, KeyValuePair[] memory _params, bytes memory _body) public returns (uint256) {
        string memory url = constructUrl(_schemaName, _params);
        uint256 requestId = nextRequestId++;
        requests[requestId] = Request({
            initiator: msg.sender,
            url: url,
            body: _body
        });

        _handleResponse(requestId, 200, '{"success": true, "data": "mock_post_response"}');
        return requestId;
    }

    /**
     * @notice Internal callback function to handle the API response.
     * @dev This function would be called by the Rialo runtime upon completion of the HTTP request.
     * @param _requestId The ID of the request being fulfilled.
     * @param _statusCode The HTTP status code of the response.
     * @param _responseBody The body of the HTTP response.
     */
    function _handleResponse(uint256 _requestId, uint256 _statusCode, string memory _responseBody) internal {
        // Here, you could add logic to parse or validate the response before emitting.
        // For now, we just emit the raw response.
        emit ResponseReceived(_requestId, _statusCode, _responseBody);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    uint256[50] private __gap;
}
