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
        string memory result = sanctifier.extractString(json, "name");
        assertEq(result, "test");
    }

    function testExtractStringKeyNotFound() public {
        string memory json = '{"name":"test","value":123}';
        string memory result = sanctifier.extractString(json, "notfound");
        assertEq(result, "");
    }

    function testExtractUint() public {
        string memory json = '{"name":"test","value":123}';
        uint256 result = sanctifier.extractUint(json, "value");
        assertEq(result, 123);
    }

    function testExtractUintWithQuotes() public {
        string memory json = '{"name":"test","value":"456"}';
        uint256 result = sanctifier.extractUint(json, "value");
        assertEq(result, 456);
    }

    function testExtractUintKeyNotFound() public {
        string memory json = '{"name":"test","value":123}';
        uint256 result = sanctifier.extractUint(json, "notfound");
        assertEq(result, 0);
    }
}
