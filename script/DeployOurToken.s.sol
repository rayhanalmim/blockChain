// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {OurToken} from "../src/OurToken.sol";

contract DeployOurToken is Script {
    uint256 public constant initialSupply = 1_000_000 ether; // 1 million tokens with 18 decimal places

    function run() external returns (OurToken) {
        vm.startBroadcast();
        OurToken ourToken = new OurToken(initialSupply); // Use initialSupply here
        vm.stopBroadcast();
        return ourToken;
    }
}
