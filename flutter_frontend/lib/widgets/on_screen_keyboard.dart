import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A TV-friendly on-screen keyboard intended for DPAD navigation.
///
/// The widget is designed to be used in a fullscreen/modal route (e.g. `showDialog`).
/// It maintains an internal buffer and emits callbacks for changes and completion.
///
/// Usage:
/// - `OnScreenKeyboard.show(...)` shows the keyboard as a dialog and returns the
///   submitted string, or `null` if cancelled.
class OnScreenKeyboard extends StatefulWidget {
  const OnScreenKeyboard({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSubmitted,
    required this.onCancelled,
    this.onChanged,
    this.obscurePreview = false,
  });

  /// Title shown at the top of the keyboard.
  final String title;

  /// Initial buffer contents.
  final String initialValue;

  /// Whether the preview line should display masked dots.
  final bool obscurePreview;

  /// Called whenever the buffer changes.
  final ValueChanged<String>? onChanged;

  /// Called when user presses Done/OK.
  final ValueChanged<String> onSubmitted;

  /// Called when user cancels (or presses back).
  final VoidCallback onCancelled;

  // PUBLIC_INTERFACE
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String initialValue,
    bool obscurePreview = false,
  }) {
    /// Presents the on-screen keyboard as a modal dialog.
    ///
    /// Returns the submitted text, or `null` if cancelled.
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // TV: avoid accidental dismiss via barrier tap.
      useSafeArea: true,
      builder: (dialogContext) {
        return Dialog.fullscreen(
          child: OnScreenKeyboard(
            title: title,
            initialValue: initialValue,
            obscurePreview: obscurePreview,
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
            onCancelled: () => Navigator.of(dialogContext).pop(null),
          ),
        );
      },
    );
  }

  @override
  State<OnScreenKeyboard> createState() => _OnScreenKeyboardState();
}

class _OnScreenKeyboardState extends State<OnScreenKeyboard> {
  late String _buffer;

  // Keep a stable focus scope so focus doesn't get lost during rebuilds.
  late final FocusScopeNode _keyboardScopeNode;

  // We keep individual key focus nodes so DPAD traversal is predictable and does
  // not rely on implicit focus order.
  late final List<FocusNode> _keyFocusNodes;

  /// Flattened key model used by the GridView.
  late final List<_KeySpec> _keys;

  // Track last-focused key index so we can restore focus after rebuilds.
  int _lastFocusedKeyIndex = 0;

  // Grid configuration (character rows are 10 columns; actions are appended).
  static const int _columns = 10;
  static const int _characterRows = 4;

  @override
  void initState() {
    super.initState();
    _keyboardScopeNode = FocusScopeNode(debugLabel: 'osk_scope');
    _buffer = widget.initialValue;
    _keys = _buildKeys();
    _keyFocusNodes = List<FocusNode>.generate(
      _keys.length,
      (i) => FocusNode(debugLabel: 'kb_key_${i}_${_keys[i].label}'),
    );

    for (int i = 0; i < _keyFocusNodes.length; i++) {
      _keyFocusNodes[i].addListener(() {
        if (_keyFocusNodes[i].hasFocus) {
          _lastFocusedKeyIndex = i;
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Start focus on first character key (top-left).
      if (_keyFocusNodes.isNotEmpty) {
        _keyboardScopeNode.requestFocus(_keyFocusNodes.first);
      }
    });
  }

  @override
  void didUpdateWidget(covariant OnScreenKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If focus was lost during a rebuild (can happen on some Android TV devices),
    // restore it to the last-focused key.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bool scopeHasFocus = _keyboardScopeNode.hasFocus;
      if (scopeHasFocus) return;

      if (_keyFocusNodes.isEmpty) return;
      final int index = _lastFocusedKeyIndex.clamp(0, _keyFocusNodes.length - 1);
      _keyboardScopeNode.requestFocus(_keyFocusNodes[index]);
    });
  }

  @override
  void dispose() {
    // Defensive: ensure focus doesn't get left attached to a soon-to-be disposed
    // subtree (rare but can happen on some TV devices during route transitions).
    FocusManager.instance.primaryFocus?.unfocus();

    for (final node in _keyFocusNodes) {
      node.dispose();
    }
    _keyboardScopeNode.dispose();
    super.dispose();
  }

