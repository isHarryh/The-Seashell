import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ustb_sso/ustb_sso.dart';

enum UstbSsoState {
  none,
  init,
  openingAuth,
  fetchingAuth,
  solvingAuth,
  authFinishing,
  success,
  initFailed,
  authFailed,
}

// SSO State Extension
extension UstbSsoStateExtension on UstbSsoState {
  IconData get icon {
    switch (this) {
      case UstbSsoState.none:
        return Icons.hourglass_bottom;
      case UstbSsoState.init:
      case UstbSsoState.openingAuth:
      case UstbSsoState.fetchingAuth:
        return Icons.pending_outlined;
      case UstbSsoState.solvingAuth:
        return Icons.hourglass_bottom;
      case UstbSsoState.authFinishing:
        return Icons.pending_outlined;
      case UstbSsoState.success:
        return Icons.check_circle;
      case UstbSsoState.initFailed:
      case UstbSsoState.authFailed:
        return Icons.error_outline;
    }
  }

  double get progress {
    switch (this) {
      case UstbSsoState.none:
        return 0.0;
      case UstbSsoState.init:
        return 0.2;
      case UstbSsoState.openingAuth:
        return 0.5;
      case UstbSsoState.fetchingAuth:
        return 0.8;
      case UstbSsoState.solvingAuth:
        return 1.0;
      case UstbSsoState.authFinishing:
        return 0.5;
      case UstbSsoState.success:
        return 1.0;
      case UstbSsoState.initFailed:
      case UstbSsoState.authFailed:
        return 0.0;
    }
  }

  bool get isError {
    switch (this) {
      case UstbSsoState.initFailed:
      case UstbSsoState.authFailed:
        return true;
      default:
        return false;
    }
  }
}

/// USTB SSO Authentication Widget
class UstbSsoAuthWidget extends StatefulWidget {
  final ApplicationParam applicationParam;

  final Function(dynamic response, HttpSession session) onSuccess;

  final String? defaultSmsPhone;

  final Function(String)? onUpdateSmsPhone;

  const UstbSsoAuthWidget({
    super.key,
    required this.applicationParam,
    required this.onSuccess,
    this.defaultSmsPhone,
    this.onUpdateSmsPhone,
  });

  @override
  State<UstbSsoAuthWidget> createState() => _UstbSsoAuthWidgetState();
}

