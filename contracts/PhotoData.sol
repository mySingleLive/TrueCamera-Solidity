// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

struct PhotoInfo {
    uint256 id;
    address owner;
    uint status;
    string filepath;
    string hash;
    string publicKey;
    uint photoTime;
    uint uploadTime;
}
