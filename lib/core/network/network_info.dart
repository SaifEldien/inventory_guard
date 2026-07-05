import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker? connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    if (kIsWeb) {
      return true; // Web always assumes connection, or we could use another check
    }
    return await connectionChecker?.hasConnection ?? true;
  }
}
