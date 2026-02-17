import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Custom Markdown widget that supports colored text
class ColoredMarkdownBody extends StatelessWidget {
  final String data;
  final MarkdownStyleSheet? styleSheet;

  const ColoredMarkdownBody({
    super.key,
    required this.data,
    this.styleSheet,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      styleSheet: styleSheet,
      builders: {
        'p': ColoredTextBuilder(),
        'h1': ColoredTextBuilder(),
        'h2': ColoredTextBuilder(),
        'h3': ColoredTextBuilder(),
        'h4': ColoredTextBuilder(),
        'h5': ColoredTextBuilder(),
        'h6': ColoredTextBuilder(),
        'li': ColoredTextBuilder(),
        'blockquote': ColoredTextBuilder(),
        'em': ColoredTextBuilder(),
        'strong': ColoredTextBuilder(),
      },
    );
  }
}

class ColoredTextBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitText(text, TextStyle? preferredStyle) {
    final String rawText = text.text;

    // Check if text contains our color tags
    if (!rawText.contains('<colored-text color:')) {
      return null; // Let default builder handle it
    }

    final List<InlineSpan> spans = [];
    final regex =
        RegExp(r'<colored-text color:(#[0-9A-Fa-f]{6})>(.*?)<\/colored-text>');
    int lastIndex = 0;

    for (final match in regex.allMatches(rawText)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: rawText.substring(lastIndex, match.start),
          style: preferredStyle,
        ));
      }

      // Add colored text
      final colorHex = match.group(1)!;
      final coloredText = match.group(2)!;
      final color =
          Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);

      spans.add(TextSpan(
        text: coloredText,
        style: (preferredStyle ?? const TextStyle()).copyWith(color: color),
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < rawText.length) {
      spans.add(TextSpan(
        text: rawText.substring(lastIndex),
        style: preferredStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
