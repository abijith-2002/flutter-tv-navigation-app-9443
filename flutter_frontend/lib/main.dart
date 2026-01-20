import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

/// Root application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _openApiTitle = 'AI Build Tool';
  static const _appTitle = 'AI Build Tool';

  @override
  Widget build(BuildContext context) {
    // TV-friendly theme: larger typography & high-contrast focus visuals.
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    );

    return MaterialApp(
      title: _openApiTitle,
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: base.textTheme.copyWith(
          headlineMedium: base.textTheme.headlineMedium?.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 20),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 18),
        ),
      ),
      home: const LoginScreen(title: _appTitle),
    );
  }
}

/// Intent used to trigger "submit login" from DPAD_CENTER/ENTER.
class SubmitIntent extends Intent {
  const SubmitIntent();
}

/// A centered, DPAD-navigable login screen designed for Android TV.
///
/// Requirements implemented:
/// - Username + Password fields + Login button
/// - Explicit FocusNodes for each control
/// - Visible focus highlight when focused (10-foot UI sizing)
/// - DPAD-ready traversal using FocusTraversalGroup + Shortcuts/Actions
/// - Hardware key handling for DPAD_CENTER/ENTER to submit (mock validation)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  late final FocusNode _usernameFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _loginButtonFocusNode;

  // Primitive UI state only (safe to update after async gaps, if any later).
  String? _errorText;
  bool _didSubmit = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();

    _usernameFocusNode = FocusNode(debugLabel: 'usernameField');
    _passwordFocusNode = FocusNode(debugLabel: 'passwordField');
    _loginButtonFocusNode = FocusNode(debugLabel: 'loginButton');

    // Start focused on the username field for TV remotes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_usernameFocusNode.canRequestFocus) {
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

  // PUBLIC_INTERFACE
  /// Mock login submit handler (placeholder for real validation/auth).
  ///
  /// This function performs simple, local validation and sets UI state.
  /// No real authentication is performed.
  void handleSubmit() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _didSubmit = true;
      if (username.isEmpty || password.isEmpty) {
        _errorText = 'Please enter a username and password.';
      } else {
        // Placeholder hook for future: trigger navigation / call provider, etc.
        _errorText = null;
      }
    });
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    // Provide an explicit fallback for hardware keys; Shortcuts/Actions should
    // handle it too, but some TV devices can be inconsistent.
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.select ||
          key == LogicalKeyboardKey.gameButtonA) {
        handleSubmit();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // High-contrast focus colors suitable for 10-foot UI.
    final focusBorderColor = cs.primary;
    final unfocusedBorderColor =
        cs.outlineVariant.withAlpha((255 * 0.55).round());
    final cardColor = cs.surface;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        // DPAD_CENTER often maps to "select" (and sometimes Enter).
        const SingleActivator(LogicalKeyboardKey.select): const SubmitIntent(),
        const SingleActivator(LogicalKeyboardKey.enter): const SubmitIntent(),
        // Some controllers map center click to gameButtonA.
        const SingleActivator(LogicalKeyboardKey.gameButtonA):
            const SubmitIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SubmitIntent: CallbackAction<SubmitIntent>(
            onInvoke: (intent) {
              handleSubmit();
              return null;
            },
          ),
        },
        child: KeyboardListener(
          focusNode: FocusNode(debugLabel: 'loginKeyboardListener'),
          onKeyEvent: (event) {
            // Safety net: handle submit keys even if focus/shortcuts are flaky.
            _onKeyEvent(FocusNode(), event);
          },
          autofocus: true,
          child: Scaffold(
            backgroundColor: cs.surface,
            body: Center(
              child: FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 40,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: cs.outlineVariant.withAlpha(120),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sign in',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Use your remote to navigate. Press OK/ENTER to submit.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 26),

                            _FocusableField(
                              label: 'Username',
                              hintText: 'Enter username',
                              controller: _usernameController,
                              focusNode: _usernameFocusNode,
                              textInputAction: TextInputAction.next,
                              obscureText: false,
                              onSubmitted: (_) {
                                // Move focus forward on submit.
                                _passwordFocusNode.requestFocus();
                              },
                              focusedBorderColor: focusBorderColor,
                              unfocusedBorderColor: unfocusedBorderColor,
                            ),

                            const SizedBox(height: 18),

                            _FocusableField(
                              label: 'Password',
                              hintText: 'Enter password',
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              textInputAction: TextInputAction.done,
                              obscureText: true,
                              onSubmitted: (_) {
                                // On TV this might come from a soft keyboard;
                                // still allow it to submit.
                                handleSubmit();
                              },
                              focusedBorderColor: focusBorderColor,
                              unfocusedBorderColor: unfocusedBorderColor,
                            ),

                            const SizedBox(height: 22),

                            _FocusableButton(
                              focusNode: _loginButtonFocusNode,
                              label: 'Login',
                              onPressed: handleSubmit,
                              onKeyEvent: _onKeyEvent,
                            ),

                            const SizedBox(height: 16),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              child: _errorText != null
                                  ? Container(
                                      key: const ValueKey('errorText'),
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: cs.errorContainer,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: cs.error.withAlpha(140),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Text(
                                        _errorText!,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: cs.onErrorContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    )
                                  : (_didSubmit
                                      ? Container(
                                          key: const ValueKey(
                                              'successPlaceholder'),
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: cs.primaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: cs.primary.withAlpha(140),
                                              width: 1.2,
                                            ),
                                          ),
                                          child: Text(
                                            'Mock submit OK (no real auth yet).',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: cs.onPrimaryContainer,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        )
                                      : const SizedBox.shrink()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusableField extends StatelessWidget {
  const _FocusableField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.textInputAction,
    required this.obscureText,
    required this.onSubmitted,
    required this.focusedBorderColor,
    required this.unfocusedBorderColor,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final bool obscureText;
  final ValueChanged<String> onSubmitted;
  final Color focusedBorderColor;
  final Color unfocusedBorderColor;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasFocus ? focusedBorderColor : unfocusedBorderColor,
                width: hasFocus ? 3.0 : 1.5,
              ),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: obscureText,
                  textInputAction: textInputAction,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withAlpha(170),
                        ),
                  ),
                  onSubmitted: onSubmitted,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FocusableButton extends StatelessWidget {
  const _FocusableButton({
    required this.focusNode,
    required this.label,
    required this.onPressed,
    required this.onKeyEvent,
  });

  final FocusNode focusNode;
  final String label;
  final VoidCallback onPressed;
  final KeyEventResult Function(FocusNode, KeyEvent) onKeyEvent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Focus(
      focusNode: focusNode,
      onKeyEvent: onKeyEvent,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;

          return AnimatedScale(
            scale: hasFocus ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasFocus ? cs.primary : cs.outlineVariant,
                  width: hasFocus ? 3.0 : 1.5,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasFocus ? cs.primary : cs.surfaceContainerHighest,
                    foregroundColor: hasFocus ? cs.onPrimary : cs.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: hasFocus ? 6 : 1,
                  ),
                  onPressed: onPressed,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
