// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

import {IVRFCoordinatorV2Plus} from "@chainlink/contracts@1.1.0/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts@1.1.0/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts@1.1.0/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {MetaData} from "./MetaData.sol";

/**
TODO: 
1. Test the below code
2. Change variable names to more meaningful names
3. Check ways to reduce gas consumption
4. check on pricing and check on receive and fallback
5. Add comments
*/

interface PriceConverterInterface {
    function convertUsdToMatic(
        uint256 ticketPrice
    ) external view returns (uint256);
}

interface NFTMetaDataInterface {
    function generateMetaData(
        uint256 _randomNumber,
        uint256 tokenId
    ) external pure returns (string memory);
}

contract Ticket is ERC721, ERC721URIStorage, VRFConsumerBaseV2Plus {
    using Counters for Counters.Counter;
    Counters.Counter internal tokenIdCounter;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus)
        internal s_requests; /* requestId --> requestStatus */
    IVRFCoordinatorV2Plus internal COORDINATOR;

    uint256 internal s_subscriptionId;

    uint256[] internal requestIds;
    uint256 internal lastRequestId;

    bytes32 private immutable keyHash =
        0x816bedba8a50b294e5cbd47842baf240c2385f2eaf719edbd4f250a137a8c899;
    uint32 private immutable callbackGasLimit = 2500000;
    uint16 private immutable requestConfirmations = 3;
    uint32 private immutable numWords = 2;
    address private immutable vr_coordinator =
        0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2;
    uint256 private constant TICKET_PRICE_USD = 20 * 10 ** 18;

    mapping(uint256 => address) private ticket_owner_adress;

    PriceConverterInterface internal convertPrice;
    NFTMetaDataInterface internal nftMetaData;
    address private eventOwner;
    mapping(address => uint) private _balance;

    struct nftDetails {
        uint256 tokenId;
        address ownerAdd;
        uint256 randomNum;
        uint256 randomNum2;
        uint256 finalRandomNum;
        address nftAddress;
        bool isMinted;
        bool paid;
    }

    mapping(uint256 => nftDetails) public listOfNftDetails;

    constructor(
        uint256 _subscriptionId,
        address _nftMetaDataAddress,
        address _priceConverterAddress
    )
        ERC721("Chainlink FootBall 2024", "CIFA")
        VRFConsumerBaseV2Plus(vr_coordinator)
    {
        COORDINATOR = IVRFCoordinatorV2Plus(vr_coordinator);
        s_subscriptionId = _subscriptionId;
        convertPrice = PriceConverterInterface(_priceConverterAddress);
        nftMetaData = NFTMetaDataInterface(_nftMetaDataAddress);
        eventOwner = msg.sender;
    }

    function safeMint(address to) external returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;

        emit RequestSent(requestId, numWords);
        ticket_owner_adress[requestId] = to;

        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);

        uint256 random1 = (_randomWords[0] % 9);
        uint256 random2 = (_randomWords[1] % 5);

        uint256 randomNumber = random1 ^ random2;
        uint256 tokenId = tokenIdCounter.current();

        string memory finalTokenURI = nftMetaData.generateMetaData(
            randomNumber,
            tokenId
        );

        address userAddr = ticket_owner_adress[_requestId];
        tokenIdCounter.increment();
        _safeMint(userAddr, tokenId);
        _setTokenURI(tokenId, finalTokenURI);
        listOfNftDetails[_requestId] = nftDetails(
            tokenId,
            userAddr,
            random1,
            random2,
            randomNumber,
            address(this),
            true,
            false
        );
    }

    function convertUSDToMatic() external view returns (uint256) {
        return convertPrice.convertUsdToMatic(TICKET_PRICE_USD);
    }

    function confirmTransaction() external payable returns (uint256, address) {
        require(listOfNftDetails[lastRequestId].isMinted, "Not minted");
        nftDetails memory nft = listOfNftDetails[lastRequestId];
        _balance[address(this)] += msg.value;
        listOfNftDetails[lastRequestId].paid = true;
        return (nft.tokenId, nft.nftAddress);
    }

    function withdraw() public payable {
        // owner of the contract
        payable(eventOwner).transfer(address(this).balance);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}