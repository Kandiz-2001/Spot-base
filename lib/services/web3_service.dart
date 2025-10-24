import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class Web3Service {
  static Web3Service? _instance;
  static Web3Service get instance {
    _instance ??= Web3Service._();
    return _instance!;
  }

  Web3Service._();

  late Web3Client _client;
  late DeployedContract _tokenContract;
  late DeployedContract _registryContract;
  late DeployedContract _reviewNftContract;

  // Contract ABIs (from your provided JSON files)
  static const String tokenAbi = '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"allowance","type":"uint256"},{"internalType":"uint256","name":"needed","type":"uint256"}],"name":"ERC20InsufficientAllowance","type":"error"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"balance","type":"uint256"},{"internalType":"uint256","name":"needed","type":"uint256"}],"name":"ERC20InsufficientBalance","type":"error"},{"inputs":[{"internalType":"address","name":"approver","type":"address"}],"name":"ERC20InvalidApprover","type":"error"},{"inputs":[{"internalType":"address","name":"receiver","type":"address"}],"name":"ERC20InvalidReceiver","type":"error"},{"inputs":[{"internalType":"address","name":"sender","type":"address"}],"name":"ERC20InvalidSender","type":"error"},{"inputs":[{"internalType":"address","name":"spender","type":"address"}],"name":"ERC20InvalidSpender","type":"error"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"OwnableInvalidOwner","type":"error"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"OwnableUnauthorizedAccount","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"minter","type":"address"}],"name":"RewardMinterSet","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"mintInitial","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"mintReward","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"rewardMinter","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_minter","type":"address"}],"name":"setRewardMinter","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"}]';

  static const String registryAbi = '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"OwnableInvalidOwner","type":"error"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"OwnableUnauthorizedAccount","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"id","type":"uint256"},{"indexed":false,"internalType":"string","name":"name","type":"string"},{"indexed":true,"internalType":"address","name":"addedBy","type":"address"}],"name":"LocationAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"id","type":"uint256"},{"indexed":false,"internalType":"string","name":"name","type":"string"},{"indexed":true,"internalType":"address","name":"updatedBy","type":"address"}],"name":"LocationUpdated","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"string","name":"category","type":"string"},{"internalType":"string","name":"ipfsHash","type":"string"},{"internalType":"int256","name":"latitude","type":"int256"},{"internalType":"int256","name":"longitude","type":"int256"}],"name":"addLocation","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"locationCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"}],"name":"locationExists","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"locations","outputs":[{"internalType":"uint256","name":"id","type":"uint256"},{"internalType":"string","name":"name","type":"string"},{"internalType":"string","name":"category","type":"string"},{"internalType":"string","name":"ipfsHash","type":"string"},{"internalType":"int256","name":"latitude","type":"int256"},{"internalType":"int256","name":"longitude","type":"int256"},{"internalType":"address","name":"addedBy","type":"address"},{"internalType":"bool","name":"exists","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"id","type":"uint256"},{"internalType":"string","name":"name","type":"string"},{"internalType":"string","name":"category","type":"string"},{"internalType":"string","name":"ipfsHash","type":"string"},{"internalType":"int256","name":"latitude","type":"int256"},{"internalType":"int256","name":"longitude","type":"int256"}],"name":"updateLocation","outputs":[],"stateMutability":"nonpayable","type":"function"}]';

  Future<void> initialize() async {
    _client = Web3Client(AppConstants.rpcUrl, http.Client());

    _tokenContract = DeployedContract(
      ContractAbi.fromJson(tokenAbi, 'SpotBaseToken'),
      EthereumAddress.fromHex(AppConstants.tokenAddress),
    );

    _registryContract = DeployedContract(
      ContractAbi.fromJson(registryAbi, 'LocationRegistry'),
      EthereumAddress.fromHex(AppConstants.registryAddress),
    );
  }

  // Token Balance
  Future<BigInt> getTokenBalance(String address) async {
    final function = _tokenContract.function('balanceOf');
    final result = await _client.call(
      contract: _tokenContract,
      function: function,
      params: [EthereumAddress.fromHex(address)],
    );
    return result.first as BigInt;
  }

  // Add Location to Blockchain
  Future<String> addLocationToBlockchain({
    required Credentials credentials,
    required String name,
    required String category,
    required String ipfsHash,
    required double latitude,
    required double longitude,
  }) async {
    final function = _registryContract.function('addLocation');
    
    // Convert coordinates to int256 (multiply by 1e6 for precision)
    final latInt = BigInt.from((latitude * 1000000).round());
    final lngInt = BigInt.from((longitude * 1000000).round());

    final transaction = Transaction.callContract(
      contract: _registryContract,
      function: function,
      parameters: [name, category, ipfsHash, latInt, lngInt],
    );

    final txHash = await _client.sendTransaction(
      credentials,
      transaction,
      chainId: AppConstants.chainId,
    );

    return txHash;
  }

  // Get Location Count
  Future<BigInt> getLocationCount() async {
    final function = _registryContract.function('locationCount');
    final result = await _client.call(
      contract: _registryContract,
      function: function,
      params: [],
    );
    return result.first as BigInt;
  }

  // Check if location exists on blockchain
  Future<bool> locationExists(int locationId) async {
    final function = _registryContract.function('locationExists');
    final result = await _client.call(
      contract: _registryContract,
      function: function,
      params: [BigInt.from(locationId)],
    );
    return result.first as bool;
  }

  void dispose() {
    _client.dispose();
  }
}