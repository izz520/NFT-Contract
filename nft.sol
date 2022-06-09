// SPDX-License-Identifier: MIT

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                               .-'''-.                                  //
//                                                                   _______                    '   _    \                                //
//|                                                  __.....__      \  ___ `'.               /   /` '.   \                    _..._       //
//||                          _.._ _.._.-''         '.     ' |--.\  \             .   |     \  '         _     _  .'     '.               //
//||                        .' .._|    .' .._|   /     .-''"'-.  `.   | |    \  '       .|   |   '      |  '  /\    \\   // .   .-.   .   //
//||  __                    | '        | '      /     /________\   \  | |     |  '    .' |_  \    \     / /   `\\  //\\ //  |  '   '  |   //
//||/'__ '.     _ _    __| |__ __| |__    |                  |  | |     |  |  .'     |  `.   ` ..' /      \`//  \'/   |         |         //
//|:/`  '. '   | '  / |  |__   __|  |__   __|   \    .-------------'  | |     ' .' '--.  .-'     '-...-'`        \|   |/    |  |   |  |   // 
//||     | |  .' | .' |     | |        | |       \    '-.____...---.  | |___.' /'     |  |                        '         |  |   |  |   // 
//||\    / '  /  | /  |     | |        | |        `.             .'  /_______.'/      |  |                                  |  |   |  |   // 
//|/\'..' /  |   `'.  |     | |        | |          `''-...... -'    \_______|/       |  '.'                                |  |   |  |   //   
//'  `'-'`   '   .'|  '/    | |        | |                                            |   /                                 |  |   |  |   //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.8.9 <0.9.0;

import 'erc721a/contracts/ERC721A.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
contract BuffedGoblin is ERC721A, Ownable, ReentrancyGuard {

  using Strings for uint256;
  string public baseURI = '';
  string public uriSuffix = '.json';
  
  uint256 public price = 0.0044 ether;
  uint256 public maxSupply = 4444;
  uint256 public maxFreeMint = 444;
  uint256 public maxMintAmountPerTX = 10;

  mapping(address => uint256) public addressMintedBalance;

  bool public paused = false;


  constructor(
    string memory _tokenName,
    string memory _tokenSymbol
  ) ERC721A(_tokenName, _tokenSymbol) {
  }


  modifier mintCompliance(uint256 _mintAmount) {

    require(_mintAmount <= maxMintAmountPerTX, 'Invalid mint amount!');
    require(_mintAmount > 0, 'Invalid mint amount!');
    require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');

    _;
  }


  function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount){
    if(msg.sender != owner()){
      require(!paused, 'The contract is paused!');
      if (totalSupply()+_mintAmount > maxFreeMint){
          require(msg.value >= price * _mintAmount, "Insufficient funds!");
        }
      }
      _safeMint(_msgSender(), _mintAmount);
    }

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : '';
  }

  function setBaseURI(string memory _url) public onlyOwner {
    baseURI = _url;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function withdraw() public onlyOwner nonReentrant {
    (bool os, ) = payable(owner()).call{value: address(this).balance}('');
    require(os);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }
}
