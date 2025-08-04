// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {FusionLinker} from "../src/FusionLinker.sol";
import {Sanctifier} from "../src/Sanctifier.sol";
import {Wardstone} from "../src/Wardstone.sol";
import {SchemaForge} from "../src/SchemaForge.sol";
import {LoreHooks} from "../src/LoreHooks.sol";

contract DeployFusionGateway is Script {
    function run() public {
        vm.startBroadcast();

        // Deploy the core contracts
        FusionLinker fusionLinker = new FusionLinker();
        Sanctifier sanctifier = new Sanctifier();
        Wardstone wardstone = new Wardstone();
        SchemaForge schemaForge = new SchemaForge();
        LoreHooks loreHooks = new LoreHooks();

        vm.stopBroadcast();

        // Log the deployed addresses
        console.log("========================================");
        console.log("  Fusion Gateway Deployed Addresses");
        console.log("========================================");
        console.log("FusionLinker:  ", address(fusionLinker));
        console.log("Sanctifier:    ", address(sanctifier));
        console.log("Wardstone:     ", address(wardstone));
        console.log("SchemaForge:   ", address(schemaForge));
        console.log("LoreHooks:     ", address(loreHooks));
        console.log("========================================");
    }
}
