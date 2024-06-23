// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "contracts/Randomer.sol";
import "contracts/PhotoData.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";


struct PhotoPage {
    uint total;
    uint from;
    uint size;
    bool isLast;
    PhotoInfo[] list;
}


contract PhotoManager is Randomer {

    mapping(uint256 => uint256) _genPhotoIds;
    mapping(uint256 => PhotoInfo) public _photos;
    mapping(address => uint256[]) _userPhotoIds;

    uint photoCount = 0;

    event AllowUploadPhoto(address indexed uploader, uint photoId);
    event UploadedPhoto(address indexed uploader, uint photoId);


    function generatePhotoId(string memory randomStr, string memory publicKey) internal returns(uint256) {
        uint count = 0;
        uint256 id;
        PhotoInfo memory data;
        do {
            uint256 seed = randomNumberOnChain();
            id = uint(keccak256(abi.encodePacked(seed, publicKey, photoCount, randomStr, count)));
            data = _photos[id];
            count++;
        } while (data.id != 0);
        return id;
    }

    function derivePrivateKey(string memory randomStr) internal returns(uint) {
        uint count = uint(keccak256(abi.encodePacked(randomStr))) % 8;

        uint result = uint(keccak256(abi.encodePacked(randomStr, randomNumberOnChain())));

        for (uint i = 0; i < count - 1; i++) {
            result = uint(keccak256(abi.encodePacked("\nPKey=\n", result, randomNumberOnChain())));
        }

        return result;
    }

    function generatePhoto(string memory randomStr, string memory publicKey) public returns(uint256 requestId, uint256 photoId) {
        address account = msg.sender;
        photoId = generatePhotoId(randomStr, publicKey);
        _genPhotoIds[requestId] = photoId;
        _photos[photoId] = PhotoInfo({
            id: photoId,
            owner: account,
            status: 0,
            filepath: "",
            hash: "",
            publicKey: publicKey,
            photoTime: 0,
            uploadTime: 0
        });
        _userPhotoIds[account].push(photoId);
        emit AllowUploadPhoto(account, photoId);
    }


    function uploadPhoto(uint256 photoId, string memory filepath, string memory hash, uint photoTime) external {
        address account = msg.sender;
        PhotoInfo memory info = getPhotoInfoById(photoId);
        require(info.owner == account, "No permission to upload the photo");
        info.status = 1;
        info.filepath = filepath;
        info.hash = hash;
        info.photoTime = photoTime;
        info.uploadTime = block.timestamp;
        _photos[photoId] = info;

        emit UploadedPhoto(msg.sender, photoId);
    }



    function getPhotoInfoById(uint256 photoId) public view returns(PhotoInfo memory) {
        PhotoInfo storage data = _photos[photoId];
        assert(data.id != 0);
        return data;
    }

    function findUserPhotoIds(address account) public view returns(uint256[] memory) {
        return _userPhotoIds[account];
    }


    function findUserPhotoInfos(address account, uint from, uint size) public view returns(PhotoPage memory) {
        require(size <= 100, "Size is too large");
        uint256[] storage ids = _userPhotoIds[account];
        uint total = ids.length;
        uint len = Math.min(from + size, total);
        uint realSize = len - from;
        PhotoInfo[] memory infos = new PhotoInfo[](realSize);
        for (uint i = from; i < len; i++) {
            uint id = ids[i];
            PhotoInfo memory info = getPhotoInfoById(id);
            infos[i - from] = info;
        }
        return PhotoPage({
            total: total,
            from: from,
            size: realSize,
            isLast: total <= from + size,
            list: infos
        });
    }


}