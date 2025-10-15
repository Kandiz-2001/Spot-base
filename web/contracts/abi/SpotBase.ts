export const SPOTBASE_ABI = [
  {
    type: "function",
    name: "createPlace",
    stateMutability: "nonpayable",
    inputs: [
      { name: "name", type: "string" },
      { name: "description", type: "string" },
      { name: "location", type: "string" }
    ],
    outputs: [{ name: "placeId", type: "uint256" }]
  },
  {
    type: "function",
    name: "addReview",
    stateMutability: "nonpayable",
    inputs: [
      { name: "placeId", type: "uint256" },
      { name: "rating", type: "uint8" },
      { name: "text", type: "string" }
    ],
    outputs: []
  },
  {
    type: "function",
    name: "getPlace",
    stateMutability: "view",
    inputs: [{ name: "placeId", type: "uint256" }],
    outputs: [
      {
        name: "",
        type: "tuple",
        components: [
          { name: "creator", type: "address" },
          { name: "name", type: "string" },
          { name: "description", type: "string" },
          { name: "location", type: "string" },
          { name: "createdAt", type: "uint256" },
          { name: "reviewCount", type: "uint256" }
        ]
      }
    ]
  },
  {
    type: "function",
    name: "getReviews",
    stateMutability: "view",
    inputs: [{ name: "placeId", type: "uint256" }],
    outputs: [
      {
        name: "",
        type: "tuple[]",
        components: [
          { name: "reviewer", type: "address" },
          { name: "rating", type: "uint8" },
          { name: "text", type: "string" },
          { name: "createdAt", type: "uint256" }
        ]
      }
    ]
  },
  {
    type: "function",
    name: "nextPlaceId",
    stateMutability: "view",
    inputs: [],
    outputs: [{ name: "", type: "uint256" }]
  },
  {
    type: "event",
    name: "PlaceCreated",
    anonymous: false,
    inputs: [
      { name: "placeId", type: "uint256", indexed: true },
      { name: "creator", type: "address", indexed: true },
      { name: "name", type: "string", indexed: false }
    ]
  },
  {
    type: "event",
    name: "ReviewAdded",
    anonymous: false,
    inputs: [
      { name: "placeId", type: "uint256", indexed: true },
      { name: "reviewer", type: "address", indexed: true },
      { name: "rating", type: "uint8", indexed: false }
    ]
  }
] as const;
