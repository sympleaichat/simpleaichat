import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/thread.dart';
import '../models/message.dart';
import '../models/folder.dart';

class StorageService {
  static Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/history.json';
  }

  static Future<void> saveThread(
      String threadId, List<Message> messages) async {
    List<Thread> threads = await loadAllThreads();
    final folders = await loadFolders();

    final index = threads.indexWhere((t) => t.threadId == threadId);
    if (index != -1) {
      threads[index] = Thread(
        threadId: threadId,
        title: threads[index].title,
        messages: messages,
      );

      await saveAllData(threads, folders);
    }
  }

/*

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
*/
  static Future<void> saveMessage(String threadId, Message message) async {
    final threads = await loadAllThreads();
    final folders = await loadFolders();

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

    await saveAllData(threads, folders);
  }

  static Future<void> saveMessageData(
      String threadId, Message message, String title) async {
    final threads = await loadAllThreads();
    final folders = await loadFolders();

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

    await saveAllData(threads, folders);
  }

  static Future<void> copyThread(String srcThreadId, String dstThreadId) async {
    final loadedThreads = await StorageService.loadAllThreads();
    final folders = await loadFolders();
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

    await saveAllData(loadedThreads, folders);
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
    final folders = await loadFolders();
    final thread = threads.firstWhere(
      (t) => t.threadId == threadId,
      orElse: () => Thread(
          threadId: threadId, title: _generateDefaultTitle(), messages: []),
    );

    return thread.messages;
  }

  static Future<void> deleteMessage(String threadId, String messageId) async {
    final threads = await loadAllThreads();
    final folders = await loadFolders();
    final index = threads.indexWhere((t) => t.threadId == threadId);

    if (index != -1) {
      threads[index].messages.removeWhere((m) => m.messageId == messageId);
      await saveAllData(threads, folders);
    }
  }

  static Future<void> deleteThread(String threadId) async {
    final threads = await loadAllThreads();
    final folders = await loadFolders();
    threads.removeWhere((t) => t.threadId == threadId);
    await saveAllData(threads, folders);
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

  static Future<String> _getFolderPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/folders.json';
  }

  static Future<void> saveAllData(
      List<Thread> threads, List<Folder> folders) async {
    final path = await _getFilePath();
    final file = File(path);

    final data = {
      'threads': threads.map((t) => t.toJson()).toList(),
      'folders': folders.map((f) => f.toJson()).toList(),
    };

    await file.writeAsString(jsonEncode(data));
  }

  static Future<List<Thread>> loadAllThreads() async {
    try {
      final path = await _getFilePath();
      final file = File(path);

      if (!await file.exists()) {
        await file.writeAsString(jsonEncode({'threads': [], 'folders': []}));
      }

      final contents = await file.readAsString();
      final decoded = jsonDecode(contents);

      if (decoded is List) {
        // Old style (list of threads only)
        // print(decoded.map<Thread>((data) => Thread.fromJson(data)).toList());
        return decoded.map<Thread>((data) => Thread.fromJson(data)).toList();
      } else if (decoded is Map<String, dynamic>) {
        final threads = (decoded['threads'] as List<dynamic>? ?? [])
            .map((data) => Thread.fromJson(data))
            .toList();

        return threads;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<Folder>> loadFolders() async {
    try {
      final path = await _getFilePath();
      final file = File(path);

      if (!await file.exists()) {
        await file.writeAsString(jsonEncode({'threads': [], 'folders': []}));
      }

      final contents = await file.readAsString();
      final decoded = jsonDecode(contents);

      if (decoded is Map<String, dynamic>) {
        final folders = (decoded['folders'] as List<dynamic>? ?? [])
            .map((data) => Folder.fromJson(data))
            .toList();

        return folders;
      } else {
        // The old format does not have folder information
        return [];
      }
    } catch (e) {
      return [];
    }
  }

/*
  static Future<void> saveFolders(List<Folder> folders) async {
    final path = await _getFolderPath();
    final file = File(path);
    final jsonData = folders.map((folder) => folder.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonData));
  }

  static Future<List<Folder>> loadFolders() async {
    final path = await _getFolderPath();
    final file = File(path);

    if (!await file.exists()) {
      await file.writeAsString('[]');
    }

    final contents = await file.readAsString();
    final List<dynamic> jsonData = jsonDecode(contents);
    return jsonData.map((data) => Folder.fromJson(data)).toList();
  }


  static Future<void> saveThreads(List<Thread> threads) async {
    final path = await _getFilePath();
    final file = File(path);
    final jsonData = threads.map((thread) => thread.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonData));
  }
  */
}
