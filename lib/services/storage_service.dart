import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/thread.dart';
import '../models/message.dart';

class StorageService {
  static Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/history.json';
  }

  static Future<void> saveThread(
      String threadId, List<Message> messages) async {
    List<Thread> threads = await loadAllThreads();

    final index = threads.indexWhere((t) => t.threadId == threadId);
    if (index != -1) {
      threads[index] = Thread(
        threadId: threadId,
        title: threads[index].title,
        messages: messages,
      );

      await saveAllThreads(threads);
    }
  }

  static Future<List<Thread>> loadAllThreads() async {
    try {
      final path = await _getFilePath();
      final file = File(path);

      if (!await file.exists()) {
        await file.writeAsString('[]');
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);

      return jsonData.map((data) => Thread.fromJson(data)).toList();
    } catch (e) {
      final path = await _getFilePath();
      final file = File(path);
      await file.writeAsString('[]');
      return [];
    }
  }

  static Future<void> saveAllThreads(List<Thread> threads) async {
    final path = await _getFilePath();
    final file = File(path);

    final jsonData = threads.map((thread) => thread.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonData));
  }

  static Future<void> saveMessage(String threadId, Message message) async {
    final threads = await loadAllThreads();

    final index = threads.indexWhere((t) => t.threadId == threadId);

    if (index != -1) {
      threads[index].messages.add(message);
      threads[index].isUnread = true;
    } else {
      final newThread = Thread(
        threadId: threadId,
        title: _generateDefaultTitle(),
        messages: [message],
      );
      threads.insert(0, newThread);
    }

    await saveAllThreads(threads);
  }

  static Future<void> saveMessageData(
      String threadId, Message message, String title) async {
    final threads = await loadAllThreads();

    final index = threads.indexWhere((t) => t.threadId == threadId);

    final settitle = (title != null && title.trim().isNotEmpty)
        ? title
        : _generateDefaultTitle();
    if (index != -1) {
      threads[index].messages.add(message);
      threads[index].isUnread = true;
    } else {
      final newThread = Thread(
        threadId: threadId,
        title: settitle,
        messages: [message],
      );
      threads.insert(0, newThread);
    }

    await saveAllThreads(threads);
  }

  static Future<void> copyThread(String srcThreadId, String dstThreadId) async {
    final loadedThreads = await StorageService.loadAllThreads();

    final srcThreadIndex =
        loadedThreads.indexWhere((t) => t.threadId == srcThreadId);

    if (srcThreadIndex == -1) {
      //throw Exception('Source thread not found: $srcThreadId');
      await createNewThreadData(srcThreadId, _generateDefaultTitle());
      return;
    }

    final dstThreadExists = loadedThreads.any((t) => t.threadId == dstThreadId);
    if (dstThreadExists) {
      //throw Exception('Destination thread already exists: $dstThreadId');
      await createNewThreadData(srcThreadId, _generateDefaultTitle());
      return;
    }

    final srcThread = loadedThreads[srcThreadIndex];

    final newThread = Thread(
      threadId: dstThreadId,
      title: 'copy ' + srcThread.title,
      messages:
          srcThread.messages.map((m) => Message.fromJson(m.toJson())).toList(),
      isUnread: true,
    );

    loadedThreads.insert(0, newThread);

    await saveAllThreads(loadedThreads);
  }

  static Future<void> createNewThread(String threadId) async {
    await createNewThreadData(threadId, _generateDefaultTitle());
  }

  static Future<void> createNewThreadData(String threadId, String title) async {
    await StorageService.saveMessageData(
        threadId,
        Message(
          messageId: generateRandomId(),
          role: 'user',
          content: 'New conversation started.',
        ),
        title);
  }

  static Future<List<Message>> loadThread(String threadId) async {
    final threads = await loadAllThreads();
    final thread = threads.firstWhere(
      (t) => t.threadId == threadId,
      orElse: () => Thread(
          threadId: threadId, title: _generateDefaultTitle(), messages: []),
    );

    return thread.messages;
  }

  static Future<void> deleteMessage(String threadId, String messageId) async {
    final threads = await loadAllThreads();
    final index = threads.indexWhere((t) => t.threadId == threadId);

    if (index != -1) {
      threads[index].messages.removeWhere((m) => m.messageId == messageId);
      await saveAllThreads(threads);
    }
  }

  static Future<void> deleteThread(String threadId) async {
    final threads = await loadAllThreads();
    threads.removeWhere((t) => t.threadId == threadId);
    await saveAllThreads(threads);
  }

  static String _generateDefaultTitle() {
    final now = DateTime.now();
    return '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}';
  }

  static String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  static Future<String> getHistoryFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/history.json';
  }

  static String generateRandomId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(8, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}
