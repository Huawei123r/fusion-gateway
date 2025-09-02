# ⛩️ Fusion Gateway

[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FF0000?style=for-the-badge&logo=foundry)](https://github.com/foundry-rs/foundry)
[![CI](https://github.com/Huawei123r/fusion-gateway/actions/workflows/ci.yml/badge.svg)](https://github.com/Huawei123r/fusion-gateway/actions/workflows/ci.yml)
[![Pages](https://github.com/Huawei123r/fusion-gateway/actions/workflows/pages.yml/badge.svg)](https://github.com/Huawei123r/fusion-gateway/actions/workflows/pages.yml)

**Fusion Gateway** is a powerful, modular framework for EVM blockchains that bridges the gap between smart contracts and the real world. It allows developers to natively fetch data from any HTTPS-based API, empowering dApps to react to external events without relying on traditional, and often complex, oracle networks. Whether you're building dynamic NFTs, adaptive DeFi protocols, or on-chain games, Fusion Gateway provides the tools to make your contracts smarter and more connected.

---

## 📖 Overview

The Fusion Gateway aims to unlock programmable reactivity and real-world connectivity for smart contracts. By providing a native, on-chain mechanism to fetch and process external data, we empower developers to build applications that are more dynamic, responsive, and connected to the world outside the blockchain.

The framework is composed of several key modules:

-   **`FusionLinker.sol`**: The core HTTP fetcher that initiates `GET` and `POST` requests.
-   **`Sanctifier.sol`**: A data validation and cleaning utility.
-   **`Wardstone.sol`**: An access control and security module for managing API keys and rate limits.
-   **`SchemaForge.sol`**: A registry for managing and reusing API endpoint definitions.
-   **`LoreHooks.sol`**: An optional narrative layer for triggering on-chain events from data.

For a more detailed explanation of the architecture, see the `docs/` directory.

---

## 🚀 Getting Started

This project is built using [Foundry](https://github.com/foundry-rs/foundry).

### Prerequisites

-   [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation

1.  Clone the repository:
    ```bash
    git clone <YOUR_REPO_URL>
    cd fusion-gate
    ```

2.  Install dependencies:
    ```bash
    forge install
    ```

---

## 🛠️ Usage

### Build

To build the contracts:

```bash
forge build
```

### Test

To run the test suite:

```bash
forge test
```

### Deploy

To deploy the entire Fusion Gateway framework, use the deployment script. You will need to provide an RPC URL and a private key with funds for the target network.

```bash
forge script script/Deploy.s.sol:DeployFusionGateway --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

### Format

To format the Solidity code:

```bash
forge fmt
```

---

## 📚 Fusion Recipes

For concrete examples and step-by-step guides, please see the `docs/` directory, which contains "Fusion Recipes" for common use cases like:

-   Triggering an NFT mint based on weather conditions.
-   Adjusting DeFi parameters based on cryptocurrency prices.
-   Minting a commemorative NFT on a national holiday.
-   Injecting news headlines into on-chain lore.
-   Fetching the top-voted meme from a social media feed.

---

## 🔌 Asynchronous Execution Model

The `FusionLinker` contract is designed to work asynchronously. In a live environment, it does not directly execute HTTP requests. Instead, it emits an event that is captured by an off-chain service.

This off-chain service is responsible for:
1.  Performing the actual HTTP `GET` or `POST` request.
2.  Retrieving the response from the external API.
3.  Submitting the response back to the blockchain by calling the appropriate callback function (e.g., `_handleWeatherResponse` in the `WeatherNFT` example).

This model allows smart contracts to remain fully deterministic while still interacting with the outside world. The mock responses in the test suite simulate this asynchronous callback behavior for development and testing purposes.
