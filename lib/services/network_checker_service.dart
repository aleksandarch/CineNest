import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import '../constants/constants.dart';

class NetworkCheckerService {
  static final NetworkCheckerService _instance =
      NetworkCheckerService._internal();
  factory NetworkCheckerService() => _instance;

  NetworkCheckerService._internal() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _hasConnection = true;
  bool _toShowWhenBackOnline = false;
  Timer? _noConnectionTimer;

  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  OverlaySupportEntry? _currentNotification;

  void _init() {
    // Monitor connectivity changes
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      debugPrint(result.toString());
      debugPrint(result.last.toString());
      final bool currentStatus = result.last != ConnectivityResult.none;
      _handleConnectionChange(currentStatus);
    });

    // Perform initial check
    checkConnection();
  }

  Future<void> checkConnection() async {
    final List<ConnectivityResult> result =
        await _connectivity.checkConnectivity();
    final bool currentStatus =
        result.last != ConnectivityResult.none; // Not sure .last or .first
    _handleConnectionChange(currentStatus);
  }

  void _handleConnectionChange(bool currentStatus) {
    if (currentStatus != _hasConnection) {
      _hasConnection = currentStatus;
      _connectionStatusController.add(_hasConnection);

      if (_hasConnection) {
        // Connection restored
        if (_toShowWhenBackOnline) {
          _currentNotification?.dismiss();
          _showStatusPopup(true);
          _toShowWhenBackOnline = false;
        }
        // Cancel any existing no-connection timer
        _noConnectionTimer?.cancel();
      } else {
        // Connection lost
        _showStatusPopup(false);
        _toShowWhenBackOnline = true;
        // Start a timer to show "No Connection" every 12 seconds
        _startNoConnectionTimer();
      }
    } else {
      // Even if the status hasn't changed, ensure the timer is correctly managed
      if (!_hasConnection && _noConnectionTimer == null) {
        _startNoConnectionTimer();
      } else if (_hasConnection) {
        _noConnectionTimer?.cancel();
        _noConnectionTimer = null;
      }
    }
  }

  void _startNoConnectionTimer() {
    _noConnectionTimer?.cancel(); // Cancel any existing timer
    _noConnectionTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      if (!_hasConnection) {
        _showStatusPopup(false);
      } else {
        // Cancel the timer if connection is restored
        timer.cancel();
      }
    });
  }

  void _showStatusPopup(bool hasConnection) {
    _currentNotification = showOverlayNotification((context) {
      return Material(
        color: hasConnection
            ? AppConstants.kSuccessColor
            : AppConstants.kNoInternetColor,
        elevation: 3,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top, bottom: 5),
          child: Text(hasConnection ? 'Back Online' : 'No Connection',
              style: const TextStyle(fontSize: 14)),
        ),
      );
    }, duration: Duration(seconds: hasConnection ? 4 : 7));
  }

  void dispose() {
    _subscription?.cancel();
    _noConnectionTimer?.cancel();
    _connectionStatusController.close();
  }
}

// Singleton instance
final networkCheckerService = NetworkCheckerService();
