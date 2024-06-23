// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "contracts/PhotoData.sol";
import "contracts/PhotoManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract TrueCamera is Ownable {

    event PhotoUpload(address indexed uploader, string indexed hash, uint256 indexed photoTime, uint photoId);

    PhotoManager _photoManager;


    constructor(address photoManagerAddress) Ownable(msg.sender) {
        _photoManager = PhotoManager(photoManagerAddress);
    }


    function setPhotoManager(address photoManagerAddress) external onlyOwner {
        _photoManager = PhotoManager(photoManagerAddress);
    }


    function generatePhoto(string memory randomStr, string memory publicKey) public returns(uint256 requestId, uint256 photoId) {
        assert(address(_photoManager) != address(0));
        return _photoManager.generatePhoto(randomStr, publicKey);
    }

    function getPhotoById(uint256 photoId) external view returns(PhotoInfo memory) {
        assert(address(_photoManager) != address(0));
        return _photoManager.getPhotoInfoById(photoId);
    }

}