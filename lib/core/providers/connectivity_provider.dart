import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { isConnected, isDisconnected, notDetermined }

final connectivityStatusProvider = StateNotifierProvider<ConnectivityStatusNotifier, ConnectivityStatus>((ref) {
  return ConnectivityStatusNotifier();
});

class ConnectivityStatusNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityStatusNotifier() : super(ConnectivityStatus.notDetermined) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateStatus(results);
    });
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      // Si "none" est présent, ou si la liste est vide (ce qui ne devrait pas arriver selon la doc mais bon)
      // On vérifie s'il n'y a QUE "none"
      if (results.length == 1 && results.first == ConnectivityResult.none) {
        state = ConnectivityStatus.isDisconnected;
      } else {
        // Parfois "none" peut être retourné avec d'autres types sur certains OS ?
        // Mais normalement si on a autre chose que none, on est connecté.
        state = ConnectivityStatus.isConnected;
      }
    } else {
      state = ConnectivityStatus.isConnected;
    }
  }

  Future<void> retry() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }
}
