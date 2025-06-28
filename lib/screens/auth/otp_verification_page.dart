import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinput/pinput.dart';
import 'package:ysyw/config/debug/debug.dart';
import 'package:ysyw/services/local_storage_service.dart';
import 'dart:async';
import '../../bloc/auth/authentication_bloc.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final bool isLogin;

  const OtpVerificationPage({
    super.key,
    required this.email,
    this.isLogin = false, //
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Pinput theme
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surface.withOpacity(0.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: colorScheme.primary, width: 2),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: colorScheme.primary.withOpacity(0.1),
        border: Border.all(color: colorScheme.primary),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: colorScheme.error.withOpacity(0.1),
        border: Border.all(color: colorScheme.error),
      ),
    );
    Debug.info(widget.email);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state is OtpResentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.primary,
              ),
            );
            _startResendTimer(); // Restart the resend timer
          } else if (state is VerificationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome ${state.user.name}!'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to home screen
            context.go('/home');
          } else if (state is AuthenticationAuthenticated) {
            // User is now authenticated
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back ${state.user.name}!'),
                backgroundColor: Colors.green,
              ),
            );
            final token = state.token;
            Debug.warning('User authenticated with token: $token');
            final role = state.user.role;
            LocalStorageService().saveAuthToken(token);
            Debug.info('Token saved successfully');
            Debug.info(
                'User authenticated successfully: ${state.user.toJson()}');
            // If this is a login flow, navigate to home directly
            Debug.info('isLogin: ${widget.isLogin.runtimeType}');
            if (widget.isLogin == true) {
              context.go('/home');
            } else {
              // Navigate based on user role
              Debug.info('User role: $role');
              if (role == "student") {
                context.go('/studentDetails', extra: {
                  "email": widget.email,
                  "name": state.user.name,
                  "userId": state.user.id,
                });
              } else {
                context.go('/home');
              }
            }
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Verify Your Email',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ve sent a 6-digit verification code to',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 48),

                // Illustration/Icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.sms4,
                      size: 60,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // OTP Input
                Center(
                  child: Pinput(
                    controller: _pinController,
                    focusNode: _focusNode,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    errorPinTheme: errorPinTheme,
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    onCompleted: (pin) {
                      _handleVerifyOtp(pin);
                    },
                    validator: (pin) {
                      if (pin == null || pin.length != 6) {
                        return 'Please enter a valid 6-digit code';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Verify Button
                BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  builder: (context, state) {
                    final isLoading = state is AuthenticationLoading;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading || _pinController.text.length != 6
                            ? null
                            : () => _handleVerifyOtp(_pinController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.onPrimary),
                                ),
                              )
                            : const Text(
                                'Verify Code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Resend Code Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Didn\'t receive the code?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _canResend
                          ? GestureDetector(
                              onTap: _handleResendCode,
                              child: Text(
                                'Resend Code',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Text(
                              'Resend code in ${_resendCountdown}s',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Check your spam folder if you don\'t see the email in your inbox.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Change Email
                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.pop(); // Go back to signup
                    },
                    child: Text(
                      'Change Email Address',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleVerifyOtp(String otp) {
    final authBloc = context.read<AuthenticationBloc>();

    authBloc.add(VerifyUserEvent(
      email: widget.email,
      otp: otp,
    ));
  }

  void _handleResendCode() async {
    context.read<AuthenticationBloc>().add(
          ResendOtpEvent(email: widget.email),
        );
  }
}
