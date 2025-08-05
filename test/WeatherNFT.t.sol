// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {WeatherNFT, RainyDayNFT} from "../examples/WeatherNFT.sol";
import {FusionLinker} from "../src/FusionLinker.sol";
import {Sanctifier} from "../src/Sanctifier.sol";

/**
 * @title MockFusionLinker
 * @notice A mock version of FusionLinker that allows us to simulate callbacks.
 */
contract MockFusionLinker is FusionLinker {
    function callHandleResponse(address _target, uint256 _requestId, uint256 _statusCode, string memory _responseBody) public {
        WeatherNFT(_target)._handleWeatherResponse(_requestId, _statusCode, _responseBody);
    }
}

contract WeatherNFTTest is Test {
    WeatherNFT public weatherNFT;
    RainyDayNFT public rainyDayNFT;
    MockFusionLinker public mockFusionLinker;
    Sanctifier public sanctifier;

    function setUp() public {
        mockFusionLinker = new MockFusionLinker();
        sanctifier = new Sanctifier();
        rainyDayNFT = new RainyDayNFT();
        weatherNFT = new WeatherNFT(address(mockFusionLinker), address(sanctifier), address(rainyDayNFT));
    }

    function testHandleWeatherResponse_AboveThreshold() public {
        string memory mockResponse = '{"rainfall_mm":"10"}';
        
        // Simulate the callback from the FusionLinker
        mockFusionLinker.callHandleResponse(address(weatherNFT), 1, 200, mockResponse);

        // Verify that the NFT was minted
        assertEq(rainyDayNFT.balanceOf(address(weatherNFT)), 1);
    }

    function testHandleWeatherResponse_BelowThreshold() public {
        string memory mockResponse = '{"rainfall_mm":"3"}';

        // We expect a log message, but no mint
        vm.expectEmit(true, false, false, true);
        emit WeatherNFT.WeatherCheckResult("Rainfall is below threshold. No NFT minted.");

        // Simulate the callback
        mockFusionLinker.callHandleResponse(address(weatherNFT), 1, 200, mockResponse);

        // Verify that no NFT was minted
        assertEq(rainyDayNFT.balanceOf(address(weatherNFT)), 0);
    }

    function testHandleWeatherResponse_ApiError() public {
        string memory mockResponse = '{"error":"API is down"}';

        // We expect a log message, but no mint
        vm.expectEmit(true, false, false, true);
        emit WeatherNFT.WeatherCheckResult("API request failed.");

        // Simulate the callback with a non-200 status code
        mockFusionLinker.callHandleResponse(address(weatherNFT), 1, 500, mockResponse);

        // Verify that no NFT was minted
        assertEq(rainyDayNFT.balanceOf(address(weatherNFT)), 0);
    }

    function testHandleWeatherResponse_ParsingError() public {
        string memory mockResponse = '{"wrong_key":"10"}';

        // We expect a log message, but no mint
        vm.expectEmit(true, false, false, true);
        emit WeatherNFT.WeatherCheckResult("Failed to parse rainfall data.");

        // Simulate the callback
        mockFusionLinker.callHandleResponse(address(weatherNFT), 1, 200, mockResponse);

        // Verify that no NFT was minted
        assertEq(rainyDayNFT.balanceOf(address(weatherNFT)), 0);
    }
}
