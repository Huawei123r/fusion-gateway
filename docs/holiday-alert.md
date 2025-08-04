# Fusion Recipe: Holiday-Triggered NFT Mint

**Objective:** Create a smart contract that can mint a special commemorative NFT, but only if the current date is a recognized national holiday in a specific country.

**API Source:** [Calendarific](https://calendarific.com/)

**Modules Used:**
- `SchemaForge`
- `FusionLinker`
- `Sanctifier`
- A custom application contract (`HolidayNFT.sol`)

---

## Concept

This recipe showcases how to connect smart contracts to real-world calendar events. This can be used for a wide range of applications, from issuing commemorative assets on special dates to enabling time-locked features that only become available on specific days (e.g., a "New Year's Gift" that can only be claimed on January 1st).

For this example, we'll create a contract that checks if today is a national holiday in the United States. If it is, a user can claim a unique "Holiday 2025" NFT.

## Step-by-Step Guide

### Step 1: Prerequisites

- The Fusion Gateway contracts are deployed on the Rialo DevNet.
- You have an API key from Calendarific.

### Step 2: Register the API Schema

The system owner registers the Calendarific API endpoint. This endpoint checks for public holidays for a given country and year.

**Example API Endpoint:**
`https://calendarific.com/api/v2/holidays?api_key=YOUR_API_KEY&country=US&year=2025`

**Example JSON Response (simplified):**
```json
{
  "response": {
    "holidays": [
      { "name": "New Year's Day", "date": { "iso": "2025-01-01" } },
      { "name": "Independence Day", "date": { "iso": "2025-07-04" } }
    ]
  }
}
```
*(Note: This complex JSON response would require a sophisticated `Sanctifier`. For our example, we'll imagine the API can return a simpler format, or that our `Sanctifier` can handle it.)*

The owner would call `SchemaForge.registerSchema()`:
- `_name`: `"Calendarific-US-Holidays"`
- `_urlTemplate`: `"https://calendarific.com/api/v2/holidays?api_key={key}&country=US&year=2025"`
- `_requiredKeys`: `["response.holidays.date.iso"]`
- `_responseParser`: The address of a capable `Sanctifier`.

### Step 3: Create the Application Contract

We'll create `HolidayNFT.sol`, which will use the gateway to check the date.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FusionLinker.sol";
import "./Sanctifier.sol";
// Assume a simple NFT contract exists
import "./CommemorativeNFT.sol"; 

contract HolidayNFT {
    FusionLinker public fusionLinker;
    Sanctifier public sanctifier;
    CommemorativeNFT public holidayNFT;

    // Mapping to prevent a user from claiming more than once per holiday
    mapping(bytes32 => mapping(address => bool)) public hasClaimed;

    event HolidayClaimResult(string message, address claimer);

    constructor(address _linker, address _sanctifier, address _nft) {
        fusionLinker = FusionLinker(_linker);
        sanctifier = Sanctifier(_sanctifier);
        holidayNFT = CommemorativeNFT(_nft);
    }

    /**
     * @notice User-facing function to attempt to claim a holiday NFT.
     */
    function claimHolidayNFT() public {
        // For this example, we'll hardcode the URL. A real implementation
        // would fetch the URL template from SchemaForge.
        string memory apiUrl = "https://calendarific.com/api/v2/holidays?api_key=YOUR_KEY&country=US&year=2025";
        fusionLinker.fetch(apiUrl);
        
        // The actual logic is in the async callback.
    }

    /**
     * @notice Hypothetical callback to handle the API response.
     */
    function _handleHolidayResponse(uint256 _requestId, uint256 _statusCode, string memory _responseBody) internal {
        if (_statusCode != 200) {
            emit HolidayClaimResult("API request failed.", msg.sender);
            return;
        }

        // This is a simplified check. A real implementation would need to get today's date
        // from the blockchain (`block.timestamp`) and check if that date exists in the holiday list.
        // For demonstration, we'll use our simple Sanctifier to look for a keyword.
        // Let's pretend the API returns a simple string if today is a holiday, e.g., `{"holiday_today":"true"}`
        
        string memory holidayStatus = sanctifier.extractString(_responseBody, "holiday_today");

        if (keccak256(abi.encodePacked(holidayStatus)) == keccak256(abi.encodePacked("true"))) {
            // To make this unique per holiday, we could use the holiday name or date as an ID.
            // For simplicity, we'll use a generic ID.
            bytes32 holidayId = keccak256(abi.encodePacked("holiday_2025"));

            if (hasClaimed[holidayId][msg.sender]) {
                emit HolidayClaimResult("Already claimed for this holiday.", msg.sender);
                return;
            }

            hasClaimed[holidayId][msg.sender] = true;
            holidayNFT.safeMint(msg.sender);
            emit HolidayClaimResult("Success! Holiday NFT minted.", msg.sender);
        } else {
            emit HolidayClaimResult("Today is not a national holiday.", msg.sender);
        }
    }
}
```

### Step 4: Execution Flow

1.  On a day they suspect is a holiday (e.g., July 4th), a user calls `claimHolidayNFT()`.
2.  The contract calls `FusionLinker.fetch()` with the Calendarific API URL.
3.  The Rialo network fetches the list of all US holidays for the year.
4.  The response is sent to the `_handleHolidayResponse` callback.
5.  The callback logic (in a real scenario) would compare the current `block.timestamp` to the dates in the holiday list.
6.  If a match is found, it checks if the user has already claimed an NFT for this holiday.
7.  If they haven't, it mints them a `CommemorativeNFT` and records that they have claimed their gift.

This recipe shows how to create time-sensitive on-chain events, opening up possibilities for loyalty programs, anniversary rewards, and other date-driven applications.
