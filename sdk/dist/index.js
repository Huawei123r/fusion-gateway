"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FusionGateway = void 0;
const ethers_1 = require("ethers");
const abi_1 = require("./abi");
class FusionGateway {
    constructor(providerUrl, addresses, privateKey) {
        this.provider = new ethers_1.ethers.JsonRpcProvider(providerUrl);
        if (privateKey) {
            this.signer = new ethers_1.ethers.Wallet(privateKey, this.provider);
            this.fusionLinker = new ethers_1.ethers.Contract(addresses.fusionLinker, abi_1.FUSION_LINKER_ABI, this.signer);
            this.schemaForge = new ethers_1.ethers.Contract(addresses.schemaForge, abi_1.SCHEMA_FORGE_ABI, this.signer);
        }
        else {
            this.fusionLinker = new ethers_1.ethers.Contract(addresses.fusionLinker, abi_1.FUSION_LINKER_ABI, this.provider);
            this.schemaForge = new ethers_1.ethers.Contract(addresses.schemaForge, abi_1.SCHEMA_FORGE_ABI, this.provider);
        }
    }
    // Example function to demonstrate usage
    async constructUrl(schemaName, params) {
        return this.fusionLinker.constructUrl(schemaName, params);
    }
}
exports.FusionGateway = FusionGateway;