  List<_KeySpec> _buildKeys() {
    // A simple TV-friendly layout:
    // - 10 columns x 5 rows of character keys (A-Z, 0-9, ., @, -)
    // - Bottom row includes Space, Backspace, Clear, Done, Cancel (larger keys)
    //
    // We keep it simple and predictable rather than trying to emulate mobile.
    const List<String> row1 = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    const List<String> row2 = <String>['K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T'];
    const List<String> row3 = <String>['U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3'];
    const List<String> row4 = <String>['4', '5', '6', '7', '8', '9', '.', '@', '-', '_'];

    final List<_KeySpec> keys = <_KeySpec>[];
    for (final s in <List<String>>[row1, row2, row3, row4]) {
      for (final ch in s) {
        keys.add(_KeySpec.char(label: ch, value: ch));
      }
    }

    // "Action strip" (row5). We keep 10 columns; some keys span multiple columns.
    // Spanning is done by duplicating specs with a span > 1 and using GridView
    // `SliverGridDelegateWithFixedCrossAxisCount` + custom layout isn't trivial.
    // Instead, we use a 10-column grid and represent spans by "wide" tiles built
    // with `LayoutBuilder` and `GridView` itemBuilder giving each a fixed width.
    //
    // Here we approximate wide keys by adding them in sequence and letting their
    // content take more space via padding; focus traversal remains linear.
    keys.add(_KeySpec.action(label: 'Space', action: _KeyboardAction.space));
    keys.add(_KeySpec.action(label: '⌫', action: _KeyboardAction.backspace));
    keys.add(_KeySpec.action(label: 'Clear', action: _KeyboardAction.clear));
    keys.add(_KeySpec.action(label: 'Done', action: _KeyboardAction.done));
    keys.add(_KeySpec.action(label: 'Cancel', action: _KeyboardAction.cancel));

    return keys;
  }

  void _notifyChanged() {
    widget.onChanged?.call(_buffer);
  }

  void _append(String s) {
    setState(() {
      _buffer += s;
    });
    _notifyChanged();
  }

  void _backspace() {
    if (_buffer.isEmpty) return;
    setState(() {
      _buffer = _buffer.substring(0, _buffer.length - 1);
    });
    _notifyChanged();
  }

  void _clear() {
    if (_buffer.isEmpty) return;
    setState(() {
      _buffer = '';
    });
    _notifyChanged();
  }

  void _space() {
    _append(' ');
  }

  void _submit() {
    widget.onSubmitted(_buffer);
  }

  void _cancel() {
    widget.onCancelled();
  }

