// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestDMS is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    constructor() ERC721("TestDMS", "TDMS") {}

    function safeMint(address to, uint256 tokenId, string memory uri)
        public
        onlyOwner
    {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // จัดการชื่อเพลง ศิลปิน และ อัลบั้มเพลงต่างๆ
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    //หากจะทำเป็นอัลบั้มเพลงไฟล์จะต้องเป็น json ซึ่งมีลิงค์เพลงอื่นๆอยู่
    //ตัวอย่างไฟล์อัลบั้มเพลง
    /*
    *{
    *   {"musicName": "Thought Crime",
    *   "song-writer": "Yorushika",
    *   "Instrumental": "TZ Sound Works",
    *   "Vocal lyrics": "Soneshiner",
    *   "description": "This music shows the true nature of NFT.",
    *   "music": "https://ipfs.io/ipfs/QmZzBdKF7sQX1Q49CQGmreuZHxt9sVB3hTc3TTXYcVZ7jC"
    *   },
    *   {"musicName": "Sun Sun Days",
    *   "song-writer": "Spira Spica",
    *   "Instrumental": "Spira Spica Official",
    *   "Vocal lyrics": "Soneshiner",
    *   "description": "This music shows the true nature of NFT.",
    *   "music": "https://ipfs.io/ipfs/QmUFdYEH934SuVtHKcvUYfDHqFQiwvToJQzNLqvsM51Tnk"
    *   },
    */

    //ลิงค์เพลงของสัญญานี้
    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/QmUFdYEH934SuVtHKcvUYfDHqFQiwvToJQzNLqvsM51Tnk";
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // การคิดค่าบริการเมื่อมีผู้ต้องการฟังเพลงจาก contract
    // ตั้งค่าว่าในการเข้ามาฟังเพลงต้องใช้สกุลเงินอะไรในการแลกเปลี่ยน
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    //เป็น String ที่แสดงถึงชื่อเพลง
    string musicName;
    function setMusicName(string memory name) public onlyOwner {
        musicName = name;
    }
    //ดูชื่อเพลงที่ตั้งไว้
    function getMusicName() public view returns (string memory) {
        return musicName;
    }

    //รายละเอียดการเก็บข้อมูลของผู้มีส่วนร่วมในลิขสิทธิ์
    struct Contributor {
        string name;
        string position;
        address payable account;
        uint percent;
    }

    //ดูรายละเอียดของผู้มีส่วนร่วมในผลงานเพลงโดยใส่เลขเริ่มจาก 0
    Contributor[] public contri;

    //เพิ่มผู้มีส่วนร่วมในลิทสิทธิ์เพลง
    //การคิดค่าเปอร์เซ็นต์ส่วนแบ่งของภาษา Solidity เบื้องต้น
    //100; == 1 Percent
    //500; == 5 percent
    //2000; == 20 Percent
    function addContributor(string memory _name,string memory _position,address payable _account,uint _percent) public onlyOwner {
        Contributor memory newCon = Contributor({
            name : _name,
            position : _position,
            account : _account,
            percent : _percent
        });
        contri.push(newCon);
    }

    //ใช้ในการแก้ไขรายละเอียดของผู้มีส่วนร่วมในเพลง
    function editContributor(uint assetId,string memory _name,string memory _position,address payable _account,uint _percent) public onlyOwner{
        Contributor storage _contri =(contri[assetId]);
        _contri.name = _name;
        _contri.position = _position;
        _contri.account = _account;
        _contri.percent = _percent;
    }

    //ใช้เพื่อดูจำนวนผู้มีส่วนร่วมในลิขสิทธิ์เพลงว่ามีกี่คน
    function recordsArrayLenth() public view returns (uint256){
        return contri.length;
    }
/*
    //ดูรายละเอียกของผู้มีส่วนร่วมในผลงานเพลง
    function getContributor(uint assetId) public view returns (string memory,address,uint) {
        return (contri[assetId].name,contri[assetId].account,contri[assetId].percent);
    }
*/
    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // การคิดค่าบริการเมื่อมีผู้ต้องการฟังเพลงจาก contract
    // ตั้งค่าว่าในการเข้ามาฟังเพลงต้องใช้อะไรบ้างเช่น ค่าบริการ หน่วยเงินหรือ ercที่ใช้แลกเปลี่ยน
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    //เจ้าของสัญญา
    address Owner;
    function setOwner(address _owner) public onlyOwner {
        Owner = _owner;
    }
    //ค่าบริการในการเข้ามาฟังเพลง
    uint Amount;
    function setServiceCharge(uint _amount) public {
        Amount = _amount;
    }
    //ตั้งค่าให้รับเฉพาะ ERC20 ที่กำหนด
    address OnlyToken;
    function setToken(address _token) public onlyOwner {
        OnlyToken = _token;
    }
    
    struct someToken {
        string symbol;
        address payable token;
    }
    someToken[] public token;
    //เพิ่ม ERC20 ที่สามารถใช้ได้
    function addToken(string memory _sym,address payable _token) public onlyOwner {
        someToken memory newToken = someToken({
            symbol : _sym,
            token : _token
        });
        token.push(newToken);
    }

    //ใช้เพื่อส่ง ERC20 มายังสัญญานี้
    //และเมื่อมีการส่ง ERC20 มาแล้วตามกำหนดจะส่ง URL ที่เป็นที่อยู่ของเพลงให้
    function listeningMusic(address _sender) payable public {
        //IERC20(OnlyToken).approve(_sender,Amount);
        //IERC20(OnlyToken).allowance(_sender, address(this));
        IERC20(OnlyToken).transferFrom(_sender, address(this), Amount);
        uint i = 0;
        for (i = 1;i <= contri.length; i++){
        Contributor storage _contri =(contri[i]);
            _contri.account.transfer(msg.value/_contri.percent);
        }
        _baseURI;
    }

    //ใช้เพื่อดู ERC20 ที่มีอยู่
    //function getBalanceToken(address _address) public view returns (unit) {
    //    return ERC20(_address).balanceOf(address(this));
    //}

    // ตั้งมูลค่าของเพลงเพื่อทำการขายเพลงไปยังบัญชีอื่นถาวร
    // จำนวนแสดงถึง ERC20 ที่ต้องจ่าย
    uint SalePrice;
    function setSalePrice (uint _salePrice) public {
        SalePrice = _salePrice;
    }

    //ตั้งค่าลิขสิทธิ์ที่ได้จากการขายขาด
    uint feeDenominator;
    function _feeDenominator(uint _fee) public {
        feeDenominator = _fee;
    }

    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    function royaltyInfo(uint256 _tokenId) public view returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];
        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }
        uint256 royaltyAmount = (SalePrice * royalty.royaltyFraction) / feeDenominator;
        return (royalty.receiver, royaltyAmount);
    }
/*
    //ขายขาดเพลง
    function sellOutMusic(address _receiver, address payable _token) public view returns (string memory) {
        royaltyInfo;
        ERC721(_token).transferFrom(Owner, _receiver);
    }
*/
}

//SciNET
//0x5447A76987906F3Bf8302449b3861dd9b28ED5AA
