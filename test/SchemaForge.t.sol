// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {SchemaForge} from "../src/SchemaForge.sol";

contract SchemaForgeTest is Test {
    SchemaForge public schemaForge;
    address owner;
    address nonOwner;
    string schemaName = "TestSchema";
    string urlTemplate = "https://example.com/{id}";
    string[] requiredKeys = ["key1", "key2"];
    address responseParser = address(0x123);

    function setUp() public {
        schemaForge = new SchemaForge();
        owner = address(this);
        nonOwner = address(0x456);
    }

    function testRegisterSchema() public {
        schemaForge.registerSchema(schemaName, urlTemplate, requiredKeys, responseParser);
        SchemaForge.ApiSchema memory schema = schemaForge.getSchema(schemaName);
        assertTrue(schema.isDefined);
        assertEq(schema.urlTemplate, urlTemplate);
        assertEq(schema.requiredKeys.length, 2);
        assertEq(schema.requiredKeys[0], "key1");
        assertEq(schema.requiredKeys[1], "key2");
        assertEq(schema.responseParser, responseParser);
    }

    function testRegisterSchemaByNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert();
        schemaForge.registerSchema(schemaName, urlTemplate, requiredKeys, responseParser);
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
