# Fusion Recipe: Weather-Triggered Mint

**Objective:** Create a smart contract that mints a special "Rainy Day" NFT only if the daily rainfall in a specific city, as reported by an external weather API, exceeds a certain threshold.

**API Source:** [OpenWeatherMap](https://openweathermap.org/api) (or any similar weather API)

**Modules Used:**
- `SchemaForge`
- `FusionLinker`
- `Sanctifier`
- A custom application contract (`WeatherNFT.sol`)

---

## Concept

This recipe demonstrates a powerful use case for the Fusion Gateway: creating on-chain actions that are conditional on real-world physical events. By connecting a smart contract to a reliable weather data feed, we can create dynamic NFTs, insurance protocols, or other applications that react to the environment.

For this example, we'll define a simple rule: if the rainfall in the last hour in "London" is greater than 5mm, a new NFT can be minted.

## Step-by-Step Guide

### Step 1: Prerequisites

- The Fusion Gateway contracts (`FusionLinker`, `Sanctifier`, `SchemaForge`) are assumed to be deployed on the Rialo DevNet.
- You have an API key from OpenWeatherMap.
- You have a basic NFT contract (`RainyDayNFT`) that the application contract can control.

### Step 2: Register the API Schema

First, the owner of the Fusion Gateway system must register the OpenWeatherMap API as a valid schema in the `SchemaForge`. This tells the gateway how to format the request and which parser to use for the response.

**Example API Endpoint:**
`https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_API_KEY`

**Example JSON Response (simplified for clarity):**
```json
{
  "weather": "Rain",
  "rainfall_mm": "7" 
}
```

The owner would call `SchemaForge.registerSchema()` with these parameters:
- `_name`: `"OpenWeatherMap-Rainfall"`
- `_urlTemplate`: `"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={apiKey}"` (Note: The framework doesn't yet support templating, so the full URL would be used for now).
- `_requiredKeys`: `["rainfall_mm"]`
- `_responseParser`: The address of the deployed `Sanctifier.sol` contract.

### Step 3: Create the Application Contract

Now, let's create our `WeatherNFT.sol` contract. This contract will use the Fusion Gateway to check the weather and trigger a mint.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FusionLinker.sol";
import "./Sanctifier.sol";
// Assume a simple NFT contract exists
import "./RainyDayNFT.sol"; 

contract WeatherNFT {
    FusionLinker public fusionLinker;
    Sanctifier public sanctifier;
    RainyDayNFT public rainyDayNFT;

    uint256 public constant RAINFALL_THRESHOLD = 5; // in mm

    // Event to log the outcome
    event WeatherCheckResult(string message);

    constructor(address _linkerAddress, address _sanctifierAddress, address _nftAddress) {
        fusionLinker = FusionLinker(_linkerAddress);
        sanctifier = Sanctifier(_sanctifierAddress);
        rainyDayNFT = RainyDayNFT(_nftAddress);
    }

    /**
     * @notice Triggers a weather check for London.
     * This function is a placeholder for the full async flow.
     */
    function checkLondonWeatherAndMint() public {
        // In a real implementation, you would use the SchemaForge to build this URL.
        string memory apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_API_KEY";
        
        // Initiate the fetch request
        fusionLinker.fetch(apiUrl);

        // NOTE: In a true async environment on Rialo, the rest of the logic
        // would be handled in a callback function that is invoked when the
        // FusionLinker receives the response.
    }

    /**
     * @notice This is the hypothetical callback function.
     * @dev It would be called by FusionLinker with the response data.
     */
    function _handleWeatherResponse(uint256 _requestId, uint256 _statusCode, string memory _responseBody) internal {
        if (_statusCode != 200) {
            emit WeatherCheckResult("API request failed.");
            return;
        }

        // Use the Sanctifier to parse the rainfall value from the JSON
        string memory rainfallStr = sanctifier.extractString(_responseBody, "rainfall_mm");
        
        if (bytes(rainfallStr).length == 0) {
            emit WeatherCheckResult("Failed to parse rainfall data.");
            return;
        }

        // Convert string to uint (a robust library should be used for this in production)
        uint256 rainfallValue = parseInt(rainfallStr);

        if (rainfallValue > RAINFALL_THRESHOLD) {
            // If rainfall exceeds the threshold, mint a new NFT
            rainyDayNFT.safeMint(msg.sender);
            emit WeatherCheckResult("Rainfall threshold exceeded. NFT minted!");
        } else {
            emit WeatherCheckResult("Rainfall is below threshold. No NFT minted.");
        }
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

1.  A user calls `checkLondonWeatherAndMint()` on your deployed `WeatherNFT` contract.
2.  The contract calls `FusionLinker.fetch()` with the OpenWeatherMap API URL.
3.  The Rialo network performs the HTTPS GET request and returns the JSON response to `FusionLinker`.
4.  `FusionLinker` calls the `_handleWeatherResponse` function in your `WeatherNFT` contract with the response data.
5.  `_handleWeatherResponse` uses `Sanctifier` to extract the `rainfall_mm` value.
6.  It compares the value against `RAINFALL_THRESHOLD`.
7.  If the condition is met, it calls the `safeMint()` function on the `RainyDayNFT` contract, awarding the user a new NFT.

This recipe illustrates how the Fusion Gateway can bridge the gap between on-chain logic and real-world data, enabling a new class of dynamic and reactive decentralized applications.
