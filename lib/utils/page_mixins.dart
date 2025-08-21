// Copyright (c) 2025, Harry Huang

import 'package:flutter/material.dart';
import '/services/provider.dart';

mixin PageStateMixin<T extends StatefulWidget> on State<T> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;

  ServiceProvider get serviceProvider => _serviceProvider;

  @override
  void initState() {
    super.initState();
    _serviceProvider.addListener(_onServiceStatusChanged);
    onServiceInit();
  }

  @override
  void dispose() {
    _serviceProvider.removeListener(_onServiceStatusChanged);
    super.dispose();
  }

  void _onServiceStatusChanged() {
    if (mounted) {
      onServiceStatusChanged();
    }
  }

  /// Override this method to initialize service-related data
  void onServiceInit() {}

  /// Override this method to handle service status changes
  void onServiceStatusChanged() {}
}

mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
        if (loading) _errorMessage = null;
      });
    }
  }

  void setError(String? error) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }

  void clearError() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Widget buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget buildErrorWidget({VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '未知错误',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ],
      ),
    );
  }
}
