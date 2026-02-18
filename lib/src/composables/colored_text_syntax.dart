import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

String processMarkdownLineBreaks(String text) {
  final lines = text.split('\n');
  final processedLines = <String>[];

  for (int i = 0; i < lines.length; i++) {
    final currentLine = lines[i];
    final isIndented = currentLine.startsWith('    ');

    if (i < lines.length - 1) {
      final nextLine = lines[i + 1];
      final nextIsIndented = nextLine.startsWith('    ');
      final nextIsEmpty = nextLine.trim().isEmpty;

      if (isIndented && !nextIsIndented && !nextIsEmpty) {
        processedLines.add(currentLine);
        processedLines.add('');
      } else if (!nextIsEmpty && currentLine.isNotEmpty) {
        processedLines.add('$currentLine  ');
      } else {
        processedLines.add(currentLine);
      }
    } else {
      processedLines.add(currentLine);
    }
  }

  return processedLines.join('\n');
}

class ColoredTextSyntax extends md.InlineSyntax {
  ColoredTextSyntax()
      : super(r'<colored-text color:(#[0-9A-Fa-f]{6})>(.*?)</colored-text>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final colorHex = match.group(1)!;
    final text = match.group(2)!;

    final element = md.Element('colored-text', [md.Text(text)]);
    element.attributes['color'] = colorHex;
    parser.addNode(element);
    return true;
  }
}

class ColoredTextBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag != 'colored-text') {
      return const SizedBox.shrink();
    }

    final colorHex = element.attributes['color'];
    final text = element.textContent;

    final color = colorHex != null
        ? Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000)
        : null;

    final baseStyle = preferredStyle ?? const TextStyle(fontSize: 16);

    return Builder(
      builder: (context) {
        final effectiveStyle = baseStyle.copyWith(
          fontSize: 18,
          color: color,
        );

        return Text(text, style: effectiveStyle);
      },
    );
  }
}
