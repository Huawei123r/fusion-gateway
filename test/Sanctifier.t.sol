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
        string memory json = '{"name":"test","value":"123"}';
        string memory key = "name";
        string memory expectedValue = "test";
        string memory actualValue = sanctifier.extractString(json, key);
        assertEq(actualValue, expectedValue);
    }

    function testExtractStringSecondKey() public {
        string memory json = '{"name":"test","value":"123"}';
        string memory key = "value";
        string memory expectedValue = "123";
        string memory actualValue = sanctifier.extractString(json, key);
        assertEq(actualValue, expectedValue);
    }

    function testExtractStringKeyNotFound() public {
        string memory json = '{"name":"test","value":"123"}';
        string memory key = "notfound";
        string memory expectedValue = "";
        string memory actualValue = sanctifier.extractString(json, key);
        assertEq(actualValue, expectedValue);
    }

    function testExtractStringMalformedJson() public {
        string memory json = '{"name":"test" "value":"123"}'; // Missing comma
        string memory key = "value";
        string memory expectedValue = "123";
        string memory actualValue = sanctifier.extractString(json, key);
        assertEq(actualValue, expectedValue);
    }
}
