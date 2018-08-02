pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "./LANDbase.sol";


// TODO:
contract LANDEvolution is ERC721Token("OASIS","EVL"), Ownable, LANDbase{


    /*
     * FUNCTION
     */

    function assignNewLand(int x, int y, address beneficiary) external onlyOwner {
        _mint(beneficiary, _encodeTokenId(x, y));
    }

    function assignMultipleLands(int[] x, int[] y, address beneficiary) external onlyOwner {
        for (uint i = 0; i < x.length; i++) {
            _mint(beneficiary, _encodeTokenId(x[i], y[i]));
        }
    }

    // decode
    function decodeTokenId(uint value) pure external returns (int, int) {
        return _decodeTokenId(value);
    }

    function exists(int x, int y) view external returns (bool) {
        return super.exists(_encodeTokenId(x, y));
    }

    function ownerOfLand(int x, int y) view public returns (address) {
        return super.ownerOf(_encodeTokenId(x, y));
    }

    function ownerOfLandMany(int[] x, int[] y) view public returns (address[]) {
        require(x.length > 0);
        require(x.length == y.length);

        address[] memory addrs = new address[](x.length);
        for (uint i = 0; i < x.length; i++) {
            addrs[i] = ownerOfLand(x[i], y[i]);
        }
    }

    function landOf(address landholder) external view returns (int[], int[]) {
        require(landholder == msg.sender);
        uint256 length = balanceOf(landholder);
        int[] memory x = new int[](length);
        int[] memory y = new int[](length);

        int landX;
        int landY;
        for(uint i = 0; i < length; i++) {
            (landX, landY) = _decodeTokenId(ownedTokens[landholder][i]);
            x[i] = landX;
            y[i] = landY;
        }

        return (x, y);
    }

    function indexOfLand(uint _tokenId) public view returns (uint index) {
        index = allTokensIndex[_tokenId];
    }

    //@dev user invoke approveAndCall to create auction
    //@param _to - address of auction contractß

    function approveAndCall(
        address _to,
        uint _tokenId,
        bytes _extraData
    ) onlyOwnerOf(_tokenId) public {
        // set _to to the auction contract
        approve(_to, _tokenId);
        if(!_to.call(bytes4(keccak256("receiveApproval(address,uint256,bytes)")),
            abi.encode(msg.sender, _tokenId, _extraData))) {
            revert();
        }

    }






}
