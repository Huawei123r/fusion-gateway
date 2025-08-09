import { ethers } from "ethers";
import { FUSION_LINKER_ABI, SCHEMA_FORGE_ABI } from "./abi";

interface FusionGatewayAddresses {
    fusionLinker: string;
    schemaForge: string;
}

export class FusionGateway {
    private provider: ethers.Provider;
    private signer: ethers.Signer | undefined;
    public fusionLinker: ethers.Contract;
    public schemaForge: ethers.Contract;

    constructor(providerUrl: string, addresses: FusionGatewayAddresses, privateKey?: string) {
        this.provider = new ethers.JsonRpcProvider(providerUrl);
        if (privateKey) {
            this.signer = new ethers.Wallet(privateKey, this.provider);
            this.fusionLinker = new ethers.Contract(addresses.fusionLinker, FUSION_LINKER_ABI, this.signer);
            this.schemaForge = new ethers.Contract(addresses.schemaForge, SCHEMA_FORGE_ABI, this.signer);
        } else {
            this.fusionLinker = new ethers.Contract(addresses.fusionLinker, FUSION_LINKER_ABI, this.provider);
            this.schemaForge = new ethers.Contract(addresses.schemaForge, SCHEMA_FORGE_ABI, this.provider);
        }
    }

    // Example function to demonstrate usage
    public async constructUrl(schemaName: string, params: { key: string; value: string }[]): Promise<string> {
        return this.fusionLinker.constructUrl(schemaName, params);
    }
}
