// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FusionLinker} from "../src/FusionLinker.sol";
import {Sanctifier} from "../src/Sanctifier.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Holder} from "openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";

/**
 * @title RainyDayNFT
 * @notice A simple NFT contract for the WeatherNFT example.
 */
contract RainyDayNFT is ERC721 {
    uint256 private _nextTokenId;

    constructor() ERC721("Rainy Day NFT", "RAIN") {}

    function safeMint(address to) public {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }
}

/**
 * @title WeatherNFT
 * @notice An example application contract that uses the Fusion Gateway
 * to mint a special "Rainy Day" NFT if the daily rainfall in a specific
 * city exceeds a certain threshold.
 */
contract WeatherNFT is ERC721Holder {
    FusionLinker public fusionLinker;
    Sanctifier public sanctifier;
    RainyDayNFT public rainyDayNFT;

    uint256 public constant RAINFALL_THRESHOLD = 5; // in mm

    event WeatherCheckResult(string message);
    event MintingTriggered(address indexed recipient);

    constructor(address _linkerAddress, address _sanctifierAddress, address _nftAddress) {
        fusionLinker = FusionLinker(_linkerAddress);
        sanctifier = Sanctifier(_sanctifierAddress);
        rainyDayNFT = RainyDayNFT(_nftAddress);
    }

    /**
     * @notice Triggers a weather check for a given city.
     * @dev In a real implementation, the URL would be constructed from a schema in SchemaForge.
     */
    function checkWeatherAndMint(string memory _apiUrl) public {
        fusionLinker.fetch(_apiUrl);
        // The rest of the logic is handled in the async callback.
    }

    /**
     * @notice This is the hypothetical callback function that would be invoked by FusionLinker.
     * @param _statusCode The HTTP status code of the response.
     * @param _responseBody The body of the HTTP response.
     */
    function _handleWeatherResponse(uint256 /*_requestId*/, uint256 _statusCode, string memory _responseBody) public {
        if (_statusCode != 200) {
            emit WeatherCheckResult("API request failed.");
            return;
        }

        // Use the Sanctifier to parse the rainfall value from the JSON.
        // Assumes a simple JSON format like `{"rainfall_mm":"7"}`
        string memory rainfallStr = sanctifier.extractString(_responseBody, "rainfall_mm");
        
        if (bytes(rainfallStr).length == 0) {
            emit WeatherCheckResult("Failed to parse rainfall data.");
            return;
        }

        uint256 rainfallValue = parseInt(rainfallStr);

        if (rainfallValue > RAINFALL_THRESHOLD) {
            // The recipient would typically be the original initiator of the request.
            // For this example, we'll mint to the contract itself for simplicity.
            address recipient = address(this); 
            rainyDayNFT.safeMint(recipient);
            emit MintingTriggered(recipient);
        } else {
            emit WeatherCheckResult("Rainfall is below threshold. No NFT minted.");
        }
    }

    /**
     * @dev Helper function to parse a string to an unsigned integer.
     * This is for demonstration purposes only. A production contract should
     * use a more robust and gas-efficient library for this.
     */
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
