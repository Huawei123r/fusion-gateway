# Fusion Recipe: On-Chain Lore from News Headlines

**Objective:** Create a contract that fetches the latest news headline from an external API and records it on-chain as a piece of evolving "lore," using the `LoreHooks` module.

**API Source:** [NewsAPI](https://newsapi.org/)

**Modules Used:**
- `SchemaForge`
- `FusionLinker`
- `Sanctifier`
- `LoreHooks`
- A custom application contract (`LoreMaster.sol`)

---

## Concept

This recipe demonstrates one of the most creative uses of the Fusion Gateway: building a dynamic, evolving narrative directly on the blockchain. By pulling in data from the real world, a contract can generate a story, a history, or a "pulse" of events that are forever recorded on-chain. This is ideal for games, dynamic NFTs, or decentralized autonomous artist (DAA) projects.

For this example, we'll fetch the top headline from a major news source and use `LoreHooks` to emit it as a stylized narrative event.

## Step-by-Step Guide

### Step 1: Prerequisites

- The Fusion Gateway contracts, including `LoreHooks`, are deployed.
- You have an API key from NewsAPI.

### Step 2: Register the API Schema

The system owner registers the NewsAPI endpoint for fetching top headlines.

**Example API Endpoint:**
`https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=YOUR_API_KEY`

**Example JSON Response (simplified):**
```json
{
  "articles": [
    {
      "title": "Global Markets Rally on New Tech Breakthrough",
      "description": "A new discovery in quantum computing has sent shockwaves through the tech industry..."
    }
  ]
}
```

The owner would call `SchemaForge.registerSchema()`:
- `_name`: `"NewsAPI-Top-Headline"`
- `_urlTemplate`: `"https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey={key}"`
- `_requiredKeys`: `["articles.title"]`
- `_responseParser`: The address of a `Sanctifier` capable of parsing this structure.

### Step 3: Configure the Lore Hook

The owner of the `LoreHooks` contract sets up a trigger that will format the headline into a lore entry.

The owner calls `LoreHooks.setTrigger()`:
- `_name`: `"HeadlinePulse"`
- `_keyword`: `"title"` (or another keyword to ensure the hook always fires for this data)
- `_narrativeTemplate`: `"The world outside whispers of a new headline..."`

### Step 4: Create the Application Contract

We'll create `LoreMaster.sol`, a contract responsible for initiating the news fetch.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FusionLinker.sol";
import "./Sanctifier.sol";
import "./LoreHooks.sol";

contract LoreMaster {
    FusionLinker public fusionLinker;
    Sanctifier public sanctifier;
    LoreHooks public loreHooks;

    constructor(address _linker, address _sanctifier, address _lore) {
        fusionLinker = FusionLinker(_linker);
        sanctifier = Sanctifier(_sanctifier);
        loreHooks = LoreHooks(_lore);
    }

    /**
     * @notice Fetches the latest headline and records it as lore.
     */
    function recordLatestHeadline() public {
        string memory apiUrl = "https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=YOUR_API_KEY";
        fusionLinker.fetch(apiUrl);
        
        // Logic is in the async callback.
    }

    /**
     * @notice Hypothetical callback to handle the API response.
     */
    function _handleNewsResponse(uint256 _requestId, uint256 _statusCode, string memory _responseBody) internal {
        if (_statusCode != 200) {
            return; // Handle error
        }

        // Use the Sanctifier to extract the headline title.
        // Simplified JSON for this example: `{"title":"Global Markets Rally"}`
        string memory headline = sanctifier.extractString(_responseBody, "title");

        if (bytes(headline).length > 0) {
            // Use the LoreHooks contract to emit a stylized, on-chain event.
            // We pass the raw headline as the data and specify the trigger name.
            loreHooks.invokeLore(headline, "HeadlinePulse");
        }
    }
}
```

### Step 5: Execution Flow

1.  A keeper bot or an authorized user calls `recordLatestHeadline()` on the `LoreMaster` contract.
2.  The contract calls `FusionLinker.fetch()` with the NewsAPI URL.
3.  The Rialo network fetches the JSON response and sends it to the `_handleNewsResponse` callback.
4.  The callback uses the `Sanctifier` to parse the headline from the JSON.
5.  It then calls `LoreHooks.invokeLore()`, passing in the headline.
6.  The `LoreHooks` contract finds the "HeadlinePulse" trigger and emits a `LoreTriggered` event containing the narrative template and the actual headline.
7.  Off-chain indexers, front-ends, or even other smart contracts can now listen for these `LoreTriggered` events to build a living history of the world as perceived by the blockchain.

This recipe shows how the Fusion Gateway can be used to create a rich, narrative layer on top of any on-chain application, making the blockchain not just a ledger of transactions, but a recorder of stories.
