//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


error USE_EXISTING_TOKEN_ID();
error YOU_MUST_OWN_TOKEN_TO_TRAIN();

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Skills {
        uint256 level;
        uint256 skills;
        uint256 communication;
        uint256 knowledge;
    }

    mapping(uint256 => Skills) public tokenIdtoSkills;

    //     Substitute the current tokenIdToLevels[] mapping with a struct that stores:
    // Level
    // Speed
    // Strength
    // Life

    constructor() ERC721("Web3 Builders", "W3B") {}

    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<defs>",
            '<linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="0%">',
            '<stop offset="0%" style="stop-color:cyan;stop-opacity:1"/>',
            '<stop offset="100%" style="stop-color:purple;stop-opacity:1"/>',
            "</linearGradient>",
            "</defs>",
            "<style>.base { font-family: verdana; font-size: 16px; font-weight: bold;}</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle" fill="url(#grad)">',
            "Web3 Builder",
            "</text>",
            '<text x="50%" y="55%" class="base" dominant-baseline="middle" text-anchor="middle" fill="url(#grad)">',
            "Level: ",
            getLevel(tokenId),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle" fill="url(#grad)">',
            "Skill: ",
            getSkill(tokenId),
            "</text>",
            '<text x="50%" y="65%" class="base" dominant-baseline="middle" text-anchor="middle" fill="url(#grad)">',
            "Communication: ",
            getCommunication(tokenId),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle" fill="url(#grad)">',
            "Knowledge: ",
            getKnowledge(tokenId),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getLevel(uint256 tokenId) public view returns (string memory) {
        Skills memory skill = tokenIdtoSkills[tokenId];
        return skill.level.toString();
    }

    function getSkill(uint256 tokenId) public view returns (string memory) {
        Skills memory skill = tokenIdtoSkills[tokenId];
        return skill.skills.toString();
    }

    function getCommunication(uint256 tokenId) public view returns (string memory) {
        Skills memory skill = tokenIdtoSkills[tokenId];
        return skill.communication.toString();
    }

    function getKnowledge(uint256 tokenId) public view returns (string memory) {
        Skills memory skill = tokenIdtoSkills[tokenId];
        return skill.knowledge.toString();
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Web3 Buidlers',
            tokenId.toString(),
            '",',
            '"description": "Web3 Builders Skills",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        Skills storage _skill = tokenIdtoSkills[newItemId];
        _skill.level = 1;
        _skill.skills = 2;
        _skill.communication = 2;
        _skill.knowledge = 2;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        if(_exists(tokenId) == false){
            revert USE_EXISTING_TOKEN_ID(); 
        }

        if(ownerOf(tokenId) != msg.sender){
            revert YOU_MUST_OWN_TOKEN_TO_TRAIN();
        }
        // require(_exists(tokenId), "Please use an Existing Token ID");
        // require(
        //     ownerOf(tokenId) == msg.sender,
        //     "You must own this token to train it"
        // );

        Skills storage _skill = tokenIdtoSkills[tokenId];

        uint256 currentLevel = _skill.level;
        _skill.level = currentLevel + 1;

        uint256 currentSkill = _skill.skills;
        _skill.skills = currentSkill + getRandomNumber(currentSkill);

        uint256 currentCommunication = _skill.communication;
        _skill.communication = currentCommunication + getRandomNumber(currentCommunication);

        uint256 currentKnowledge = _skill.knowledge;
        _skill.knowledge = currentKnowledge + getRandomNumber(currentKnowledge);
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function getRandomNumber(uint256 max) public view returns (uint256) {
        bytes memory seed = abi.encodePacked(block.timestamp,block.difficulty,msg.sender);
        uint256 rand = random(seed,max);
        return rand;
    }

    function random(bytes memory _seed, uint256 max) private pure returns (uint256) {
        return uint256(keccak256(_seed)) % max;        
    }
}
