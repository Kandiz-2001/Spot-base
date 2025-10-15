// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title SpotBase - decentralized places and reviews on Base
/// @notice Minimal MVP for adding places and leaving reviews
contract SpotBase {
    struct Place {
        address creator;
        string name;
        string description;
        string location; // could be lat,long or on-chain place id
        uint256 createdAt;
        uint256 reviewCount;
    }

    struct Review {
        address reviewer;
        uint8 rating; // 1..5
        string text;
        uint256 createdAt;
    }

    // placeId => Place
    mapping(uint256 => Place) private places;
    // placeId => reviews
    mapping(uint256 => Review[]) private reviewsByPlace;
    // auto-increment id
    uint256 public nextPlaceId;

    event PlaceCreated(uint256 indexed placeId, address indexed creator, string name);
    event ReviewAdded(uint256 indexed placeId, address indexed reviewer, uint8 rating);

    error InvalidRating();
    error EmptyName();
    error EmptyLocation();
    error PlaceNotFound();

    function createPlace(string calldata name, string calldata description, string calldata location) external returns (uint256 placeId) {
        if (bytes(name).length == 0) revert EmptyName();
        if (bytes(location).length == 0) revert EmptyLocation();

        placeId = ++nextPlaceId; // start ids at 1
        places[placeId] = Place({
            creator: msg.sender,
            name: name,
            description: description,
            location: location,
            createdAt: block.timestamp,
            reviewCount: 0
        });

        emit PlaceCreated(placeId, msg.sender, name);
    }

    function addReview(uint256 placeId, uint8 rating, string calldata text) external {
        if (rating < 1 || rating > 5) revert InvalidRating();
        Place storage p = places[placeId];
        if (p.createdAt == 0) revert PlaceNotFound();

        reviewsByPlace[placeId].push(Review({
            reviewer: msg.sender,
            rating: rating,
            text: text,
            createdAt: block.timestamp
        }));
        p.reviewCount += 1;

        emit ReviewAdded(placeId, msg.sender, rating);
    }

    function getPlace(uint256 placeId) external view returns (Place memory) {
        Place memory p = places[placeId];
        if (p.createdAt == 0) revert PlaceNotFound();
        return p;
    }

    function getReviews(uint256 placeId) external view returns (Review[] memory) {
        Place memory p = places[placeId];
        if (p.createdAt == 0) revert PlaceNotFound();
        return reviewsByPlace[placeId];
    }
}
