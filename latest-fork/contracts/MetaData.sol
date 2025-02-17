// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts@4.6.0/utils/Base64.sol";
import "@openzeppelin/contracts@4.6.0/utils/Strings.sol";

contract MetaData {

      function generateMetaData(uint256 _randomNumber,  uint256 _tokenId) pure external returns (string memory){
       
        string memory ticketImage = "https://ipfs.io/ipfs/QmPuo9Bxfhwbf7t7RkdBJwP6WDMGht5Bat8bzYz5S8ktWu?filename=FootBallTicket.jpeg";
        if (_randomNumber == 7){ 
            ticketImage = "ipfs://bafybeid6yni6xppmwua6wky27cubjkcn4jbswqdhhbmkcuegarvphz3744/";
        }

        string memory newUri = Base64.encode(
                    bytes(
                        string(
                            abi.encodePacked(
                                '{"name": "CIFA - Chainlink FootBall 2024 - Updated",'
                                '"description": "Chainlink FootBall 2024 - This is a Test NFT for the Hackathon",',
                                 '"image": "', ticketImage, '",'
                                '"attributes": [',
                                    '{"display_type": "Ticket Number","trait_type": "ticket_number",', '"value": ', Strings.toString(_tokenId) ,'}',
                                    ',{"display_type": "Event Name", "trait_type": "event_name",', '"value": "CIFA - Chainlink Foot Ball 2024"}',
                                    ',{"display_type": "Description", "trait_type": "description",', '"value": "Chainlink FootBall 2024 - This is a Test NFT for a Hackathon"}',
                                    ',{"display_type": "Teams", "trait_type": "teams",', '"value": "Manchester United vs Chelsea"}',
                                    ',{"display_type": "Date", "trait_type": "date",', '"value": "2nd June 2024"}',
                                    ',{"display_type": "Time", "trait_type": "time",', '"value": "3.15 PM"}',
                                    ',{"display_type": "Venue", "trait_type": "venue",', '"value": "Allianz Stadium, Sydney, Australia"}',
                                    ',{"display_type": "Seat Number", "trait_type": "seat_number",', '"value": "A10"}',
                                    ',{"display_type": "Exclusive eligibility", "trait_type": "exclusive_eligibility",', '"value": "false"}',
                                ']}'
                            )
                        )
                    )
                );

        string memory finalTokenURI = string(
             abi.encodePacked("data:application/json;base64,", newUri)
        );

        return finalTokenURI;
      }
}