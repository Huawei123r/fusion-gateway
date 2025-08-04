# Fusion Recipe: On-Chain Meme Fetcher

**Objective:** Create a contract that fetches the URL of the top-voted meme from a social media API (like Reddit) and stores it on-chain.

**API Source:** [Reddit API](https://www.reddit.com/dev/api/)

**Modules Used:**
- `SchemaForge`
- `FusionLinker`
- `Sanctifier`
- A custom application contract (`MemeCollector.sol`)

---

## Concept

This recipe is a fun demonstration of the Fusion Gateway's versatility. By connecting to social media, we can create contracts that reflect internet culture, power community-governed content feeds, or even build decentralized social games.

For this example, we'll design a contract that fetches the top post from the `/r/memes` subreddit and stores the URL of the image in a public state variable, creating an on-chain "meme of the day."

## Step-by-Step Guide

### Step 1: Prerequisites

- The Fusion Gateway contracts are deployed.
- You have set up a Reddit API application to get credentials (though some endpoints are public).

### Step 2: Register the API Schema

The system owner registers the Reddit API endpoint for fetching the top posts of a subreddit.

**Example API Endpoint:**
`https://www.reddit.com/r/memes/top.json?limit=1`

**Example JSON Response (highly simplified):**
```json
{
  "data": {
    "children": [
      {
        "data": {
          "title": "Stonks",
          "url": "https://i.redd.it/example.jpg"
        }
      }
    ]
  }
}
```

The owner would call `SchemaForge.registerSchema()`:
- `_name`: `"Reddit-Top-Meme"`
- `_urlTemplate`: `"https://www.reddit.com/r/memes/top.json?limit=1"`
- `_requiredKeys`: `["data.children.data.url"]`
- `_responseParser`: The address of a `Sanctifier` capable of handling nested JSON.

### Step 3: Create the Application Contract

We'll create `MemeCollector.sol`, which will store the URL of the top meme.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FusionLinker.sol";
import "./Sanctifier.sol";

contract MemeCollector {
    FusionLinker public fusionLinker;
    Sanctifier public sanctifier;

    string public topMemeUrl;
    uint256 public lastUpdated;

    event NewMemeFetched(string url);

    constructor(address _linker, address _sanctifier) {
        fusionLinker = FusionLinker(_linker);
        sanctifier = Sanctifier(_sanctifier);
    }

    /**
     * @notice Fetches the latest top meme from Reddit.
     */
    function fetchTopMeme() public {
        string memory apiUrl = "https://www.reddit.com/r/memes/top.json?limit=1";
        fusionLinker.fetch(apiUrl);
        
        // Logic is in the async callback.
    }

    /**
     * @notice Hypothetical callback to handle the API response.
     */
    function _handleMemeResponse(uint256 _requestId, uint256 _statusCode, string memory _responseBody) internal {
        if (_statusCode != 200) {
            return; // Handle error
        }

        // Use the Sanctifier to extract the meme URL.
        // Simplified JSON for this example: `{"url":"https://i.redd.it/example.jpg"}`
        string memory memeUrl = sanctifier.extractString(_responseBody, "url");

        if (bytes(memeUrl).length > 0) {
            topMemeUrl = memeUrl;
            lastUpdated = block.timestamp;
            emit NewMemeFetched(memeUrl);
        }
    }
}
```

### Step 4: Execution Flow

1.  A user or keeper calls `fetchTopMeme()` on the `MemeCollector` contract.
2.  The contract calls `FusionLinker.fetch()` with the Reddit API URL.
3.  The Rialo network fetches the JSON response and sends it to the `_handleMemeResponse` callback.
4.  The callback uses the `Sanctifier` to parse the `url` of the top post.
5.  If a valid URL is found, the contract updates its `topMemeUrl` state variable and the `lastUpdated` timestamp.
6.  An event is emitted, allowing front-ends or other services to easily display the new "meme of the day."

This recipe, while lighthearted, powerfully illustrates that *any* data accessible via an API can be brought on-chain to drive novel decentralized applications.
