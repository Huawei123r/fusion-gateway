// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Wardstone} from "../src/Wardstone.sol";

contract WardstoneTest is Test {
    Wardstone public wardstone;
    address owner;
    address nonOwner;
    string apiKey = "test-api-key";

    function setUp() public {
        wardstone = new Wardstone();
        owner = address(this);
        nonOwner = address(0x123);
    }

    function testAddApiKey() public {
        wardstone.addApiKey(apiKey);
        assertTrue(wardstone.isApiKeyAuthorized(apiKey));
    }

    function testAddApiKeyByNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert();
        wardstone.addApiKey(apiKey);
    }

    function testRemoveApiKey() public {
        wardstone.addApiKey(apiKey);
        assertTrue(wardstone.isApiKeyAuthorized(apiKey));
        wardstone.removeApiKey(apiKey);
        assertFalse(wardstone.isApiKeyAuthorized(apiKey));
    }

    function testRemoveApiKeyByNonOwner() public {
        wardstone.addApiKey(apiKey);
        vm.prank(nonOwner);
        vm.expectRevert();
        wardstone.removeApiKey(apiKey);
    }

    function testIsApiKeyAuthorized() public {
        assertFalse(wardstone.isApiKeyAuthorized(apiKey));
        wardstone.addApiKey(apiKey);
        assertTrue(wardstone.isApiKeyAuthorized(apiKey));
    }
}
