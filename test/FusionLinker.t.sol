// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {FusionLinker} from "../src/FusionLinker.sol";
import {SchemaForge} from "../src/SchemaForge.sol";

contract FusionLinkerTest is Test {
    FusionLinker public fusionLinker;
    SchemaForge public schemaForge;
    address owner;
    address user = address(0x123);
    string schemaName = "TestSchema";

    function setUp() public {
        owner = address(this);

        // Deploy and initialize SchemaForge
        SchemaForge schemaForgeImpl = new SchemaForge();
        bytes memory schemaForgeData = abi.encodeWithSelector(SchemaForge.initialize.selector, owner);
        ERC1967Proxy schemaForgeProxy = new ERC1967Proxy(address(schemaForgeImpl), schemaForgeData);
        schemaForge = SchemaForge(address(schemaForgeProxy));

        // Deploy and initialize FusionLinker
        FusionLinker fusionLinkerImpl = new FusionLinker();
        bytes memory fusionLinkerData = abi.encodeWithSelector(FusionLinker.initialize.selector, owner, address(schemaForge));
        ERC1967Proxy fusionLinkerProxy = new ERC1967Proxy(address(fusionLinkerImpl), fusionLinkerData);
        fusionLinker = FusionLinker(address(fusionLinkerProxy));

        // Register a test schema
        string[] memory urlParts = new string[](2);
        urlParts[0] = "https://example.com/";
        urlParts[1] = "/data";
        string[] memory keyPlaceholders = new string[](1);
        keyPlaceholders[0] = "id";
        string[] memory requiredKeys = new string[](0);
        schemaForge.registerSchema(schemaName, urlParts, keyPlaceholders, requiredKeys, address(0));
    }

    function testConstructUrl() public {
        FusionLinker.KeyValuePair[] memory params = new FusionLinker.KeyValuePair[](1);
        params[0] = FusionLinker.KeyValuePair("id", "123");
        string memory constructedUrl = fusionLinker.constructUrl(schemaName, params);
        assertEq(constructedUrl, "https://example.com/123/data");
    }

    function testFetchWithSchema() public {
        vm.prank(user);
        FusionLinker.KeyValuePair[] memory params = new FusionLinker.KeyValuePair[](1);
        params[0] = FusionLinker.KeyValuePair("id", "123");

        vm.expectEmit(true, true, true, true);
        emit FusionLinker.ResponseReceived(0, 200, '{"success": true, "data": "mock_get_response"}');
        uint256 requestId = fusionLinker.fetch(schemaName, params);

        assertEq(requestId, 0);
        (address initiator, string memory url, bytes memory body) = fusionLinker.requests(requestId);
        assertEq(initiator, user);
        assertEq(url, "https://example.com/123/data");
        assertEq(body.length, 0);
    }

    function testPostWithSchema() public {
        vm.prank(user);
        FusionLinker.KeyValuePair[] memory params = new FusionLinker.KeyValuePair[](1);
        params[0] = FusionLinker.KeyValuePair("id", "123");
        bytes memory postBody = abi.encodePacked('{"key":"value"}');
        
        vm.expectEmit(true, true, true, true);
        emit FusionLinker.ResponseReceived(0, 200, '{"success": true, "data": "mock_post_response"}');
        uint256 requestId = fusionLinker.post(schemaName, params, postBody);

        assertEq(requestId, 0);
        (address initiator, string memory url, bytes memory body) = fusionLinker.requests(requestId);
        assertEq(initiator, user);
        assertEq(url, "https://example.com/123/data");
        assertEq(body, postBody);
    }
}

