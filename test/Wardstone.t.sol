// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {Wardstone} from "../src/Wardstone.sol";

contract WardstoneTest is Test {
    Wardstone public wardstone;
    address owner;
    address nonOwner;
    address user = address(0x456);
    string apiKey = "test-api-key";

    function setUp() public {
        owner = address(this);
        nonOwner = address(0x123);

        // Deploy the implementation contract
        Wardstone wardstoneImpl = new Wardstone();

        // Prepare the initialize call data
        bytes memory initData = abi.encodeWithSelector(Wardstone.initialize.selector, owner);

        // Deploy the proxy
        ERC1967Proxy proxy = new ERC1967Proxy(address(wardstoneImpl), initData);

        // Attach the Wardstone interface to the proxy address
        wardstone = Wardstone(address(proxy));
    }

    function testAddApiKey() public {
        wardstone.addApiKey(apiKey);
        assertTrue(wardstone.isApiKeyAuthorized(apiKey));
    }

    function testAddApiKeyByNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, nonOwner));
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
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, nonOwner));
        wardstone.removeApiKey(apiKey);
    }

    function testIsApiKeyAuthorized() public {
        assertFalse(wardstone.isApiKeyAuthorized(apiKey));
        wardstone.addApiKey(apiKey);
        assertTrue(wardstone.isApiKeyAuthorized(apiKey));
    }

    function testCheckRateLimit() public {
        vm.prank(user);
        wardstone.checkRateLimit(user);
        assertEq(wardstone.lastRequestTimestamp(user), block.timestamp);
    }

    function testCheckRateLimit_Exceeded() public {
        vm.prank(user);
        wardstone.checkRateLimit(user);

        vm.expectRevert("Wardstone: Rate limit exceeded");
        wardstone.checkRateLimit(user);
    }

    function testCheckRateLimit_AfterPeriod() public {
        vm.prank(user);
        wardstone.checkRateLimit(user);

        uint256 period = wardstone.RATE_LIMIT_PERIOD();
        vm.warp(block.timestamp + period);

        wardstone.checkRateLimit(user);
        assertEq(wardstone.lastRequestTimestamp(user), block.timestamp);
    }
}
