// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {LoreHooks} from "../src/LoreHooks.sol";

contract LoreHooksTest is Test {
    LoreHooks public loreHooks;
    address owner;
    address nonOwner;
    string triggerName = "TestTrigger";
    string keyword = "keyword";
    string narrativeTemplate = "A test narrative.";

    function setUp() public {
        owner = address(this);
        nonOwner = address(0x789);

        // Deploy the implementation contract
        LoreHooks loreHooksImpl = new LoreHooks();

        // Prepare the initialize call data
        bytes memory initData = abi.encodeWithSelector(LoreHooks.initialize.selector, owner);

        // Deploy the proxy
        ERC1967Proxy proxy = new ERC1967Proxy(address(loreHooksImpl), initData);

        // Attach the LoreHooks interface to the proxy address
        loreHooks = LoreHooks(address(proxy));
    }

    function testSetTrigger() public {
        loreHooks.setTrigger(triggerName, keyword, narrativeTemplate);
        bytes32 triggerId = keccak256(abi.encodePacked(triggerName));
        (string memory _keyword, string memory _narrativeTemplate, bool _isDefined) = loreHooks.triggers(triggerId);
        assertTrue(_isDefined);
        assertEq(_keyword, keyword);
        assertEq(_narrativeTemplate, narrativeTemplate);
    }

    function testSetTriggerByNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, nonOwner));
        loreHooks.setTrigger(triggerName, keyword, narrativeTemplate);
    }

    function testInvokeLore() public {
        loreHooks.setTrigger(triggerName, keyword, narrativeTemplate);
        vm.expectEmit(true, true, true, true);
        emit LoreHooks.LoreTriggered(keccak256(abi.encodePacked(triggerName)), narrativeTemplate, "Some data with the keyword");
        loreHooks.invokeLore("Some data with the keyword", triggerName);
    }

    function testInvokeLoreKeywordNotFound() public {
        loreHooks.setTrigger(triggerName, keyword, narrativeTemplate);
        // We expect no event to be emitted
        loreHooks.invokeLore("Some data without the magic word", triggerName);
    }

    function testInvokeLoreTriggerNotSet() public {
        // We expect no event to be emitted
        loreHooks.invokeLore("Some data", "NonExistentTrigger");
    }
}
