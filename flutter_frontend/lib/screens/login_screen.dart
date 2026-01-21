import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A login screen optimized for Android TV DPAD navigation.
///
/// - Up/Down moves focus between username, password, and login button.
/// - Enter/Select on the Login button triggers login.
/// - Enter/Done on password triggers login.
/// - On "login" navigates to `/home` (no auth in this sample).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final FocusNode _usernameFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _loginButtonFocusNode;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode = FocusNode(debugLabel: 'username');
    _passwordFocusNode = FocusNode(debugLabel: 'password');
    _loginButtonFocusNode = FocusNode(debugLabel: 'login_button');

    // On TV, it's often desirable to have initial focus land on the first field.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _usernameFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loginButtonFocusNode.dispose();
    super.dispose();
  }

  void _requestNext(FocusNode next) => FocusScope.of(context).requestFocus(next);
  void _requestPrev(FocusNode prev) => FocusScope.of(context).requestFocus(prev);

  void _triggerLogin() {
    // No auth required per requirements. Navigate to home.
    Navigator.of(context).pushReplacementNamed('/home');
  }

  KeyEventResult _handleDpadTraversal(FocusNode currentNode, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      if (currentNode == _usernameFocusNode) {
        _requestNext(_passwordFocusNode);
        return KeyEventResult.handled;
      }
      if (currentNode == _passwordFocusNode) {
        _requestNext(_loginButtonFocusNode);
        return KeyEventResult.handled;
      }
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      if (currentNode == _loginButtonFocusNode) {
        _requestPrev(_passwordFocusNode);
        return KeyEventResult.handled;
      }
      if (currentNode == _passwordFocusNode) {
        _requestPrev(_usernameFocusNode);
        return KeyEventResult.handled;
      }
    }

    // Trigger login from password field on Enter/Select.
    final bool isSelect =
        key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter;

    if (isSelect && currentNode == _loginButtonFocusNode) {
      _triggerLogin();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  InputDecoration _tvInputDecoration({
    required String label,
    required bool hasFocus,
  }) {
    final Color focusColor = Theme.of(context).colorScheme.primary;
    final Color baseColor = Theme.of(context).colorScheme.outlineVariant;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 20,
        color: hasFocus ? focusColor : Theme.of(context).colorScheme.onSurface,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: baseColor,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: focusColor,
          width: 4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    // Keep content well within overscan-safe bounds.
    final double maxWidth = size.width * 0.55; // TV-safe, not too wide.
    final double cardWidth = maxWidth.clamp(520.0, 900.0);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: cardWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sign in',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 36),
                  Focus(
                    focusNode: _usernameFocusNode,
                    onKeyEvent: (node, event) =>
                        _handleDpadTraversal(node, event),
                    child: Builder(
                      builder: (context) {
                        final bool hasFocus = Focus.of(context).hasFocus;
                        return TextField(
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(fontSize: 22),
                          decoration: _tvInputDecoration(
                            label: 'Username',
                            hasFocus: hasFocus,
                          ),
                          onSubmitted: (_) => _requestNext(_passwordFocusNode),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  Focus(
                    focusNode: _passwordFocusNode,
                    onKeyEvent: (node, event) =>
                        _handleDpadTraversal(node, event),
                    child: Builder(
                      builder: (context) {
                        final bool hasFocus = Focus.of(context).hasFocus;
                        return TextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(fontSize: 22),
                          decoration: _tvInputDecoration(
                            label: 'Password',
                            hasFocus: hasFocus,
                          ),
                          onSubmitted: (_) => _triggerLogin(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  Focus(
                    focusNode: _loginButtonFocusNode,
                    onKeyEvent: (node, event) =>
                        _handleDpadTraversal(node, event),
                    child: Builder(
                      builder: (context) {
                        final bool hasFocus = Focus.of(context).hasFocus;

                        return SizedBox(
                          height: 64,
                          child: ElevatedButton(
                            focusNode: _loginButtonFocusNode,
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                              backgroundColor: hasFocus
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha(210),
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: hasFocus
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            onPressed: _triggerLogin,
                            child: const Text('Login'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Use DPAD ↑/↓ to move focus. Press Select to login.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
