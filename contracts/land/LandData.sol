pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract LandData is Ownable {

    uint256 constant CLEAR_LOW = 0xffff0000;
    uint256 constant CLEAR_HIGH = 0x0000ffff;
    uint256 constant FACTOR = 0x10000;

    /**
     * @dev LandInfo contains attibutes of Land asset.
     * consider LandInfo a binary array with the index starting at 0.
     * the rightmost one is the 0th element and the leftmost one is 255th element.
     * from the right to the left:
     * LandInfo[0,15] : y
     * LandInfo[16,31] : x
     * LandInfo[32,47] : z
     * LandInfo[48,63] : goldrate
     * LandInfo[64,79] : woodrate
     * LandInfo[80,95] : waterrate
     * LandInfo[96,111] : firerate
     * LandInfo[112,127] : soilrate
     * LandInfo[128,128] : isReserved
     * LandInfo[129,129] : isSpecial
     * LandInfo[130,130] : hasBox
     * LandInfo[131,255] : not open yet
    */
    //uint256 LandInfo;


    mapping(uint256 => uint256) tokenId2Attributes;


    function addLandPixel(uint256 _tokenId, uint256 _landAttribute) public onlyOwner {
        require(_landAttribute != 0);
        require(tokenId2Attributes[_tokenId] == 0);
        tokenId2Attributes[_tokenId] = _landAttribute;
    }

    function batchAdd(uint256[] _tokenIds, uint256[] _landAttributes) public onlyOwner {
        require(_tokenIds.length == _landAttributes.length);
        uint length = _tokenIds.length;
        for (uint i = 0; i < length; i++) {
            addLandPixel(_tokenIds[i], _landAttributes[i]);
        }
    }

    function getXY(uint _tokenId) public view returns (int16 x, int16 y) {
        uint landInfo = tokenId2Attributes[_tokenId];
        // get x and y
        uint position = getInfoFromAttibutes(landInfo, 0, 31);
        (x, y) = _decodeTokenId(position);
    }


    function modifyAttibutes(uint _tokenId, uint _right, uint _left, uint _newValue) public onlyOwner {
        uint landInfo = tokenId2Attributes[_tokenId];
        uint newValue = _modifyInfoFromAttibutes(landInfo, _right, _left, _newValue);
        tokenId2Attributes[_tokenId] = newValue;
    }

    function getGoldRate(uint _tokenId) public view returns (uint) {
        uint landInfo = tokenId2Attributes[_tokenId];
        return (getInfoFromAttibutes(landInfo, 48, 63));
    }

    function getWoodRate(uint _tokenId) public view returns (uint) {
        uint landInfo = tokenId2Attributes[_tokenId];
        return (getInfoFromAttibutes(landInfo, 64, 79));
    }

    function getWaterRate(uint _tokenId) public view returns (uint) {
        uint landInfo = tokenId2Attributes[_tokenId];
        return (getInfoFromAttibutes(landInfo, 80, 95));
    }

    function getFireRate(uint _tokenId) public view returns (uint) {
        uint landInfo = tokenId2Attributes[_tokenId];
        return (getInfoFromAttibutes(landInfo, 96, 111));
    }

    function getSoilRate(uint _tokenId) public view returns (uint) {
        uint landInfo = tokenId2Attributes[_tokenId];
        return (getInfoFromAttibutes(landInfo, 112, 127));
    }


    function isReserved(uint256 _tokenId) public view returns (bool) {
        uint landInfo = tokenId2Attributes[_tokenId];
        return (getInfoFromAttibutes(landInfo, 128, 128) == 1);
    }

    function isSpecial(uint256 _tokenId) public view returns (bool) {
        uint landInfo = tokenId2Attributes[_tokenId];
        return (getInfoFromAttibutes(landInfo, 129, 129) == 1);
    }

    function hasBox(uint256 _tokenId) public view returns (bool) {
        uint landInfo = tokenId2Attributes[_tokenId];
        return (getInfoFromAttibutes(landInfo, 130, 130) == 1);
    }


    function _modifyInfoFromAttibutes(uint256 _attibutes, uint _rightAt, uint _leftAt, uint _value) internal returns (uint) {
        uint emptyTarget = (_attibutes >> _leftAt) << _leftAt;
        uint newValue = _value << _rightAt;
        return (emptyTarget + newValue);
    }


    /**
    * @dev get specific snippet of info from _flag
    * @param _attibutes - LandPixel.flag
    * @param _rightAt - where the snippet start from the right
    * @param _leftAt - where the snippet end to the left
    * for example, uint(000...010100), because of the index starting at 0.
    * the '101' part's _rightAt is 2, and _leftAt is 4.
    */
    function getInfoFromAttibutes(uint256 _attibutes, uint _rightAt, uint _leftAt) public returns (uint) {
        uint leftShift = _attibutes << (255 - _leftAt);
        uint rightShift = leftShift >> (_rightAt + 255 - _leftAt);
        return rightShift;
    }

    // helper
    function encodeTokenId(int _x, int _y) pure public returns (uint) {
        return _unsafeEncodeTokenId(_x, _y);
    }

    function _encodeTokenId(int _x, int _y) pure internal returns (uint) {
        return _unsafeEncodeTokenId(_x, _y);
    }

    function _unsafeEncodeTokenId(int _x, int _y) pure internal returns (uint) {
        return ((uint(_x) * FACTOR) & CLEAR_LOW) | (uint(_y) & CLEAR_HIGH);
    }

    function _decodeTokenId(uint _value) pure internal returns (int16 x, int16 y) {
        (x, y) = _unsafeDecodeTokenId(_value);
    }

    function _unsafeDecodeTokenId(uint _value) pure internal returns (int16 x, int16 y) {
        x = expandNegative128BitCast((_value & CLEAR_LOW) >> 16);
        y = expandNegative128BitCast(_value & CLEAR_HIGH);
    }

    function expandNegative128BitCast(uint _value) pure internal returns (int16) {
        if (_value & (1 << 15) != 0) {
            return int16(_value | CLEAR_LOW);
        }
        return int16(_value);
    }






}
