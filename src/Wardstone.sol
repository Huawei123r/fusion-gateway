// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/**
 * @title Wardstone
 * @author Huawei123r
 * @notice Manages access control and API key authorization.
 * @dev Provides a basic authorization layer. A production system might need more granular RBAC.
 */
contract Wardstone is UUPSUpgradeable, OwnableUpgradeable {

    // Mapping from the hash of an API key to its authorization status.
    // Hashes are stored to avoid exposing raw keys on-chain.
    mapping(bytes32 => bool) private authorizedApiKeys;
    mapping(address => uint256) public lastRequestTimestamp;

    uint256 public constant RATE_LIMIT_PERIOD = 60 seconds;

    event ApiKeyAuthorizationChanged(bytes32 indexed apiKeyHash, bool isAuthorized);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    /**
     * @notice Authorizes a new API key by storing its hash.
     * @dev Can only be called by the owner.
     */
    function addApiKey(string memory _apiKey) public onlyOwner {
        bytes32 apiKeyHash = keccak256(abi.encodePacked(_apiKey));
        authorizedApiKeys[apiKeyHash] = true;
        emit ApiKeyAuthorizationChanged(apiKeyHash, true);
    }

    /**
     * @notice Revokes authorization for an API key.
     * @dev Can only be called by the owner.
     */
    function removeApiKey(string memory _apiKey) public onlyOwner {
        bytes32 apiKeyHash = keccak256(abi.encodePacked(_apiKey));
        authorizedApiKeys[apiKeyHash] = false;
        emit ApiKeyAuthorizationChanged(apiKeyHash, false);
    }

    /**
     * @notice Checks if an API key is currently authorized.
     */
    function isApiKeyAuthorized(string memory _apiKey) public view returns (bool) {
        bytes32 apiKeyHash = keccak256(abi.encodePacked(_apiKey));
        return authorizedApiKeys[apiKeyHash];
    }

    /**
     * @notice Checks if a user is allowed to make a request based on the rate limit.
     * @dev Updates the user's last request timestamp if the check passes.
     */
    function checkRateLimit(address _user) public {
        require(block.timestamp >= lastRequestTimestamp[_user] + RATE_LIMIT_PERIOD, "Wardstone: Rate limit exceeded");
        lastRequestTimestamp[_user] = block.timestamp;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    uint256[50] private __gap;
}
