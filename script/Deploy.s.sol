// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {FusionLinker} from "../src/FusionLinker.sol";
import {Sanctifier} from "../src/Sanctifier.sol";
import {Wardstone} from "../src/Wardstone.sol";
import {SchemaForge} from "../src/SchemaForge.sol";
import {LoreHooks} from "../src/LoreHooks.sol";

contract DeployFusionGateway is Script {
    function run() public returns (address, address, address, address, address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the implementation contracts
        FusionLinker fusionLinkerImpl = new FusionLinker();
        Sanctifier sanctifierImpl = new Sanctifier();
        Wardstone wardstoneImpl = new Wardstone();
        SchemaForge schemaForgeImpl = new SchemaForge();
        LoreHooks loreHooksImpl = new LoreHooks();

        // Prepare the initialize call data
        bytes memory fusionLinkerData = abi.encodeWithSelector(FusionLinker.initialize.selector, deployer);
        bytes memory sanctifierData = abi.encodeWithSelector(Sanctifier.initialize.selector, deployer);
        bytes memory wardstoneData = abi.encodeWithSelector(Wardstone.initialize.selector, deployer);
        bytes memory schemaForgeData = abi.encodeWithSelector(SchemaForge.initialize.selector, deployer);
        bytes memory loreHooksData = abi.encodeWithSelector(LoreHooks.initialize.selector, deployer);

        // Deploy the proxies
        ERC1967Proxy fusionLinkerProxy = new ERC1967Proxy(address(fusionLinkerImpl), fusionLinkerData);
        ERC1967Proxy sanctifierProxy = new ERC1967Proxy(address(sanctifierImpl), sanctifierData);
        ERC1967Proxy wardstoneProxy = new ERC1967Proxy(address(wardstoneImpl), wardstoneData);
        ERC1967Proxy schemaForgeProxy = new ERC1967Proxy(address(schemaForgeImpl), schemaForgeData);
        ERC1967Proxy loreHooksProxy = new ERC1967Proxy(address(loreHooksImpl), loreHooksData);

        vm.stopBroadcast();

        // Log the deployed proxy addresses
        console.log("========================================");
        console.log("  Fusion Gateway Proxy Addresses");
        console.log("========================================");
        console.log("FusionLinker:  ", address(fusionLinkerProxy));
        console.log("Sanctifier:    ", address(sanctifierProxy));
        console.log("Wardstone:     ", address(wardstoneProxy));
        console.log("SchemaForge:   ", address(schemaForgeProxy));
        console.log("LoreHooks:     ", address(loreHooksProxy));
        console.log("========================================");
        console.log("\nImplementation contract addresses:");
        console.log("FusionLinker Impl: ", address(fusionLinkerImpl));
        console.log("Sanctifier Impl:   ", address(sanctifierImpl));
        console.log("Wardstone Impl:    ", address(wardstoneImpl));
        console.log("SchemaForge Impl:  ", address(schemaForgeImpl));
        console.log("LoreHooks Impl:    ", address(loreHooksImpl));
        console.log("========================================");

        return (
            address(fusionLinkerProxy),
            address(sanctifierProxy),
            address(wardstoneProxy),
            address(schemaForgeProxy),
            address(loreHooksProxy)
        );
    }
}
