import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import '../config/constants.dart';

class WalletService {
  static WalletService? _instance;
  static WalletService get instance {
    _instance ??= WalletService._();
    return _instance!;
  }

  WalletService._();

  Web3App? _web3App;
  SessionData? _session;
  String? _currentAddress;

  bool get isConnected => _session != null && _currentAddress != null;
  String? get currentAddress => _currentAddress;
  SessionData? get session => _session;

  Future<void> initialize() async {
    _web3App = await Web3App.createInstance(
      projectId: AppConstants.walletConnectProjectId,
      metadata: const PairingMetadata(
        name: 'SpotBase',
        description: 'Decentralized Location Discovery App',
        url: 'https://spotbase.app',
        icons: ['https://spotbase.app/icon.png'],
      ),
    );

    // Check for existing sessions
    final sessions = _web3App!.sessions.getAll();
    if (sessions.isNotEmpty) {
      _session = sessions.first;
      _currentAddress = _session!.namespaces['eip155']?.accounts.first.split(':').last;
    }

    // Listen to session events
    _web3App!.onSessionEvent.subscribe(_onSessionEvent);
    _web3App!.onSessionUpdate.subscribe(_onSessionUpdate);
    _web3App!.onSessionDelete.subscribe(_onSessionDelete);
  }

  Future<String> connect() async {
    if (_web3App == null) {
      await initialize();
    }

    try {
      final ConnectResponse response = await _web3App!.connect(
        requiredNamespaces: {
          'eip155': RequiredNamespace(
            chains: ['eip155:${AppConstants.chainId}'],
            methods: [
              'eth_sendTransaction',
              'eth_signTransaction',
              'eth_sign',
              'personal_sign',
              'eth_signTypedData',
            ],
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
      );

      final Uri? uri = response.uri;
      if (uri != null) {
        // Show QR code or deep link
        // For mobile, you can use url_launcher to open wallet apps
        print('WalletConnect URI: $uri');
      }

      // Wait for session approval
      _session = await response.session.future;
      _currentAddress = _session!.namespaces['eip155']?.accounts.first.split(':').last;

      return _currentAddress!;
    } catch (e) {
      throw Exception('Failed to connect wallet: $e');
    }
  }

  Future<void> disconnect() async {
    if (_session != null && _web3App != null) {
      await _web3App!.disconnectSession(
        topic: _session!.topic,
        reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
      );
      _session = null;
      _currentAddress = null;
    }
  }

  Future<String> sendTransaction({
    required String to,
    required String data,
    String? value,
  }) async {
    if (!isConnected) {
      throw Exception('Wallet not connected');
    }

    try {
      final result = await _web3App!.request(
        topic: _session!.topic,
        chainId: 'eip155:${AppConstants.chainId}',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': _currentAddress,
              'to': to,
              'data': data,
              if (value != null) 'value': value,
            }
          ],
        ),
      );

      return result as String;
    } catch (e) {
      throw Exception('Transaction failed: $e');
    }
  }

  Future<String> signMessage(String message) async {
    if (!isConnected) {
      throw Exception('Wallet not connected');
    }

    try {
      final result = await _web3App!.request(
        topic: _session!.topic,
        chainId: 'eip155:${AppConstants.chainId}',
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [message, _currentAddress],
        ),
      );

      return result as String;
    } catch (e) {
      throw Exception('Failed to sign message: $e');
    }
  }

  Future<EthereumAddress> getEthereumAddress() async {
    if (_currentAddress == null) {
      throw Exception('No wallet connected');
    }
    return EthereumAddress.fromHex(_currentAddress!);
  }

  String formatAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  void _onSessionEvent(SessionEvent? event) {
    print('Session event: ${event?.name}');
  }

  void _onSessionUpdate(SessionUpdate? update) {
    if (update != null) {
      _session = SessionData(
        topic: update.topic,
        pairingTopic: _session!.pairingTopic,
        relay: _session!.relay,
        expiry: _session!.expiry,
        acknowledged: _session!.acknowledged,
        controller: _session!.controller,
        namespaces: update.namespaces,
        self: _session!.self,
        peer: _session!.peer,
      );
    }
  }

  void _onSessionDelete(SessionDelete? delete) {
    _session = null;
    _currentAddress = null;
    print('Session deleted');
  }

  void dispose() {
    _web3App?.onSessionEvent.unsubscribe(_onSessionEvent);
    _web3App?.onSessionUpdate.unsubscribe(_onSessionUpdate);
    _web3App?.onSessionDelete.unsubscribe(_onSessionDelete);
  }
}