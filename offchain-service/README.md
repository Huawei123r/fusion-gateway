# Fusion Gateway Off-Chain Service

This service listens for `ApiRequestInitiated` events from the `FusionLinker` smart contract, performs the requested HTTP call, and sends the response back to the blockchain.

## Setup

1.  **Install Dependencies:**
    Navigate to this directory and run:
    ```bash
    npm install
    ```

2.  **Create Environment File:**
    Create a `.env` file in this directory by copying the example:
    ```bash
    cp .env.example .env
    ```

3.  **Edit Environment Variables:**
    Open the `.env` file and fill in the required values:
    -   `RPC_URL`: The RPC URL for your target blockchain network (e.g., from Infura or Alchemy).
    -   `PRIVATE_KEY`: The private key of the wallet you want to use to send the response transactions. This wallet must have native currency (e.g., ETH) to pay for gas.
    -   `FUSION_LINKER_ADDRESS`: The address of your deployed `FusionLinker` contract.

## Running the Service

Once the setup is complete, you can start the listener service:

```bash
npm start
```

The service will connect to the blockchain and begin listening for events.
