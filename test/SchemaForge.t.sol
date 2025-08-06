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
    string urlTemplate = "https://example.com/{id}";
    string[] requiredKeys = ["key1", "key2"];
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
        schemaForge.registerSchema(schemaName, urlTemplate, requiredKeys, responseParser);
        (string memory _urlTemplate, address _responseParser, bool _isDefined) = schemaForge.schemas(
            schemaForge.getSchemaId(schemaName)
        );
        assertTrue(_isDefined);
        assertEq(_urlTemplate, urlTemplate);
        assertEq(_responseParser, responseParser);
    }

    function testRegisterSchemaByNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, nonOwner));
        schemaForge.registerSchema(schemaName, urlTemplate, requiredKeys, responseParser);
    }

    function testGetSchemaId() public {
        bytes32 expectedId = keccak256(abi.encodePacked(schemaName));
        bytes32 actualId = schemaForge.getSchemaId(schemaName);
        assertEq(actualId, expectedId);
    }

    function testGetSchemaNotRegistered() public {
        (,, bool _isDefined) = schemaForge.schemas(schemaForge.getSchemaId("NonExistentSchema"));
        assertFalse(_isDefined);
    }
}
