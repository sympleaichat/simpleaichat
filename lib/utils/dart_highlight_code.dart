import 'package:flutter/material.dart';

class DartHighlightedCode extends StatelessWidget {
  final String code;

  DartHighlightedCode({required this.code});

  @override
  Widget build(BuildContext context) {
    final spans = _highlightDartCode(code);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        //color: const Color.fromARGB(0, 0, 0, 0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText.rich(
        maxLines: null,
        TextSpan(children: spans),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          //  color: Colors.white,
        ),
      ),
    );
  }

  List<TextSpan> _highlightDartCode(String source) {
    final List<TextSpan> spans = [];

    final keywords = RegExp(
        r'\b(abstract|class|extends|final|if|else|import|return|void|new|var|int|double|bool|true|false|null|for|while|switch|case|break|continue|default|static|const)\b');
    final strings = '"' + '.*?' + '"' + '|' + "'" + '.*?' + "'";
    final stringsRegex = RegExp('(' + strings + ')');
    final comments = RegExp(r'(\/\/.*?$|\/\*[\s\S]*?\*\/)', multiLine: true);

    int currentIndex = 0;

    void addSpan(int start, int end, Color color) {
      if (start > currentIndex) {
        spans.add(TextSpan(text: source.substring(currentIndex, start)));
      }
      spans.add(TextSpan(
        text: source.substring(start, end),
        style: TextStyle(color: color),
      ));
      currentIndex = end;
    }

    final matches = [
      ...keywords
          .allMatches(source)
          .map((m) => {'start': m.start, 'end': m.end, 'color': Colors.blue}),
      ...strings
          .allMatches(source)
          .map((m) => {'start': m.start, 'end': m.end, 'color': Colors.orange}),
      ...comments
          .allMatches(source)
          .map((m) => {'start': m.start, 'end': m.end, 'color': Colors.green}),
    ];
    matches.sort(
      (a, b) => (a['start']! as int).compareTo(b['start']! as int),
    );

    for (final match in matches) {
      addSpan(
        match['start']! as int,
        match['end']! as int,
        match['color']! as Color,
      );
    }

    if (currentIndex < source.length) {
      spans.add(TextSpan(text: source.substring(currentIndex)));
    }

    return spans;
  }
}
