// SPDX-License-Identifier: MIT

// Version 1 deployed to Mumbai at: 0x77C45ADB236098efB0D4D318F518B2C86E827938

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract ChainBattles is ERC721URIStorage {
  using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // Keep track of the stats for each of the NFTs
  struct Stats {
    uint256 level;
    uint256 health;
    uint256 attack;
    uint256 defense;
    uint256 speed;
    uint256 rarity;
  }

  mapping(uint256 => Stats) public tokenIdToStats;

  constructor() ERC721("Chain Battles", "CB") {
    
  }

  // Generates the NFT character SVG image
  function generateCharacter(uint256 _tokenId) public view returns (string memory) {
    bytes memory svg = abi.encodePacked(
      '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
      '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
      '<rect width="100%" height="100%" fill="red" />',
      '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior #",_tokenId.toString(),'</text>',
      getStats(_tokenId),
      '</svg>'
    );

    return string(
      abi.encodePacked(
        "data:image/svg+xml;base64,",
        Base64.encode(svg)
      )
    );
  }

  // Gets the stats of the character
  function getStats(uint256 _tokenId) public view returns (string memory) {
    uint256 level = tokenIdToStats[_tokenId].level;
    uint256 health = tokenIdToStats[_tokenId].health;
    uint256 attack = tokenIdToStats[_tokenId].attack;
    uint256 defense = tokenIdToStats[_tokenId].defense;
    uint256 speed = tokenIdToStats[_tokenId].speed;
    uint256 rarity = tokenIdToStats[_tokenId].rarity;

    return string(
      abi.encodePacked(
        '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",level.toString(),'</text>',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">', "Health: ",health.toString(),'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Attack: ",attack.toString(),'</text>',
        '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Defense: ",defense.toString(),'</text>',
        '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",speed.toString(),'</text>',
        '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Rarity: ",rarity.toString(),'</text>',
      )
    );
  }

  // Generates the NFT character data URI from the JSON metadata
  function getTokenURI(uint256 _tokenId) public view returns (string memory){
    bytes memory dataURI = abi.encodePacked(
      '{',
        '"name": "Chain Battles #', _tokenId.toString(), '",',
        '"description": "Battles On-Chain",',
        '"image": "', generateCharacter(_tokenId), '"',
      '}'
    );

    return string(
      abi.encodePacked(
        "data:application/json;base64,",
        Base64.encode(dataURI)
      )
    );
  }

  // Mints the NFT character
  function mint() public {
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);

    // Initialize the stats
    tokenIdToStats[newItemId].level = 1;
    tokenIdToStats[newItemId].health = 100;
    tokenIdToStats[newItemId].attack = 10;
    tokenIdToStats[newItemId].defense = 10;
    tokenIdToStats[newItemId].speed = 10;
    tokenIdToStats[newItemId].rarity = randomNumber(100);

    // Sets the token URI
    _setTokenURI(newItemId, getTokenURI(newItemId));
  }

  // Train the Character to increase its stats
  function train(uint256 _tokenId) public {
    require(_exists(tokenId), "Token does not exist");
    require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");

    // Increase the level by 1
    uint256 currentLevel = tokenIdToStats[tokenId].level;
    tokenIdToStats[tokenId].level = currentLevel + 1;

    // Increase the stats by a random number between 1 and 10
    tokenIdtoStats[tokenId].health = tokenIdToStats[tokenId].health + randomNumber(10);
    tokenIdToStats[tokenId].attack = tokenIdToStats[tokenId].attack + randomNumber(10);
    tokenIdToStats[tokenId].defense = tokenIdToStats[tokenId].defense + randomNumber(10);
    tokenIdToStats[tokenId].speed = tokenIdToStats[tokenId].speed + randomNumber(10);

    // Sets the new token URI
    _setTokenURI(tokenId, getTokenURI(tokenId));
  }

  function randomNumber(uint256 _number) private view returns (uint256) {
    return uint256(
      keccak256(
        abi.encodePacked(
          block.timestamp,
          block.difficulty,
          msg.sender
        )
      )
    ) % _number;
  }

  /**
  * TODOs:
  * Emit event when an NFT is minted and trained
  * Create new classes
  * Change SVG attributes dynamically
  */ 

}