import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:study_cards/src/composables/colored_text_syntax.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

/// Custom Markdown Editor with real-time preview
class MarkdownEditorField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final Widget? suffixIcon;
  final bool enableHardLineBreak;

  const MarkdownEditorField({
    super.key,
    required this.controller,
    this.labelText,
    this.suffixIcon,
    this.enableHardLineBreak = true,
  });

  @override
  State<MarkdownEditorField> createState() => _MarkdownEditorFieldState();
}

class _MarkdownEditorFieldState extends State<MarkdownEditorField> {
  bool _editMode = true;
  final List<String> _history = [];
  int _historyIndex = -1;
  bool _isUndoing = false;
  String _lastSavedText = '';

  @override
  void initState() {
    super.initState();
    // Add initial text to history (even if empty)
    _history.add(widget.controller.text);
    _lastSavedText = widget.controller.text;
    _historyIndex = 0;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_isUndoing) return;

    final currentText = widget.controller.text;

    // Save to history only if:
    // 1. A space or newline was just added
    // 2. Text is now empty (delete all)
    final textDiff = currentText.length - _lastSavedText.length;
    final shouldSave = currentText.isEmpty ||
        (textDiff > 0 &&
            (currentText.endsWith(' ') || currentText.endsWith('\n')));

    if (shouldSave && _lastSavedText != currentText) {
      // Remove any history after current index
      if (_historyIndex < _history.length - 1) {
        _history.removeRange(_historyIndex + 1, _history.length);
      }

      _history.add(currentText);
      _lastSavedText = currentText;
      _historyIndex = _history.length - 1;

      // Limit history to 50 entries
      if (_history.length > 50) {
        _history.removeAt(0);
        _historyIndex--;
      }

      setState(() {});
    }
  }

  void _undo() {
    if (_historyIndex > 0) {
      _isUndoing = true;
      _historyIndex--;
      final previousText = _history[_historyIndex];
      widget.controller.text = previousText;
      widget.controller.selection = TextSelection.collapsed(
        offset: previousText.length,
      );
      setState(() {});
      _isUndoing = false;
    }
  }

  void _insertText(String text, {int cursorOffset = 0}) {
    final currentText = widget.controller.text;
    final selection = widget.controller.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    widget.controller.value = widget.controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + text.length + cursorOffset,
      ),
    );
  }

  void _insertLinePrefix(String prefix) {
    final currentText = widget.controller.text;
    final selection = widget.controller.selection;

    if (selection.start == selection.end) {
      // No selection - add prefix at start of current line
      final lines = currentText.split('\n');
      int currentPos = 0;
      int lineIndex = 0;

      for (int i = 0; i < lines.length; i++) {
        if (currentPos + lines[i].length >= selection.start) {
          lineIndex = i;
          break;
        }
        currentPos += lines[i].length + 1; // +1 for newline
      }

      lines[lineIndex] = '$prefix${lines[lineIndex]}';
      final newText = lines.join('\n');

      widget.controller.value = widget.controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + prefix.length,
        ),
      );
    } else {
      // Selection exists - add prefix to each selected line
      final selectedText =
          currentText.substring(selection.start, selection.end);
      final lines = selectedText.split('\n');
      final modifiedLines = lines.map((line) => '$prefix$line').toList();
      final newSelectedText = modifiedLines.join('\n');

      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        newSelectedText,
      );

      widget.controller.value = widget.controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + newSelectedText.length,
        ),
      );
    }
  }

  void _wrapText(String before, String after) {
    final currentText = widget.controller.text;
    final selection = widget.controller.selection;
    final selectedText = currentText.substring(selection.start, selection.end);
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      '$before$selectedText$after',
    );
    widget.controller.value = widget.controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + before.length + selectedText.length,
      ),
    );
  }

  Future<void> _showColorPicker() async {
    Color pickerColor = Theme.of(context).colorScheme.primary;
    
    final bool result = await ColorPicker(
      color: pickerColor,
      onColorChanged: (Color color) => pickerColor = color,
      width: 40,
      height: 40,
      borderRadius: 8,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 200,
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.wheel: true,
      },
      enableShadesSelection: false,
      selectedPickerTypeColor: Theme.of(context).colorScheme.primary,
    ).showPickerDialog(
      context,
      constraints: const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
      actionsPadding: const EdgeInsets.all(16),
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      elevation: 2,
    );

    if (result) {
      final colorHex = '#${pickerColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      _wrapText('<colored-text color:$colorHex>', '</colored-text>');
    }
  }

  String _processMarkdown(String text) {
    if (!widget.enableHardLineBreak) return text;
    return processMarkdownLineBreaks(text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_editMode || widget.controller.text.isEmpty)
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: widget.labelText,
              suffixIcon: widget.suffixIcon,
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
          )
        else
          InkWell(
            onTap: () {
              setState(() {
                _editMode = true;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 24.0, left: 2.0),
              constraints: const BoxConstraints(minHeight: 100),
              child: MarkdownBody(
                data: _processMarkdown(widget.controller.text),
                inlineSyntaxes: [ColoredTextSyntax()],
                builders: {'colored-text': ColoredTextBuilder()},
                styleSheet: MarkdownStyleSheet(
                  textAlign: WrapAlignment.start,
                  p: const TextStyle(fontSize: 16),
                  h1: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  h2: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  h3: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  h4: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold),
                  h5: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  h6: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                  listBullet: const TextStyle(fontSize: 16),
                  blockquote: const TextStyle(
                      fontSize: 16, fontStyle: FontStyle.italic),
                  code: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  strong: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  em: const TextStyle(
                      fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ),
        if (_editMode) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolbarButton(
                    icon: Icons.visibility,
                    tooltip: 'Preview',
                    onPressed: () {
                      setState(() {
                        _editMode = false;
                      });
                    },
                  ),
                  _ToolbarButton(
                    icon: Icons.undo,
                    tooltip: 'Undo',
                    onPressed: _historyIndex > 0 ? _undo : null,
                  ),
                  _ToolbarButton(
                    icon: Icons.title,
                    tooltip: 'Heading',
                    onPressed: () => _insertLinePrefix('# '),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_bold,
                    tooltip: 'Bold',
                    onPressed: () => _wrapText('**', '**'),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_italic,
                    tooltip: 'Italic',
                    onPressed: () => _wrapText('*', '*'),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_list_bulleted,
                    tooltip: 'List',
                    onPressed: () => _insertLinePrefix('- '),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_list_numbered,
                    tooltip: 'List',
                    onPressed: () => _insertLinePrefix('1. '),
                  ),
                  _ToolbarButton(
                    icon: Icons.code,
                    tooltip: 'Code',
                    onPressed: () => _wrapText('`', '`'),
                  ),
                  _ToolbarButton(
                    icon: Icons.keyboard_tab,
                    tooltip: 'Tab',
                    onPressed: () => _insertText('    '),
                  ),
                  _ToolbarButton(
                    icon: Icons.color_lens,
                    tooltip: 'Color Text',
                    onPressed: _showColorPicker,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: onPressed == null
                  ? Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
