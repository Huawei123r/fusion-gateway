# Fusion Recipe: Dynamic Yield Based on Crypto Index

**Objective:** Create a DeFi-style contract that dynamically adjusts a parameter, such as a yield rate or a tax fee, based on the real-time price volatility of a cryptocurrency fetched from an external API.

**API Source:** [CoinGecko](https://www.coingecko.com/en/api)

**Modules Used:**
- `SchemaForge`
- `FusionLinker`
- `Sanctifier`
- A custom application contract (`DynamicYieldVault.sol`)

---

## Concept

This recipe demonstrates how the Fusion Gateway can be used to create more responsive and automated DeFi protocols. By pulling in external market data, contracts can self-regulate, reducing risk during volatile periods or increasing incentives when the market is stable.

For this example, we'll design a simple yield vault that adjusts its `yieldRate` based on the price of Ethereum. If the price drops significantly, the contract could lower the yield to reduce risk; if the price is stable or rising, it could increase the yield to attract more liquidity.

## Step-by-Step Guide

### Step 1: Prerequisites

- The Fusion Gateway contracts (`FusionLinker`, `Sanctifier`, `SchemaForge`) are assumed to be deployed on the Rialo DevNet.
- CoinGecko's public API does not require a key for many endpoints, making it ideal for decentralized applications.

### Step 2: Register the API Schema

The owner of the Fusion Gateway system registers the CoinGecko API endpoint for fetching the current price of Ethereum in USD.

**Example API Endpoint:**
`https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd`

**Example JSON Response:**
```json
{
  "ethereum": {
    "usd": 3450.12
  }
}
```
*(Note: The `Sanctifier` created earlier is too simple for this nested JSON. This recipe assumes a more capable parser exists or that the API provides a simpler, flat response.)*

The owner would call `SchemaForge.registerSchema()`:
- `_name`: `"CoinGecko-ETH-USD"`
- `_urlTemplate`: `"https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd"`
- `_requiredKeys`: `["ethereum.usd"]` (hypothetical path for a more advanced parser)
- `_responseParser`: The address of a `Sanctifier` capable of handling this response.

### Step 3: Create the Application Contract

We'll create `DynamicYieldVault.sol`, which adjusts its yield based on the fetched ETH price.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FusionLinker.sol";
import "./Sanctifier.sol"; // Assuming a more advanced version

contract DynamicYieldVault {
    FusionLinker public fusionLinker;
    Sanctifier public sanctifier;

    uint256 public yieldRate; // Basis points, e.g., 100 = 1%
    uint256 public lastPrice;   // Last recorded price of ETH in USD

    // Event to log the outcome
    event YieldRateAdjusted(uint256 newRate, uint256 price);

    constructor(address _linkerAddress, address _sanctifierAddress) {
        fusionLinker = FusionLinker(_linkerAddress);
        sanctifier = Sanctifier(_sanctifierAddress);
        yieldRate = 100; // Default 1%
    }

    /**
     * @notice Triggers a price check to adjust the yield rate.
     */
    function adjustYieldRate() public {
        string memory apiUrl = "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd";
        fusionLinker.fetch(apiUrl);

        // The rest of the logic happens in the async callback.
    }

    /**
     * @notice Hypothetical callback function for handling the API response.
     */
    function _handlePriceResponse(uint256 _requestId, uint256 _statusCode, string memory _responseBody) internal {
        if (_statusCode != 200) {
            return; // Handle error
        }

        // Assume an advanced sanctifier that can parse "ethereum.usd"
        // For this example, we'll use our simple one on a simplified JSON string.
        // Simplified JSON: `{"price":"3450"}`
        string memory priceStr = sanctifier.extractString(_responseBody, "price");
        
        if (bytes(priceStr).length == 0) {
            return; // Handle parsing error
        }

        uint256 currentPrice = parseInt(priceStr);

        // Simple logic: if price drops by more than 10%, halve the yield.
        // If it rises by more than 10%, double the yield.
        if (lastPrice > 0) {
            if (currentPrice < (lastPrice * 90) / 100) {
                yieldRate /= 2; // Halve the yield
            } else if (currentPrice > (lastPrice * 110) / 100) {
                yieldRate *= 2; // Double the yield
            }
        }

        lastPrice = currentPrice;
        emit YieldRateAdjusted(yieldRate, currentPrice);
    }

    // Helper function to parse string to uint (for demonstration only)
    function parseInt(string memory _value) internal pure returns (uint256) {
        uint256 result = 0;
        bytes memory b = bytes(_value);
        for (uint256 i = 0; i < b.length; i++) {
            if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
            }
        }
        return result;
    }
}
```

### Step 4: Execution Flow

1.  An authorized operator calls `adjustYieldRate()` on the `DynamicYieldVault` contract.
2.  The vault calls `FusionLinker.fetch()` with the CoinGecko API URL.
3.  The Rialo network fetches the JSON response and passes it to the `_handlePriceResponse` callback.
4.  The callback uses the `Sanctifier` to parse the current price of ETH.
5.  It then applies its internal logic, adjusting the `yieldRate` based on the price change.
6.  An event is emitted, providing a transparent, on-chain record of the adjustment.

This recipe shows how the Fusion Gateway can make DeFi protocols more intelligent and autonomous, reacting to market conditions without manual intervention or reliance on traditional, slow-moving oracle systems.
