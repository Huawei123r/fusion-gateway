// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {SchemaForge} from "../src/SchemaForge.sol";

contract SchemaForgeTest is Test {
    SchemaForge public schemaForge;
    address owner;
    address nonOwner;
    string schemaName = "TestSchema";
    address responseParser = address(0x123);

    function setUp() public {
        owner = address(this);
        nonOwner = address(0x456);

        // Deploy the implementation contract
        SchemaForge schemaForgeImpl = new SchemaForge();

        // Prepare the initialize call data
        bytes memory initData = abi.encodeWithSelector(SchemaForge.initialize.selector, owner);

        // Deploy the proxy
        ERC1967Proxy proxy = new ERC1967Proxy(address(schemaForgeImpl), initData);
        // Attach the SchemaForge interface to the proxy address
        schemaForge = SchemaForge(address(proxy));
    }

    function testRegisterSchema() public {
        string[] memory urlParts = new string[](2);
        urlParts[0] = "https://example.com/";
        urlParts[1] = "/data";
        string[] memory keyPlaceholders = new string[](1);
        keyPlaceholders[0] = "id";
        string[] memory requiredKeys = new string[](2);
        requiredKeys[0] = "key1";
        requiredKeys[1] = "key2";

        schemaForge.registerSchema(schemaName, urlParts, keyPlaceholders, requiredKeys, responseParser);
        
        SchemaForge.ApiSchema memory schema = schemaForge.getSchema(schemaName);

        assertTrue(schema.isDefined);
        assertEq(schema.urlParts.length, 2);
        assertEq(schema.keyPlaceholders.length, 1);
        assertEq(schema.requiredKeys.length, 2);
        assertEq(schema.responseParser, responseParser);
    }

    function testRegisterSchemaByNonOwner() public {
        string[] memory urlParts;
        string[] memory keyPlaceholders;
        string[] memory requiredKeys;
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, nonOwner));
        schemaForge.registerSchema(schemaName, urlParts, keyPlaceholders, requiredKeys, responseParser);
    }

    function testRegisterSchemaInvalidTemplate() public {
        string[] memory invalidUrlParts = new string[](1);
        invalidUrlParts[0] = "https://example.com/";
        string[] memory keyPlaceholders = new string[](1);
        keyPlaceholders[0] = "id";
        string[] memory requiredKeys;
        vm.expectRevert("SchemaForge: Invalid template structure");
        schemaForge.registerSchema(schemaName, invalidUrlParts, keyPlaceholders, requiredKeys, responseParser);
    }

    function testGetSchemaId() public {
        bytes32 expectedId = keccak256(abi.encodePacked(schemaName));
        bytes32 actualId = schemaForge.getSchemaId(schemaName);
        assertEq(actualId, expectedId);
    }

    function testGetSchemaNotRegistered() public {
        SchemaForge.ApiSchema memory schema = schemaForge.getSchema("NonExistentSchema");
        assertFalse(schema.isDefined);
    }
}