class _UstbSsoAuthWidgetState extends State<UstbSsoAuthWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Progress animation controller
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _opacityAnimation;

  // QR Code authentication state
  QrAuthProcedure? _qrAuth;
  Uint8List? _qrImageBytes;
  UstbSsoState _qrState = UstbSsoState.none;
  String? _qrErrorMessage;

  // SMS authentication state
  SmsAuthProcedure? _smsAuth;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  int _smsCountdown = 0;
  UstbSsoState _smsState = UstbSsoState.none;
  String? _smsErrorMessage;

  // Common authentication
  HttpSession? _session;

  // Current displayed state (based on active tab)
  UstbSsoState get _currentState =>
      _tabController.index == 0 ? _qrState : _smsState;
  String? get _errorMessage =>
      _tabController.index == 0 ? _qrErrorMessage : _smsErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _tabController.addListener(_onTabChanged);
    _phoneController.addListener(() => setState(() {}));
    _smsCodeController.addListener(() => setState(() {}));

    // Set default SMS phone if provided
    if (widget.defaultSmsPhone != null) {
      _phoneController.text = widget.defaultSmsPhone!;
    }

    _initializeQrAuth();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      // Update animation to match the new tab's state
      _updateProgressAnimation(_currentState);

      // Initialize QR authentication if switching to QR tab and not already initialized
      if (_tabController.index == 0) {
        if (_qrState == UstbSsoState.none && _qrImageBytes == null) {
          _initializeQrAuth();
        }
      }
      // SMS tab doesn't need auto-initialization, wait for user to click get verification code

      // Trigger a rebuild to show the correct state
      setState(() {});
    }
  }

  // Get status message based on state and authentication type
  String _getStatusMessage(UstbSsoState state, bool isSmsTab) {
    if (!isSmsTab) {
      // QR authentication messages
      switch (state) {
        case UstbSsoState.none:
          return '等待初始化';
        case UstbSsoState.init:
          return '正在初始化';
        case UstbSsoState.openingAuth:
          return '正在建立认证管线';
        case UstbSsoState.fetchingAuth:
          return '正在获取二维码';
        case UstbSsoState.solvingAuth:
          return '请扫描二维码并确认登录';
        case UstbSsoState.authFinishing:
          return '正在获取令牌';
        case UstbSsoState.success:
          return '认证完成';
        case UstbSsoState.initFailed:
          return '无法获取二维码';
        case UstbSsoState.authFailed:
          return '认证失败';
      }
    } else {
      // SMS authentication messages
      switch (state) {
        case UstbSsoState.none:
          return '等待发送验证码';
        case UstbSsoState.init:
          return '正在初始化';
        case UstbSsoState.openingAuth:
          return '正在建立认证管线';
        case UstbSsoState.fetchingAuth:
          return '正在发送验证码';
        case UstbSsoState.solvingAuth:
          return '请输入验证码';
        case UstbSsoState.authFinishing:
          return '正在获取令牌';
        case UstbSsoState.success:
          return '认证完成';
        case UstbSsoState.initFailed:
          return '无法发送验证码';
        case UstbSsoState.authFailed:
          return '认证失败';
      }
    }
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _tabController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  // Update progress animation when state changes
  void _updateProgressAnimation(UstbSsoState newState) {
    bool shouldShowProgress(double progress) {
      return progress != 0.0 && progress != 1.0;
    }

    final newProgress = newState.progress;
    final currentProgress = _currentState.progress;
    final shouldShowNew = shouldShowProgress(newProgress);
    final shouldShowCurrent = shouldShowProgress(currentProgress);

    // Get current animated values to avoid jumps
    final currentAnimatedProgress = _progressAnimation.value;
    final currentAnimatedOpacity = _opacityAnimation.value;

    // Update progress animation
    final progressTween = Tween<double>(
      begin: currentAnimatedProgress,
      end: newProgress,
    );
    _progressAnimation = progressTween.animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Update opacity animation
    final opacityTween = Tween<double>(
      begin: currentAnimatedOpacity,
      end: shouldShowNew ? 1.0 : 0.0,
    );
    _opacityAnimation = opacityTween.animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    if (currentProgress != newProgress || shouldShowCurrent != shouldShowNew) {
      _progressAnimationController.reset();
      if (currentProgress > newProgress) {
        _progressAnimationController.value = 1.0;
      } else {
        _progressAnimationController.forward(from: 0.0);
      }
    }
  }

  // Helper method to update QR state with progress animation
  void _updateQrState(UstbSsoState newState, {String? errorMessage}) {
    _updateProgressAnimation(newState);
    setState(() {
      _qrState = newState;
      if (errorMessage != null) {
        _qrErrorMessage = errorMessage;
      }
    });
  }

  // Helper method to update SMS state with progress animation
  void _updateSmsState(UstbSsoState newState, {String? errorMessage}) {
    _updateProgressAnimation(newState);
    setState(() {
      _smsState = newState;
      if (errorMessage != null) {
        _smsErrorMessage = errorMessage;
      }
    });
  }

  Future<void> _initializeQrAuth() async {
    try {
      _updateQrState(UstbSsoState.init);

      _session = HttpSession();
      _qrAuth = QrAuthProcedure(
        entityId: widget.applicationParam.entityId,
        redirectUri: widget.applicationParam.redirectUri,
        state: widget.applicationParam.state,
        session: _session!,
      );

      await _qrAuth!.openAuth();

      _updateQrState(UstbSsoState.openingAuth);
      await _qrAuth!.useWechatAuth();
      await _qrAuth!.useQrCode();

      _updateQrState(UstbSsoState.fetchingAuth);
      _qrImageBytes = await _qrAuth!.getQrImage();

      _updateQrState(UstbSsoState.solvingAuth);
      // Wait for QR code scanning and confirmation
      try {
        final passCode = await _qrAuth!.waitForPassCode();

        _updateQrState(UstbSsoState.authFinishing);
        final response = await _qrAuth!.completeQrAuth(passCode);

        _updateQrState(UstbSsoState.success);
        widget.onSuccess(response, _session!);
      } catch (e) {
        if (mounted) {
          final errorMsg = '$e';
          _updateQrState(UstbSsoState.authFailed, errorMessage: errorMsg);
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = '$e';
        _updateQrState(UstbSsoState.initFailed, errorMessage: errorMsg);
      }
    }
  }

  Future<void> _sendSmsCode() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      return;
    }

    // Update SMS phone via callback if provided
    widget.onUpdateSmsPhone?.call(phoneNumber);

    try {
      _updateSmsState(UstbSsoState.init);

      _session ??= HttpSession();
      _smsAuth = SmsAuthProcedure(
        entityId: widget.applicationParam.entityId,
        redirectUri: widget.applicationParam.redirectUri,
        state: widget.applicationParam.state,
        session: _session!,
      );

      _updateSmsState(UstbSsoState.openingAuth);
      await _smsAuth!.openAuth();
    } catch (e) {
      if (mounted) {
        final errorMsg = '$e';
        _updateSmsState(UstbSsoState.initFailed, errorMessage: errorMsg);
        return;
      }
    }

    int autoRetry = 5;

    do {
      try {
        _updateSmsState(UstbSsoState.fetchingAuth);
        await _smsAuth!.sendSms(phoneNumber);
        break;
      } catch (e) {
        if (mounted) {
          final errorMsg = '$e';
          if (autoRetry >= 1 && errorMsg.contains('图形验证不通过')) {
            autoRetry -= 1;
            await Future.delayed(const Duration(seconds: 1));
          } else {
            _updateSmsState(UstbSsoState.initFailed, errorMessage: errorMsg);
            return;
          }
        } else {
          return;
        }
      }
    } while (autoRetry >= 0);

    try {
      setState(() {
        _smsCountdown = 60;
        _smsErrorMessage = null;
      });

      _updateSmsState(UstbSsoState.solvingAuth);
      _startSmsCountdown();
    } catch (e) {
      if (mounted) {
        final errorMsg = '$e';
        _updateSmsState(UstbSsoState.authFailed, errorMessage: errorMsg);
      }
    }
  }

  void _startSmsCountdown() {
    if (_smsCountdown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _smsCountdown--;
          });
          _startSmsCountdown();
        }
      });
    }
  }

  Future<void> _submitSmsCode() async {
    final phoneNumber = _phoneController.text.trim();
    final smsCode = _smsCodeController.text.trim();
    if (phoneNumber.isEmpty || smsCode.isEmpty) {
      return;
    }

    try {
      _updateSmsState(UstbSsoState.authFinishing);
      final token = await _smsAuth!.submitSmsCode(phoneNumber, smsCode);
      final response = await _smsAuth!.completeSmsAuth(token);

      _updateSmsState(UstbSsoState.success);
      widget.onSuccess(response, _session!);
    } catch (e) {
      if (mounted) {
        final errorMsg = '$e';
        _updateSmsState(UstbSsoState.authFailed, errorMessage: errorMsg);
      }
    }
  }

  // Build Status area widget
  Widget _buildStatusArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Status indicator
        Icon(
          _currentState.icon,
          color: _currentState.isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        const SizedBox(height: 4),

        // Status message
        Text(
          _getStatusMessage(_currentState, _tabController.index == 1),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: _currentState.isError
                ? Theme.of(context).colorScheme.error
                : null,
          ),
        ),
        const SizedBox(height: 4),

        // Progress bar
        AnimatedBuilder(
          animation: _progressAnimationController,
          builder: (context, child) {
            return AnimatedOpacity(
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutCubic,
              opacity: _opacityAnimation.value,
              child: Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _currentState.isError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 14,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  // Build QR Code area widget
  Widget _buildQrCodeArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: _qrImageBytes != null
              ? AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _currentState != UstbSsoState.solvingAuth
                      ? 0.2
                      : 1.0,
                  child: Image.memory(
                    _qrImageBytes!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                )
              : Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.qr_code_2_outlined,
                    size: 100,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
        ),
        const SizedBox(height: 8),

        // Retry button
        if (_tabController.index == 0 && _qrErrorMessage != null)
          ElevatedButton.icon(
            onPressed: () async {
              if (_tabController.index == 0) {
                setState(() {
                  _qrErrorMessage = null;
                  _qrImageBytes = null;
                });
                _updateQrState(UstbSsoState.none);
                await _initializeQrAuth();
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
          ),
      ],
    );
  }

  // Build QR code login content
  Widget _buildQrCodeLoginContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useHorizontalLayout = constraints.maxWidth > 600;

        if (useHorizontalLayout) {
          // Horizontal layout
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Center(child: _buildQrCodeArea())),
              const SizedBox(width: 16),
              Expanded(child: Center(child: _buildStatusArea())),
            ],
          );
        } else {
          // Vertical layout
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildQrCodeArea(),
              const SizedBox(height: 16),
              _buildStatusArea(),
            ],
          );
        }
      },
    );
  }

  // Build SMS login content
  Widget _buildSmsLoginContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useHorizontalLayout = constraints.maxWidth > 600;

        if (useHorizontalLayout) {
          // Horizontal layout
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Center(child: _buildSmsInputArea())),
              const SizedBox(width: 16),
              Expanded(child: Center(child: _buildStatusArea())),
            ],
          );
        } else {
          // Vertical layout
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSmsInputArea(),
              const SizedBox(height: 16),
              _buildStatusArea(),
            ],
          );
        }
      },
    );
  }

  // Build SMS input area
  Widget _buildSmsInputArea() {
    final isBusy =
        _currentState == UstbSsoState.init ||
        _currentState == UstbSsoState.openingAuth ||
        _currentState == UstbSsoState.fetchingAuth;
    final canInputCode =
        _currentState != UstbSsoState.none &&
        _currentState != UstbSsoState.init &&
        _currentState != UstbSsoState.openingAuth &&
        _currentState != UstbSsoState.fetchingAuth;
    final canSendSms =
        _currentState == UstbSsoState.none &&
        _smsCountdown <= 0 &&
        _phoneController.text.trim().isNotEmpty;
    final canResendSms =
        canInputCode &&
        _smsCountdown <= 0 &&
        _phoneController.text.trim().isNotEmpty;
    final canLogin =
        (_currentState == UstbSsoState.solvingAuth ||
            _currentState == UstbSsoState.authFailed) &&
        _phoneController.text.trim().isNotEmpty &&
        _smsCodeController.text.trim().isNotEmpty;

    return SizedBox(
      width: 300,
      height: 240,
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Phone number input
          TextField(
            controller: _phoneController,
            enabled: !isBusy,
            keyboardType: TextInputType.phone,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: '手机号码',
              prefixIcon: const Icon(Icons.phone),
              suffixIcon: _phoneController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _phoneController.clear();
                        widget.onUpdateSmsPhone?.call("");
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),

          // SMS code input or send button
          if (!canInputCode) ...[
            // Full-width send SMS button when no code input needed
            ElevatedButton(
              onPressed: canSendSms ? _sendSmsCode : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 52),
              ),
              child: isBusy
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.send, size: 18),
                        SizedBox(width: 8),
                        Text(
                          '发送验证码',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ] else ...[
            // SMS code input with resend suffix
            TextField(
              controller: _smsCodeController,
              enabled: !isBusy,
              keyboardType: TextInputType.number,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: '验证码',
                prefixIcon: const Icon(Icons.numbers),
                suffixIcon: canResendSms
                    ? TextButton(
                        onPressed: _sendSmsCode,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '重新发送',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : _smsCountdown > 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            '${_smsCountdown}s',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                counterText: '',
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Login button
          if (canInputCode)
            ElevatedButton(
              onPressed: canLogin ? _submitSmsCode : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 52),
              ),
              child: (_currentState == UstbSsoState.authFinishing)
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.login, size: 18),
                        SizedBox(width: 8),
                        Text(
                          '确认登录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '微信二维码登录'),
              Tab(text: '短信验证码登录'),
            ],
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          // Tab content
          SizedBox(
            height: 450,
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // QR Code login tab
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _buildQrCodeLoginContent(),
                ),
                // SMS login tab
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _buildSmsLoginContent(),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 14,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  _extractDomainFromUri(widget.applicationParam.redirectUri),
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Extract domain from redirectUri for footer display
  String _extractDomainFromUri(String uri) {
    try {
      final parsedUri = Uri.parse(uri);
      return parsedUri.host.isNotEmpty ? parsedUri.host : uri;
    } catch (e) {
      return uri;
    }
  }
}
