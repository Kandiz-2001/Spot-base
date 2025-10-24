# SpotBase - Decentralized Location Discovery App

A Flutter mobile application built on Base blockchain that allows users to discover, review, and earn rewards for real-world locations.

## Features

- 🗺️ **Location Discovery**: Explore and spot locations using GPS or manual entry
- ⭐ **Reviews & Ratings**: Write reviews, share photos, earn SBT tokens
- 🎯 **GeoQuests**: Complete weekly challenges and earn NFT badges
- 💰 **Web3 Integration**: All actions are recorded on Base Sepolia blockchain
- 🏆 **Leaderboard**: Compete with other users based on reputation
- ✅ **Verification System**: High-reputation users can verify pending locations
- 📱 **Responsive Design**: Works seamlessly across different device sizes

## Tech Stack

- **Frontend**: Flutter 3.0+
- **State Management**: Provider
- **Blockchain**: Base Sepolia (EVM)
- **Backend**: Supabase (Auth, Database, Storage)
- **Web3**: WalletConnect, web3dart
- **Maps**: Flutter Map with OpenStreetMap tiles
- **Location**: Geolocator, Geocoding

## Prerequisites

Before you begin, ensure you have:

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode for mobile development
- Supabase account
- WalletConnect Project ID
- Base Sepolia RPC access

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/spotbase.git
cd spotbase
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Fill in your credentials:

```env
# Supabase
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Base Sepolia Network
RPC_URL=https://sepolia.base.org
CHAIN_ID=84532
NETWORK_NAME=Base Sepolia

# Smart Contracts (Already deployed)
SPOTBASE_TOKEN_ADDRESS=0x8eF00a5F252C9F23Cf981C7f7993a66C9e9C3Ef1
LOCATION_REGISTRY_ADDRESS=0xC67cF666608e3A22F6925e1603C06179Bc1ff7CC
REVIEW_NFT_ADDRESS=0x815E17f76a27ff3709dF1c71847fcA6CAe21b7E0

# WalletConnect
WALLETCONNECT_PROJECT_ID=get_from_walletconnect_cloud

# Optional
MAPBOX_ACCESS_TOKEN=your_mapbox_token_if_needed
```

### 4. Supabase Setup

#### A. Create Tables

Run the SQL scripts in your Supabase SQL Editor:

**See `supabase_schema.sql` file for complete database schema**

#### B. Create Storage Buckets

1. Go to Storage in Supabase Dashboard
2. Create three public buckets:
   - `location-images`
   - `review-images`
   - `profile-images`

#### C. Enable Authentication Providers

1. Go to Authentication > Providers
2. Enable:
   - Email/Password
   - Google OAuth
   - Apple OAuth (for iOS)

### 5. WalletConnect Setup

1. Go to [WalletConnect Cloud](https://cloud.walletconnect.com/)
2. Create a new project
3. Copy your Project ID to `.env`

### 6. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run

# For specific device
flutter run -d <device_id>
```

## Project Structure

```
lib/
├── config/
│   ├── theme.dart              # App theme and colors
│   └── constants.dart          # Configuration constants
├── models/
│   ├── user_model.dart         # User data model
│   ├── location_model.dart     # Location data model
│   ├── review_model.dart       # Review data model
│   └── geoquest_model.dart     # GeoQuest data model
├── services/
│   ├── supabase_service.dart   # Supabase integration
│   ├── web3_service.dart       # Blockchain integration
│   ├── wallet_service.dart     # Wallet connection
│   ├── storage_service.dart    # File uploads
│   └── location_service.dart   # GPS/location services
├── providers/
│   ├── auth_provider.dart      # Authentication state
│   ├── location_provider.dart  # Location state
│   ├── review_provider.dart    # Review state
│   └── user_provider.dart      # User state
├── screens/
│   ├── onboarding/            # Splash, onboarding, auth
│   ├── home/                  # Home screen with map
│   ├── location/              # Location screens
│   ├── review/                # Review screens
│   ├── profile/               # User profile
│   ├── geoquest/              # GeoQuests
│   └── leaderboard/           # Leaderboard
├── widgets/
│   ├── common/                # Reusable widgets
│   ├── location/              # Location-specific widgets
│   └── review/                # Review-specific widgets
├── utils/
│   ├── validators.dart        # Form validators
│   ├── helpers.dart           # Helper functions
│   └── extensions.dart        # Dart extensions
└── main.dart                  # App entry point
```

## Smart Contract Addresses (Base Sepolia)

- **SpotBase Token**: `0x8eF00a5F252C9F23Cf981C7f7993a66C9e9C3Ef1`
- **Location Registry**: `0xC67cF666608e3A22F6925e1603C06179Bc1ff7CC`
- **Review NFT**: `0x815E17f76a27ff3709dF1c71847fcA6CAe21b7E0`

## How to Use

1. **Sign Up/Login**: Create account with email or social login
2. **Connect Wallet**: WalletConnect modal will prompt wallet connection
3. **Explore Map**: Browse nearby locations on the map
4. **Spot Location**: Add new locations via GPS or manual entry
5. **Write Reviews**: Rate and review locations, upload photos
6. **Check-in**: Check-in at locations to earn tokens and maintain streaks
7. **Complete Quests**: Participate in weekly GeoQuests
8. **Earn Rewards**: Collect SBT tokens and NFT badges

## Known Issues & Limitations

- Users pay gas fees themselves (no gasless transactions yet)
- Manual location entries require verification by validators
- Maximum 5 reviews per location per user
- Daily check-in limit of 1 per location

## Testing

Currently, the app runs on Base Sepolia testnet. To test:

1. Get Base Sepolia ETH from [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-sepolia-faucet)
2. Connect your wallet (MetaMask, Rainbow, etc.)
3. Start spotting locations and earning test tokens

## Build for Production

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- GitHub Issues: [Create an issue](https://github.com/yourusername/spotbase/issues)
- Documentation: See `/docs` folder

## Acknowledgments

- Built on Base (Ethereum L2)
- Powered by Supabase
- Maps by OpenStreetMap
- WalletConnect for Web3 authentication
