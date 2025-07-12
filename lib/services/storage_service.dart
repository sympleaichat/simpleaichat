import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/thread.dart';
import '../models/message.dart';
import '../models/folder.dart';
import '../models/memory.dart';
import '../utils/logger.dart';

class StorageService {
  static Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/history.json';
  }

  static Future<void> saveThread(
      String threadId, List<Message> messages) async {
    List<Thread> threads = await loadAllThreads();
    final folders = await loadFolders();
    final memoris = await loadMemoris();

    final index = threads.indexWhere((t) => t.threadId == threadId);
    if (index != -1) {
      threads[index] = Thread(
          threadId: threadId,
          title: threads[index].title,
          messages: messages,
          folderId: threads[index].folderId);

      await saveAllData(threads, folders, memoris);
    }
  }

  static Future<void> saveMessage(String threadId, Message message) async {
    final threads = await loadAllThreads();
    final folders = await loadFolders();
    final memoris = await loadMemoris();
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

    await saveAllData(threads, folders, memoris);
  }

  static Future<void> saveMessageData(
      String threadId, Message message, String title) async {
    final threads = await loadAllThreads();
    final folders = await loadFolders();
    final memoris = await loadMemoris();

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

    await saveAllData(threads, folders, memoris);
  }

  static Future<void> copyThread(String srcThreadId, String dstThreadId) async {
    final loadedThreads = await StorageService.loadAllThreads();
    final folders = await loadFolders();
    final memoris = await loadMemoris();

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

    await saveAllData(loadedThreads, folders, memoris);
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
    final folders = await loadFolders();
    final memoris = await loadMemoris();

    final index = threads.indexWhere((t) => t.threadId == threadId);

    if (index != -1) {
      threads[index].messages.removeWhere((m) => m.messageId == messageId);
      await saveAllData(threads, folders, memoris);
    }
  }

  static Future<void> deleteThread(String threadId) async {
    final threads = await loadAllThreads();
    final folders = await loadFolders();
    final memoris = await loadMemoris();

    threads.removeWhere((t) => t.threadId == threadId);

    await saveAllData(threads, folders, memoris);
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

  static Future<void> saveAllData(
      List<Thread> threads, List<Folder> folders, List<Memory> memoris) async {
    final path = await _getFilePath();

    await saveAllDataSub(threads, folders, memoris, path);
  }

  static Future<void> saveAllDataSub(List<Thread> threads, List<Folder> folders,
      List<Memory> memoris, String path) async {
    final file = File(path);

    final data = {
      'threads': threads.map((t) => t.toJson()).toList(),
      'folders': folders.map((f) => f.toJson()).toList(),
      'memoris': memoris.map((m) => m.toJson()).toList(),
    };

    await file.writeAsString(jsonEncode(data));
  }

  static Future<List<Thread>> loadAllThreads() async {
    final path = await _getFilePath();

    return loadAllThreadsSub(path);
  }

  static Future<List<Thread>> loadAllThreadsSub(String path) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        await file.writeAsString(
            jsonEncode({'threads': [], 'folders': [], 'memory': []}));
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
    final path = await _getFilePath();

    return loadFoldersSub(path);
  }

  static Future<List<Folder>> loadFoldersSub(String path) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        await file.writeAsString(
            jsonEncode({'threads': [], 'folders': [], 'memory': []}));
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
        Logger.log("The old format does not have folder information");
        return [];
      }
    } catch (e) {
      Logger.log(e);
      return [];
    }
  }

  static Future<List<Memory>> loadMemoris() async {
    final path = await _getFilePath();

    return loadMemorisSub(path);
  }

  static Future<List<Memory>> loadMemorisSub(String path) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        await file.writeAsString(
            jsonEncode({'threads': [], 'folders': [], 'memoris': []}));
      }

      final contents = await file.readAsString();
      final decoded = jsonDecode(contents);

      if (decoded is Map<String, dynamic>) {
        final memoris = (decoded['memoris'] as List<dynamic>? ?? [])
            .map((data) => Memory.fromJson(data))
            .toList();

        return memoris;
      } else {
        // The old format does not have folder information
        Logger.log("The old format does not have folder information");
        return [];
      }
    } catch (e) {
      Logger.log(e);
      return [];
    }
  }
}
