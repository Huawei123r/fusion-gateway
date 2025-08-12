// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

import {SchemaForge} from "./SchemaForge.sol";

/**
 * @title FusionLinker
 * @author Huawei123r
 * @notice Core contract for fetching data from external HTTPS APIs.
 */
contract FusionLinker is UUPSUpgradeable, OwnableUpgradeable {

    // For dynamic URL construction
    struct KeyValuePair {
        string key;
        string value;
    }

    event ApiRequestInitiated(
        uint256 indexed requestId,
        address indexed initiator,
        string url,
        bytes body
    );

    event ResponseReceived(
        uint256 indexed requestId,
        uint256 statusCode,
        string responseBody
    );

    uint256 private nextRequestId;
    SchemaForge public schemaForge;

    struct Request {
        address initiator;
        string url;
        bytes body; // For POST requests
    }

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
     * @notice Constructs a URL from a schema and key-value parameters.
     */
    function constructUrl(string memory _schemaName, KeyValuePair[] memory _params) public view returns (string memory) {
        SchemaForge.ApiSchema memory schema = schemaForge.getSchema(_schemaName);
        require(schema.isDefined, "FusionLinker: Schema not found");
        require(schema.keyPlaceholders.length == _params.length, "FusionLinker: Incorrect number of parameters");

        string memory constructedUrl = schema.urlParts[0];
        for (uint i = 0; i < _params.length; i++) {
            // A more robust implementation would check all keys.
            require(keccak256(abi.encodePacked(schema.keyPlaceholders[i])) == keccak256(abi.encodePacked(_params[i].key)), string.concat("FusionLinker: Invalid parameter key ", _params[i].key));
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

        emit ApiRequestInitiated(requestId, msg.sender, url, "");
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

        emit ApiRequestInitiated(requestId, msg.sender, url, _body);
        return requestId;
    }

    /**
     * @notice Callback for the off-chain service to post the API response.
     * @dev This should only be callable by an authorized service.
     */
    function handleResponse(uint256 _requestId, uint256 _statusCode, string memory _responseBody) public {
        // TODO: Add access control to ensure only the off-chain service can call this.
        emit ResponseReceived(_requestId, _statusCode, _responseBody);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    uint256[50] private __gap;
}
