// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title Wardstone
 * @author Gemini
 * @notice This contract provides access control and rate limiting for the Fusion Gateway.
 * It allows the owner to manage a set of authorized API keys that can be required
 * to access certain FusionLinker functionalities.
 *
 * NOTE: This is a basic implementation. A production system might require more
 * granular permissions, role-based access control (RBAC), and more sophisticated
 * rate-limiting mechanisms (e.g., token bucket algorithm).
 */
contract Wardstone is Ownable {

    // Mapping from a keccak256 hash of an API key to a boolean indicating its validity.
    // We store hashes to avoid exposing the raw API keys on-chain.
    mapping(bytes32 => bool) private authorizedApiKeys;

    // Event emitted when an API key is added or removed.
    event ApiKeyAuthorizationChanged(bytes32 indexed apiKeyHash, bool isAuthorized);

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Authorizes a new API key.
     * @dev Only the contract owner can call this function.
     * The key is hashed before being stored.
     * @param _apiKey The API key to authorize.
     */
    function addApiKey(string memory _apiKey) public onlyOwner {
        bytes32 apiKeyHash = keccak256(abi.encodePacked(_apiKey));
        authorizedApiKeys[apiKeyHash] = true;
        emit ApiKeyAuthorizationChanged(apiKeyHash, true);
    }

    /**
     * @notice Revokes authorization for an API key.
     * @dev Only the contract owner can call this function.
     * @param _apiKey The API key to revoke.
     */
    function removeApiKey(string memory _apiKey) public onlyOwner {
        bytes32 apiKeyHash = keccak256(abi.encodePacked(_apiKey));
        authorizedApiKeys[apiKeyHash] = false;
        emit ApiKeyAuthorizationChanged(apiKeyHash, false);
    }

    /**
     * @notice Checks if a given API key is authorized.
     * @param _apiKey The API key to check.
     * @return True if the key is authorized, false otherwise.
     */
    function isApiKeyAuthorized(string memory _apiKey) public view returns (bool) {
        bytes32 apiKeyHash = keccak256(abi.encodePacked(_apiKey));
        return authorizedApiKeys[apiKeyHash];
    }

    /**
     * @dev Placeholder for rate-limiting logic. This could be implemented
     * using a mapping to track request timestamps or counters for each user/key.
     * For example: `mapping(address => uint256) public lastRequestTimestamp;`
     */
    function checkRateLimit(address /*_user*/) public pure returns (bool) {
        // Replace with actual rate-limiting logic.
        // For now, it always returns true.
        return true;
    }
}
