class Memory {
  final String id;
  String content;
  bool select;

  Memory({
    required this.id,
    required this.content,
    this.select = false,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'],
      content: json['content'],
      select: json['select'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'select': select,
    };
  }

  /// Generates a formatted string of selected memory content wrapped in custom XML-like tags,
  /// to be inserted before the user's message, providing structured context to the AI model.
  /// This version includes an instruction for the AI not to acknowledge the reference information.
  ///
  /// This function filters the provided list of [memories] for items
  /// where [Memory.select] is true. It then formats these selected memories
  /// within <ReferenceInformation> tags, with each individual memory in <data> tags.
  /// This structured format helps the AI model clearly delineate the reference material.
  ///
  /// [memories]: A list of Memory objects, potentially containing selected and unselected items.
  /// [userInputMessage]: The original message provided by the user.
  ///
  /// Returns a combined string with the formatted selected memories preceding
  /// the [userInputMessage]. If no memories are selected, it returns the
  /// [userInputMessage] unchanged.
  static String buildMessageWithMemories(
      List<Memory> memories, String userInputMessage) {
    if (memories.isEmpty || memories.length == 0) {
      return userInputMessage;
    }

    // Filter out only the selected memories.
    final List<Memory> selectedMemories =
        memories.where((m) => m.select).toList();

    // If no memories are selected, return the user message as is.
    if (selectedMemories.isEmpty) {
      return userInputMessage;
    }

    // Build the string for selected memories using custom tags.
    final StringBuffer memoryStringBuilder = StringBuffer();
    memoryStringBuilder.writeln(
        "<ReferenceInformation>"); // Opening tag for the reference block

    // Add the instruction to the AI model
    memoryStringBuilder.writeln(
        "  <data>AI: Please use the following information as context for your response, but do not explicitly acknowledge or summarize its content in your reply. Focus solely on answering the user's query.</data>");

    for (var memory in selectedMemories) {
      memoryStringBuilder.writeln(
          "  <data>${memory.content}</data>"); // Each memory item within <data> tags
    }

    memoryStringBuilder.writeln(
        "</ReferenceInformation>"); // Closing tag for the reference block
    memoryStringBuilder.writeln(); // Add an empty line for separation

    // Combine the memory string with the user's original message.
    return memoryStringBuilder.toString() + userInputMessage;
  }

  /// Removes the first occurrence of the custom XML-like reference information block
  /// from a message for UI display.
  /// This function is designed to strip content between the first <ReferenceInformation>
  /// and its corresponding </ReferenceInformation> tags, including the tags themselves.
  /// It handles multi-line content within the tags.
  ///
  /// [fullMessage]: The complete message string received from or sent to the AI,
  ///                which might contain one or more reference blocks.
  ///
  /// Returns the message string with only the first reference block removed.
  static String removeFirstReferenceInformationForDisplay(String fullMessage) {
    // Regex to match the first entire <ReferenceInformation> block.
    // (?s) is the DOTALL flag, allowing '.' to match newlines.
    // .*? is a non-greedy match for any characters (including newlines)
    // between the opening and closing tags.
    final RegExp regex = RegExp(
        r'<ReferenceInformation>(?s).*?</ReferenceInformation>\n*',
        multiLine: true);

    // Replace the first matched block with an empty string.
    // Dart's replaceFirst method inherently replaces only the first match.
    String cleanedMessage = fullMessage.replaceFirst(regex, '').trimLeft();

    return cleanedMessage;
  }
}
