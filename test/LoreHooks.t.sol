// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {LoreHooks} from "../src/LoreHooks.sol";

contract LoreHooksTest is Test {
    LoreHooks public loreHooks;
    address owner;
    address nonOwner;
    string triggerName = "TestTrigger";
    string keyword = "keyword";
    string narrativeTemplate = "A test narrative.";

    function setUp() public {
        loreHooks = new LoreHooks();
        owner = address(this);
        nonOwner = address(0x789);
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
        vm.expectRevert();
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
