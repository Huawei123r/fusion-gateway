// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {FusionLinker} from "../src/FusionLinker.sol";

contract FusionLinkerTest is Test {
    FusionLinker public fusionLinker;
    address owner;
    address user = address(0x123);

    function setUp() public {
        owner = address(this);

        // Deploy the implementation contract
        FusionLinker fusionLinkerImpl = new FusionLinker();

        // Prepare the initialize call data
        bytes memory initData = abi.encodeWithSelector(FusionLinker.initialize.selector, owner);

        // Deploy the proxy
        ERC1967Proxy proxy = new ERC1967Proxy(address(fusionLinkerImpl), initData);

        // Attach the FusionLinker interface to the proxy address
        fusionLinker = FusionLinker(address(proxy));
    }

    function testFetch() public {
        vm.prank(user);
        vm.expectEmit(true, true, true, true);
        emit FusionLinker.ResponseReceived(0, 200, '{"success": true, "data": "mock_get_response"}');
        uint256 requestId = fusionLinker.fetch("https://example.com/get");

        assertEq(requestId, 0);
        (address initiator, string memory url, bytes memory body) = fusionLinker.requests(requestId);
        assertEq(initiator, user);
        assertEq(url, "https://example.com/get");
        assertEq(body.length, 0);
    }

    function testPost() public {
        vm.prank(user);
        bytes memory postBody = abi.encodePacked('{"key":"value"}');
        
        vm.expectEmit(true, true, true, true);
        emit FusionLinker.ResponseReceived(0, 200, '{"success": true, "data": "mock_post_response"}');
        uint256 requestId = fusionLinker.post("https://example.com/post", postBody);

        assertEq(requestId, 0);
        (address initiator, string memory url, bytes memory body) = fusionLinker.requests(requestId);
        assertEq(initiator, user);
        assertEq(url, "https://example.com/post");
        assertEq(body, postBody);
    }
}