  KeyEventResult _handleBack(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.goBack) {
      _cancel();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  String _previewText() {
    if (!widget.obscurePreview) return _buffer;
    if (_buffer.isEmpty) return '';
    // Fixed length preview to avoid leaking length.
    return '••••';
  }

  int _rowForIndex(int index) => index ~/ _columns;
  int _colForIndex(int index) => index % _columns;

  bool _isCharacterKeyIndex(int index) => index < _columns * _characterRows;

  KeyEventResult _handleKeyEvent({
    required int index,
    required _KeySpec spec,
    required KeyEvent event,
  }) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final LogicalKeyboardKey key = event.logicalKey;

    // Common "select" keys across Android TV remotes / keyboards / emulators.
    final bool isSelect =
        key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.gameButtonA;

    if (isSelect) {
      _activateKey(spec);

      // IMPORTANT: consume the event so it doesn't bubble and cause double
      // activations on some platforms.
      return KeyEventResult.handled;
    }

    // Explicit DPAD navigation: avoid platform-dependent implicit traversal.
    if (key == LogicalKeyboardKey.arrowLeft) {
      final int target = (index - 1).clamp(0, _keyFocusNodes.length - 1);
      _keyboardScopeNode.requestFocus(_keyFocusNodes[target]);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowRight) {
      final int target = (index + 1).clamp(0, _keyFocusNodes.length - 1);
      _keyboardScopeNode.requestFocus(_keyFocusNodes[target]);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      if (_isCharacterKeyIndex(index)) {
        final int row = _rowForIndex(index);
        final int col = _colForIndex(index);

        // Requirement: allow exiting back to the input fields when pressing UP
        // from the first keyboard row. We do that by cancelling the dialog,
        // letting the caller restore focus to the input tile.
        if (row == 0) {
          _cancel();
          return KeyEventResult.handled;
        }

        final int target = ((row - 1) * _columns + col)
            .clamp(0, _keyFocusNodes.length - 1);
        _keyboardScopeNode.requestFocus(_keyFocusNodes[target]);
        return KeyEventResult.handled;
      }

      // From action strip, move to the nearest character key in the last row.
      final int actionStripStart = _columns * _characterRows;
      final int actionIndex = index - actionStripStart;
      final int col = actionIndex.clamp(0, _columns - 1);
      final int target = ((_characterRows - 1) * _columns + col)
          .clamp(0, _keyFocusNodes.length - 1);
      _keyboardScopeNode.requestFocus(_keyFocusNodes[target]);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      if (_isCharacterKeyIndex(index)) {
        final int row = _rowForIndex(index);
        final int col = _colForIndex(index);

        // From last character row, go to action strip.
        if (row == _characterRows - 1) {
          final int actionStripStart = _columns * _characterRows;
          final int target =
              (actionStripStart + col).clamp(0, _keyFocusNodes.length - 1);
          _keyboardScopeNode.requestFocus(_keyFocusNodes[target]);
          return KeyEventResult.handled;
        }

        final int target = ((row + 1) * _columns + col)
            .clamp(0, _keyFocusNodes.length - 1);
        _keyboardScopeNode.requestFocus(_keyFocusNodes[target]);
        return KeyEventResult.handled;
      }

      // In action strip: do nothing (stay in row).
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Size size = MediaQuery.sizeOf(context);

    // Keep a generous inset for overscan safety and TV readability.
    final EdgeInsets pad = EdgeInsets.symmetric(
      horizontal: (size.width * 0.06).clamp(32.0, 96.0),
      vertical: (size.height * 0.06).clamp(24.0, 72.0),
    );

    // We use a Focus widget at the root to intercept DPAD_BACK/Escape, and a
    // stable FocusScope for the keyboard keys.
    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) => _handleBack(event),
      child: FocusScope(
        node: _keyboardScopeNode,
        child: Scaffold(
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: Padding(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withAlpha(255),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.outlineVariant, width: 2),
                  ),
                  child: Text(
                    _previewText().isEmpty ? ' ' : _previewText(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 24,
                          letterSpacing: 0.5,
                          color: scheme.onSurface,
                        ),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: FocusTraversalGroup(
                    // Keep for tab traversal / accessibility, but DPAD is handled
                    // explicitly per-key for Android TV stability.
                    policy: ReadingOrderTraversalPolicy(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double spacing = 12;
                        final double tileWidth =
                            (constraints.maxWidth - spacing * (_columns - 1)) / _columns;
                        final double tileHeight = (tileWidth * 0.75).clamp(56.0, 92.0);

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _columns,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: tileWidth / tileHeight,
                          ),
                          itemCount: _keys.length,
                          itemBuilder: (context, index) {
                            final _KeySpec spec = _keys[index];
                            final FocusNode node = _keyFocusNodes[index];

                            // Action strip: place actions in the last row by padding
                            // their content to look wider (not true spanning).
                            final bool isAction = spec.kind == _KeyKind.action;
                            final EdgeInsets contentPad = isAction
                                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                                : const EdgeInsets.symmetric(horizontal: 6, vertical: 8);

                            return Focus(
                              focusNode: node,
                              autofocus: false,
                              onKeyEvent: (node, event) => _handleKeyEvent(
                                index: index,
                                spec: spec,
                                event: event,
                              ),
                              child: Builder(
                                builder: (context) {
                                  final bool hasFocus = Focus.of(context).hasFocus;

                                  // High contrast focus ring for TV visibility.
                                  final Color focusBorder =
                                      hasFocus ? scheme.onPrimary : scheme.outlineVariant;
                                  final Color focusFill = hasFocus
                                      ? scheme.primary.withAlpha(220)
                                      : scheme.surfaceContainerHighest.withAlpha(160);

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    decoration: BoxDecoration(
                                      color: focusFill,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        // Wider ring improves visibility and also makes focus
                                        // detectable in tests.
                                        color: focusBorder,
                                        width: hasFocus ? 4 : 2,
                                      ),
                                      boxShadow: hasFocus
                                          ? <BoxShadow>[
                                              BoxShadow(
                                                color: scheme.primary.withAlpha(110),
                                                blurRadius: 18,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : const <BoxShadow>[],
                                    ),
                                    child: InkWell(
                                      canRequestFocus: true,
                                      onTap: () => _activateKey(spec),
                                      child: Center(
                                        child: Padding(
                                          padding: contentPad,
                                          child: Text(
                                            spec.label,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: isAction ? 18 : 20,
                                              fontWeight: FontWeight.w800,
                                              color: hasFocus
                                                  ? scheme.onPrimary
                                                  : scheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'DPAD: arrows to move • Select to press • Back to cancel',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        color: scheme.onSurfaceVariant,
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

  void _activateKey(_KeySpec spec) {
    switch (spec.kind) {
      case _KeyKind.character:
        _append(spec.value ?? '');
      case _KeyKind.action:
        switch (spec.action) {
          case _KeyboardAction.backspace:
            _backspace();
          case _KeyboardAction.space:
            _space();
          case _KeyboardAction.clear:
            _clear();
          case _KeyboardAction.done:
            _submit();
          case _KeyboardAction.cancel:
            _cancel();
          case null:
            // ignore
            break;
        }
    }
  }
}

enum _KeyKind { character, action }

enum _KeyboardAction { backspace, space, clear, done, cancel }

class _KeySpec {
  _KeySpec._({
    required this.kind,
    required this.label,
    this.value,
    this.action,
  });

  final _KeyKind kind;
  final String label;
  final String? value;
  final _KeyboardAction? action;

  factory _KeySpec.char({required String label, required String value}) =>
      _KeySpec._(kind: _KeyKind.character, label: label, value: value);

  factory _KeySpec.action({required String label, required _KeyboardAction action}) =>
      _KeySpec._(kind: _KeyKind.action, label: label, action: action);
}
