// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

abstract contract Randomer  {

    uint random_count = 0;

    function randomNumberOnChain() internal returns(uint256) {
        uint inc = uint(keccak256(abi.encodePacked("\nRandomCountIncrement:\n", blockhash(block.number + 1), msg.sender, block.timestamp)));
        random_count += inc % 64;
        bytes32 randomBytes = keccak256(abi.encodePacked("\nRandom Number:\n", random_count, blockhash(block.number + 1), msg.sender, block.timestamp, block.prevrandao));
        return uint256(randomBytes);
    }

}