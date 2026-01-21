import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/widgets/on_screen_keyboard.dart';

/// A login screen optimized for Android TV DPAD navigation.
///
/// Refactor notes:
/// - Username and Password are presented as focusable ListTile rows (TV-friendly).
/// - DPAD Up/Down moves focus between Username → Password → Login.
/// - DPAD Center/Enter selects a tile to edit via an on-screen keyboard overlay, or
///   activates the Login button.
/// - Pressing Login navigates to `/home` (no auth in this sample).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _username = '';
  String _password = '';

  late final FocusNode _usernameTileFocusNode;
  late final FocusNode _passwordTileFocusNode;
  late final FocusNode _loginButtonFocusNode;

  @override
  void initState() {
    super.initState();
    _usernameTileFocusNode = FocusNode(debugLabel: 'username_tile');
    _passwordTileFocusNode = FocusNode(debugLabel: 'password_tile');
    _loginButtonFocusNode = FocusNode(debugLabel: 'login_button');

    // On TV, it's often desirable to have initial focus land on the first row.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _usernameTileFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _usernameTileFocusNode.dispose();
    _passwordTileFocusNode.dispose();
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
      if (currentNode == _usernameTileFocusNode) {
        _requestNext(_passwordTileFocusNode);
        return KeyEventResult.handled;
      }
      if (currentNode == _passwordTileFocusNode) {
        _requestNext(_loginButtonFocusNode);
        return KeyEventResult.handled;
      }
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      if (currentNode == _loginButtonFocusNode) {
        _requestPrev(_passwordTileFocusNode);
        return KeyEventResult.handled;
      }
      if (currentNode == _passwordTileFocusNode) {
        _requestPrev(_usernameTileFocusNode);
        return KeyEventResult.handled;
      }
    }

    final bool isSelect =
        key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter;

    if (isSelect && currentNode == _loginButtonFocusNode) {
      _triggerLogin();
      return KeyEventResult.handled;
    }

    // For tiles, Select/Enter is handled by the tile Focus wrapper so it works
    // even when ListTile doesn't receive/translate the key into a tap event.
    return KeyEventResult.ignored;
  }

  // PUBLIC_INTERFACE
  Future<void> _editValueWithKeyboard({
    required String title,
    required String initialValue,
    required bool obscurePreview,
    required ValueChanged<String> onSaved,
    required FocusNode returnFocusTo,
  }) async {
    /// Opens a TV-friendly on-screen keyboard overlay and returns the typed value.
    ///
    /// While the keyboard is open, a temporary buffer is used. On Done, the buffer
    /// is returned and applied via `onSaved`. On Cancel/Back, returns null and does
    /// not modify the field.
    ///
    /// After the overlay closes, focus is restored to `returnFocusTo`.
    final String? result = await OnScreenKeyboard.show(
      context,
      title: title,
      initialValue: initialValue,
      obscurePreview: obscurePreview,
    );

    if (!mounted) return;

    if (result != null) {
      setState(() => onSaved(result));
    }

    // Restoring focus immediately after the dialog closes can be flaky on TV
    // devices because focus is still settling after Navigator.pop.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      returnFocusTo.requestFocus();
    });
  }

  String _passwordPreview(String value) {
    if (value.isEmpty) return '';
    // Keep it simple: show a fixed "••••" so we don't leak length on screen.
    return '••••';
  }

  Widget _focusableTile({
    required FocusNode focusNode,
    required String title,
    required String valuePreview,
    required VoidCallback onActivate,
  }) {
    KeyEventResult handleTileKey(FocusNode node, KeyEvent event) {
      final KeyEventResult traversal = _handleDpadTraversal(node, event);
      if (traversal == KeyEventResult.handled) return traversal;

      if (event is! KeyDownEvent) return KeyEventResult.ignored;

      // Many TV remotes send DPAD_CENTER as Select/Enter. When we wrap ListTile
      // with Focus(onKeyEvent), ListTile may never see the key and thus won't
      // translate it into a tap. Explicitly trigger activation here.
      final LogicalKeyboardKey key = event.logicalKey;
      final bool isSelect =
          key == LogicalKeyboardKey.select ||
          key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.numpadEnter;

      if (isSelect && (node == _usernameTileFocusNode || node == _passwordTileFocusNode)) {
        onActivate();
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

    return Focus(
      focusNode: focusNode,
      onKeyEvent: (node, event) => handleTileKey(node, event),
      child: Builder(
        builder: (context) {
          final bool hasFocus = Focus.of(context).hasFocus;
          final ColorScheme scheme = Theme.of(context).colorScheme;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: hasFocus
                  ? scheme.primary.withAlpha(26)
                  : scheme.surface.withAlpha(255),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasFocus ? scheme.primary : scheme.outlineVariant,
                width: hasFocus ? 3 : 2,
              ),
            ),
            child: ListTile(
              dense: false,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: hasFocus ? scheme.primary : scheme.onSurface,
                ),
              ),
              trailing: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  valuePreview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              onTap: onActivate,
            ),
          );
        },
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

                  _focusableTile(
                    focusNode: _usernameTileFocusNode,
                    title: 'Username',
                    valuePreview: _username.isEmpty ? 'Select to enter' : _username,
                    onActivate: () async {
                      await _editValueWithKeyboard(
                        title: 'Username',
                        initialValue: _username,
                        obscurePreview: false,
                        returnFocusTo: _usernameTileFocusNode,
                        onSaved: (value) {
                          _username = value;
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  _focusableTile(
                    focusNode: _passwordTileFocusNode,
                    title: 'Password',
                    valuePreview: _password.isEmpty
                        ? 'Select to enter'
                        : _passwordPreview(_password),
                    onActivate: () async {
                      await _editValueWithKeyboard(
                        title: 'Password',
                        initialValue: _password,
                        obscurePreview: true,
                        returnFocusTo: _passwordTileFocusNode,
                        onSaved: (value) {
                          _password = value;
                        },
                      );
                    },
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
                            // IMPORTANT:
                            // Do not pass `_loginButtonFocusNode` here because the outer `Focus`
                            // already owns it. A FocusNode can only be attached to one Focus
                            // widget; attaching it twice can break the focus tree and trigger:
                            // "Tried to make a child into a parent of itself".
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
                    'Use DPAD ↑/↓ to move focus. Press Select to edit fields or login.',
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
