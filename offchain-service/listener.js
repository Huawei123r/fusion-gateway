require("dotenv").config();
const { ethers } = require("ethers");
const axios = require("axios");
const FusionLinkerABI = require("../out/FusionLinker.sol/FusionLinker.json").abi;

const { RPC_URL, PRIVATE_KEY, FUSION_LINKER_ADDRESS } = process.env;

if (!RPC_URL || !PRIVATE_KEY || !FUSION_LINKER_ADDRESS) {
    console.error("Missing required environment variables. Please check your .env file.");
    process.exit(1);
}

const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
const fusionLinker = new ethers.Contract(FUSION_LINKER_ADDRESS, FusionLinkerABI, wallet);

async function main() {
    console.log("✅ Off-chain listener started.");
    console.log(`Listening for ApiRequestInitiated events on FusionLinker at ${FUSION_LINKER_ADDRESS}...`);

    fusionLinker.on("ApiRequestInitiated", async (requestId, initiator, url, body) => {
        console.log("\n🚀 Received ApiRequestInitiated event:");
        console.log(`  - Request ID: ${requestId}`);
        console.log(`  - Initiator: ${initiator}`);
        console.log(`  - URL: ${url}`);
        console.log(`  - Body: ${body}`);

        try {
            let response;
            if (body && body !== "0x") {
                // POST request
                response = await axios.post(url, JSON.parse(ethers.utils.toUtf8String(body)));
            } else {
                // GET request
                response = await axios.get(url);
            }

            const statusCode = response.status;
            const responseBody = JSON.stringify(response.data);

            console.log("✅ API request successful:");
            console.log(`  - Status Code: ${statusCode}`);
            console.log(`  - Response Body: ${responseBody}`);

            // This is where the callback to the original contract would happen.
            // The current FusionLinker emits a generic ResponseReceived event.
            // A production system would call a specific function on the `initiator` contract.
            // For this example, we call the generic `handleResponse` on the FusionLinker itself.
            
            console.log("Submitting response back to the blockchain...");
            const tx = await fusionLinker.handleResponse(requestId, statusCode, responseBody);
            await tx.wait();
            console.log(`✅ Response submitted in transaction: ${tx.hash}`);

        } catch (error) {
            console.error("\n❌ Error handling API request:", error.message);
            const statusCode = error.response ? error.response.status : 500;
            const responseBody = error.response ? JSON.stringify(error.response.data) : `{"error":"${error.message}"}`;
            
            console.log("Submitting error response back to the blockchain...");
            try {
                const tx = await fusionLinker.handleResponse(requestId, statusCode, responseBody);
                await tx.wait();
                console.log(`✅ Error response submitted in transaction: ${tx.hash}`);
            } catch (txError) {
                console.error("❌ Failed to submit error response to the blockchain:", txError.message);
            }
        }
    });
}

main().catch((error) => {
    console.error("Fatal error in listener:", error);
    process.exit(1);
});
