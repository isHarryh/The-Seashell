import 'package:flutter/material.dart';
import '/services/provider.dart';

/// A wrapper widget that manages sync operations with smooth animations.
class SyncPowered extends StatefulWidget {
  final WidgetBuilder childBuilder;
  final VoidCallback? onSyncStart;
  final VoidCallback? onSyncEnd;

  const SyncPowered({
    super.key,
    required this.childBuilder,
    this.onSyncStart,
    this.onSyncEnd,
  });

  @override
  State<SyncPowered> createState() => _SyncPoweredState();
}

class _SyncPoweredState extends State<SyncPowered>
    with TickerProviderStateMixin {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;

  static const Duration _fadeDuration = Duration(milliseconds: 300);
  static const Duration _delayBeforeShow = Duration(milliseconds: 300);

  bool _syncCompleted = false;
  bool _syncCancelled = false;
  late AnimationController _loadingOpacityController;
  late Animation<double> _loadingOpacity;

  @override
  void initState() {
    super.initState();

    _loadingOpacityController = AnimationController(
      duration: _fadeDuration,
      vsync: this,
    );

    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingOpacityController,
        curve: Curves.easeInOut,
      ),
    );

    _performSync();
  }

  @override
  void dispose() {
    _loadingOpacityController.dispose();
    super.dispose();
  }

  Future<void> _performSync() async {
    try {
      widget.onSyncStart?.call();

      await _serviceProvider.maybeUpdateConfigAndApplyChanges();
    } catch (e) {
      // Silently ignore sync errors
    } finally {
      if (mounted && !_syncCancelled) {
        await _loadingOpacityController.reverse();
        setState(() {
          _syncCompleted = true;
        });

        widget.onSyncEnd?.call();
      }
    }
  }

  void _handleCancel() {
    setState(() {
      _syncCancelled = true;
    });
    _loadingOpacityController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_syncCompleted || _syncCancelled) widget.childBuilder(context),

        if (!_syncCompleted && !_syncCancelled ||
            _loadingOpacityController.status == AnimationStatus.forward ||
            _loadingOpacityController.status == AnimationStatus.reverse)
          Center(child: _buildLoadingIndicator()),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return FutureBuilder(
      future: Future.delayed(_delayBeforeShow),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !_syncCompleted &&
            !_syncCancelled) {
          // Start fading in loading indicator after delay
          if (_loadingOpacityController.status == AnimationStatus.dismissed) {
            _loadingOpacityController.forward();
          }
        }

        return FadeTransition(
          opacity: _loadingOpacity,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '正在同步数据...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _handleCancel,
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
