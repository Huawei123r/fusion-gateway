// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Sanctifier} from "../src/Sanctifier.sol";

contract SanctifierTest is Test {
    Sanctifier public sanctifier;

    function setUp() public {
        // Deploy the implementation contract
        Sanctifier sanctifierImpl = new Sanctifier();

        // Prepare the initialize call data
        bytes memory initData = abi.encodeWithSelector(Sanctifier.initialize.selector, address(this));

        // Deploy the proxy
        ERC1967Proxy proxy = new ERC1967Proxy(address(sanctifierImpl), initData);

        // Attach the Sanctifier interface to the proxy address
        sanctifier = Sanctifier(address(proxy));
    }

    function testExtractString() public {
        string memory json = '{"name":"test","value":123}';
        (bool success, string memory result) = sanctifier.extractString(json, "name");
        assertTrue(success);
        assertEq(result, "test");
    }

    function testExtractStringKeyNotFound() public {
        string memory json = '{"name":"test","value":123}';
        (bool success, string memory result) = sanctifier.extractString(json, "notfound");
        assertFalse(success);
        assertEq(result, "");
    }

    function testExtractUint() public {
        string memory json = '{"name":"test","value":123}';
        (bool success, uint256 result) = sanctifier.extractUint(json, "value");
        assertTrue(success);
        assertEq(result, 123);
    }

    function testExtractUintWithQuotes() public {
        string memory json = '{"name":"test","value":"456"}';
        (bool success, uint256 result) = sanctifier.extractUint(json, "value");
        assertTrue(success);
        assertEq(result, 456);
    }

    function testExtractUintKeyNotFound() public {
        string memory json = '{"name":"test","value":123}';
        (bool success, uint256 result) = sanctifier.extractUint(json, "notfound");
        assertFalse(success);
        assertEq(result, 0);
    }
}
