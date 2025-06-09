import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../utils/logger.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/setting_service.dart';
import '../models/message.dart';
import '../models/thread.dart';
import '../models/folder.dart';
import '../screens/settings_screen.dart';
import '../utils/dart_highlight_code.dart';
import '../utils/constants.dart';

class ChatScreen extends StatefulWidget {
  final String? threadId;

  ChatScreen({this.threadId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Thread> _threads = [];
  List<Folder> _folders = [];
  List<Message> _messages = [];
  List<Thread> _filteredThreads = [];

  final TextEditingController _controller = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  late String _activeThreadId;

  String? _backupJson;
  String? _editingMessageId;

  List<int> _searchHits = [];
  int _currentHitIndex = 0;

  bool _isLoading = false;
  bool _sendModeThread = true;
  bool _isSidebarVisible = true;

  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollCahtController = ScrollController();

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  void initState() {
    super.initState();
    _activeThreadId = widget.threadId ?? StorageService.generateRandomId();
    _loadThreads();
    _loadMessages();
    _loadFolders();

    ApiService.pdffilePath = "";
    ApiService.pdffileName = "";
    if (!SettingService.isInit) {
      Future(() {
        SettingService.isInit = true;
        return Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messages.isNotEmpty) {
        _itemScrollController.scrollTo(
          index: _messages.length - 1,
          duration: Duration(milliseconds: 0), // 即時スクロール
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollCahtController.dispose();
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadThreads() async {
    final loadedThreads = await StorageService.loadAllThreads();
    setState(() {
      _threads = loadedThreads;
    });
  }

  Future<void> _loadFolders() async {
    final loadedFolders = await StorageService.loadFolders();
    setState(() {
      _folders = loadedFolders;
    });
  }

  Future<void> _loadMessages() async {
    final loadedMessages = await StorageService.loadThread(_activeThreadId);
    setState(() {
      _messages = loadedMessages;
    });
  }

  // Create a new thread and navigate to the chat screen
  Future<void> _createNewThread() async {
    final newThreadId = StorageService.generateRandomId();

    await StorageService.createNewThread(newThreadId);

    await _loadThreads();

    setState(() {
      _activeThreadId = newThreadId;
    });
    await _loadMessages();
  }

  // Create a new thread and navigate to the chat screen
  Future<void> _copyThread(String threadId) async {
    final newThreadId = StorageService.generateRandomId();

    await StorageService.copyThread(threadId, newThreadId);

    await _loadThreads();

    setState(() {
      _activeThreadId = newThreadId;
    });
    await _loadMessages();
  }

  Future<void> _sendMessage(String content, bool web) async {
    setState(() {});
    if (_sendModeThread) {
      await _sendThreadMessage(content, web);
    } else {
      await _sendSingleMessage(content, web);
    }
  }

  Future<void> _sendSingleMessage(String content, bool web) async {
    if (content.trim().isEmpty) return;

    final userMessage = Message(
      messageId: StorageService.generateRandomId(),
      role: 'user',
      content: content.trim(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    await StorageService.saveMessage(_activeThreadId, userMessage);
    _controller.clear();
    String assistantReply = '';
    if (web) {
      assistantReply =
          await ApiService.sendMessageWeb(content, ApiService.currentEngine);
    } else {
      assistantReply =
          await ApiService.sendMessage(content, ApiService.currentEngine);
    }

    final assistantMessage = Message(
      messageId: StorageService.generateRandomId(),
      role: 'assistant',
      content: assistantReply,
    );

    setState(() {
      _messages.add(assistantMessage);
      _isLoading = false;
    });

    await StorageService.saveMessage(_activeThreadId, assistantMessage);
    _loadThreads();
    Future(() {
      setState(() {});
    });
  }

  Future<void> _sendThreadMessage(String content, bool web) async {
    if (content.trim().isEmpty) return;

    final userMessage = Message(
      messageId: StorageService.generateRandomId(),
      role: 'user',
      content: content.trim(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _controller.clear();

    final allMessages = [..._messages];
    String assistantReply = '';
    if (web) {
      assistantReply = await ApiService.sendMessageWithHistoryWeb(
          allMessages, ApiService.currentEngine);
    } else {
      assistantReply = await ApiService.sendMessageWithHistory(
          allMessages, ApiService.currentEngine);
    }
    final isError = assistantReply.startsWith("Sorry") ||
        assistantReply.contains("Error") ||
        assistantReply.contains("communication") ||
        assistantReply.contains("failed");

    if (isError) {
      setState(() {
        _messages.remove(userMessage);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Communication failed. Please try again.')),
      );

      return;
    }

    final assistantMessage = Message(
      messageId: StorageService.generateRandomId(),
      role: 'assistant',
      content: assistantReply,
    );

    setState(() {
      _messages.add(assistantMessage);
      _isLoading = false;
    });

    await StorageService.saveMessage(_activeThreadId, userMessage);
    await StorageService.saveMessage(_activeThreadId, assistantMessage);

    _loadThreads();
  }

  void _chngSendMode(bool value) {
    setState(() {
      _sendModeThread = value;
    });
  }

  void _backupData() {
    final backup = {
      'threads': _threads.map((t) => {'threadId': t.threadId}).toList(),
      'messages': _messages
          .map((m) => {
                'messageId': m.messageId,
                'role': m.role,
                'content': m.content,
              })
          .toList(),
    };
    setState(() {
      _backupJson = jsonEncode(backup);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup created (memory only).')),
    );
  }

  void _restoreData() {
    if (_backupJson == null) return;

    final Map<String, dynamic> restored = jsonDecode(_backupJson!);

    final restoredThreads = (restored['threads'] as List)
        .map((t) => Thread(
              threadId: t['threadId'],
            ))
        .toList();
    final restoredMessages = (restored['messages'] as List)
        .map((m) => Message(
              messageId: m['messageId'],
              role: m['role'],
              content: m['content'],
            ))
        .toList();

    setState(() {
      _threads = restoredThreads;
      _messages = restoredMessages;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data restored from backup.')),
    );
  }

  void _filterThreads(String query) {
    setState(() {
      _searchQuery = query;
      _filteredThreads = _threads.where((thread) {
        bool titleMatch = thread.title.contains(query);
        bool messageMatch = thread.messages.any((message) {
          return message.content.contains(query);
        });
        return titleMatch || messageMatch;
      }).toList();
    });
  }

  void _createNewFolder() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New folder nmae'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder nmae'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final newFolder = Folder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result,
        createdAt: DateTime.now(),
      );

      setState(() {
        _folders.add(newFolder);
      });

      await StorageService.saveAllData(_threads, _folders);
    }
  }

  void _deleteFolder(Folder folder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(
            'Are you sure you want to delete the folder "${folder.name}"?\nThreads will be moved out of the folder.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _folders.removeWhere((f) => f.id == folder.id);
      for (final thread in _threads) {
        if (thread.folderId == folder.id) {
          thread.folderId = '';
        }
      }
    });

    await StorageService.saveAllData(_threads, _folders);
  }

  void _renameFolder(Folder folder) async {
    final controller = TextEditingController(text: folder.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: 'Folder Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context, text);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName == null || newName == folder.name) return;

    setState(() {
      folder.name = newName;
    });

    await StorageService.saveAllData(_threads, _folders);
  }

  void _scrollToMessage(String keyword) {
    final index = _messages.indexWhere((msg) => msg.content.contains(keyword));
    if (index == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No matching messages found')),
      );
      return;
    }

    _itemScrollController.scrollTo(
      index: index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  void _scrollToIndex(int index) {
    _itemScrollController.scrollTo(
      index: index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  void _searchMessages(String keyword) {
    final hits = <int>[];

    if (keyword == '') {
      setState(() {
        _searchHits = [];
        _currentHitIndex = 0;
      });
      return;
    }
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].content.contains(keyword)) {
        hits.add(i);
      }
    }

    if (hits.isNotEmpty) {
      setState(() {
        _searchHits = hits;
        _currentHitIndex = 0;
      });
      _scrollToIndex(hits[0]);
    } else {
      setState(() {
        _searchHits = [];
        _currentHitIndex = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No matching messages found')),
      );
    }
  }

  void _goToNextHit() {
    if (_searchHits.isEmpty) return;
    _currentHitIndex = (_currentHitIndex + 1) % _searchHits.length;
    _scrollToIndex(_searchHits[_currentHitIndex]);

    setState(() {});
  }

  void _goToPreviousHit() {
    if (_searchHits.isEmpty) return;
    _currentHitIndex =
        (_currentHitIndex - 1 + _searchHits.length) % _searchHits.length;
    _scrollToIndex(_searchHits[_currentHitIndex]);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
              _isSidebarVisible ? Icons.chevron_left : Icons.chevron_right),
          tooltip: _isSidebarVisible ? 'Hide Sidebar' : 'Show Sidebar',
          onPressed: () {
            setState(() {
              _isSidebarVisible = !_isSidebarVisible;
            });
          },
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Thread: ${_getThreadTitle()}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(child: Container()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thread Tokens: ${estimateTokens(_messages)}',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'Model: ${ApiService.getModelName(ApiService.currentEngine)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.save_alt),
              tooltip: 'Backup',
              onPressed: _backupData),
          IconButton(
              icon: Icon(Icons.folder_open),
              tooltip: 'Restore',
              onPressed: _restoreData),
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              ).then((_) => setState(() {}));
            },
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Row(
        children: [
          if (_isSidebarVisible)
            Container(
              width: 240,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xFF2a2d32)
                  : Colors.grey[200],
              child: Column(
                children: [
                  // 検索欄
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, top: 12, right: 6, bottom: 10),
                    child: TextField(
                      style: TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                      onChanged: _filterThreads,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.create_new_folder, size: 20),
                        tooltip: 'Create Folder',
                        onPressed: _createNewFolder,
                      ),
                      const Text(
                        'Create Folder',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView(
                        controller: _scrollController,
                        children: [
                          ..._folders.map((folder) {
                            final folderThreads = (_searchQuery
                                        .trim()
                                        .isNotEmpty
                                    ? _filteredThreads
                                    : _threads)
                                .where((thread) => thread.folderId == folder.id)
                                .toList();

                            return DragTarget<Thread>(
                              onAccept: (draggedThread) async {
                                setState(() {
                                  draggedThread.folderId = folder.id;
                                });
                                updateThreadFolderId(draggedThread, folder.id);
                                await StorageService.saveAllData(
                                    _threads, _folders);
                              },
                              builder: (context, candidateData, rejectedData) =>
                                  Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  leading: Icon(Icons.folder, size: 18),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          folder.name,
                                          style: TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit, size: 16),
                                        onPressed: () => _renameFolder(folder),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, size: 16),
                                        onPressed: () => _deleteFolder(folder),
                                      ),
                                    ],
                                  ),
                                  tilePadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 0),
                                  childrenPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  children: folderThreads
                                      .map(_buildDraggableThreadTile)
                                      .toList(),
                                ),
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 6),

                          // Thread outside folder
                          DragTarget<Thread>(
                            onAccept: (draggedThread) async {
                              setState(() {
                                draggedThread.folderId = null;
                              });
                              updateThreadFolderId(draggedThread, '');
                              await StorageService.saveAllData(
                                  _threads, _folders);
                            },
                            builder: (context, candidateData, rejectedData) =>
                                Container(
                              constraints: const BoxConstraints(minHeight: 160),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: candidateData.isNotEmpty
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                              child: Column(
                                children: (_searchQuery.trim().isNotEmpty
                                        ? _filteredThreads
                                        : _threads)
                                    .where((thread) =>
                                        (thread.folderId == null ||
                                            thread.folderId == ''))
                                    .map((thread) =>
                                        _buildDraggableThreadTile(thread))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1),
                  SwitchListTile(
                    title: (!_sendModeThread)
                        ? Text('Send Mode \nSingle',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ))
                        : Text('Send Mode \nThread',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            )),
                    value: _sendModeThread,
                    onChanged: _chngSendMode,
                  ),
                  Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _createNewThread();
                      },
                      icon: Icon(
                        Icons.add,
                        color: const Color.fromARGB(183, 255, 255, 255),
                      ),
                      label: Text('New Chat'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                // 検索ボックス + コントロール UI
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12, top: 12, right: 12, bottom: 12),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (query) => _searchMessages(query),
                        style: TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search messages...',
                          prefixIcon: Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ),
                        // onChanged: _filterThreads,
                      ),
                    ),
                    if (_searchHits.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              '${_currentHitIndex + 1} / ${_searchHits.length} 件'),
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: _goToPreviousHit,
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: _goToNextHit,
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 6),
// チャット表示部
                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemCount: _messages.length,
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    padding: EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg.role == 'user';
                      final isHighlighted = _searchHits.isNotEmpty &&
                          _searchHits[_currentHitIndex] == index;

                      return Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            padding: EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isHighlighted
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5)
                                  : isUser
                                      ? Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.2)
                                      : Theme.of(context)
                                          .cardColor
                                          .withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg.content,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.copy, size: 18),
                                tooltip: 'Copy',
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: msg.content));
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, size: 18),
                                tooltip: 'Delete',
                                onPressed: () async {
                                  _messages.removeAt(index);
                                  await StorageService.saveThread(
                                      _activeThreadId, _messages);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, size: 18),
                                tooltip: 'Edit',
                                onPressed: () {
                                  _editingMessageId = msg.messageId;
                                  _editController.text = msg.content;
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                            Text("Thinking..."),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (ApiService.pdffilePath != "" &&
                    ApiService.pdffilePath != null)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          ApiService.pdffileName!,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              ApiService.pdffilePath = "";
                              ApiService.pdffileName = "";
                            });
                          },
                          tooltip: 'cancel',
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 12, right: 12, bottom: 4, left: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          controller: _controller,
                          style: TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () => _sendMessage(_controller.text, false),
                        tooltip: 'Send',
                        color: Theme.of(context).primaryColor,
                      ),
                      if (ApiService.currentEngine == AIEngine.chatgpt_4o ||
                          ApiService.currentEngine == AIEngine.chatgpt_4omini ||
                          ApiService.currentEngine == AIEngine.claude40opus ||
                          ApiService.currentEngine == AIEngine.claude40sonnet ||
                          ApiService.currentEngine == AIEngine.claude35 ||
                          ApiService.currentEngine == AIEngine.claude37)
                        const SizedBox(width: 8),
                      if (ApiService.currentEngine == AIEngine.chatgpt_4o ||
                          ApiService.currentEngine == AIEngine.chatgpt_4omini ||
                          ApiService.currentEngine == AIEngine.claude40opus ||
                          ApiService.currentEngine == AIEngine.claude40sonnet ||
                          ApiService.currentEngine == AIEngine.claude35 ||
                          ApiService.currentEngine == AIEngine.claude37)
                        IconButton(
                          icon: const Icon(Icons.language),
                          onPressed: () => _sendMessage(_controller.text, true),
                          tooltip: 'Web',
                          color: Theme.of(context).primaryColor,
                        ),
                      if (ApiService.currentEngine == AIEngine.claude40opus ||
                          ApiService.currentEngine == AIEngine.claude40sonnet ||
                          ApiService.currentEngine == AIEngine.claude35 ||
                          ApiService.currentEngine == AIEngine.claude37)
                        const SizedBox(width: 8),
                      if (ApiService.currentEngine == AIEngine.claude40opus ||
                          ApiService.currentEngine == AIEngine.claude40sonnet ||
                          ApiService.currentEngine == AIEngine.claude35 ||
                          ApiService.currentEngine == AIEngine.claude37)
                        IconButton(
                          icon: const Icon(Icons.insert_drive_file_outlined),
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                            );

                            if (result != null) {
                              setState(() {
                                ApiService.pdffilePath =
                                    result.files.single.path;
                                ApiService.pdffileName =
                                    result.files.single.name;
                              });
                            } else {}
                          },
                          tooltip: 'Pdf',
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 4, right: 12, bottom: 12, left: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Opacity(
                        opacity: 0.70,
                        child: Text(appVersion,
                            style: TextStyle(
                              fontSize: 11,
                            )),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Opacity(
                        opacity: 0.70,
                        child: Text(
                            'Sent: ${ApiService.msgSendLength} characters | Received: ${ApiService.msgReceivedLength} characters | model: ${ApiService.msgModel}',
                            style: TextStyle(
                              fontSize: 11,
                            )),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Draggable thread tile generation function
  Widget _buildDraggableThreadTile(Thread thread) {
    final index = _threads.indexWhere((t) => t.threadId == thread.threadId);

    return Draggable<Thread>(
      data: thread,
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: _buildThreadTile(thread),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _buildThreadTile(thread)),
      child: _buildThreadTile(thread),
    );
  }

  Widget _buildThreadTile(Thread thread) {
    final index = _threads.indexWhere((t) => t.threadId == thread.threadId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        tileColor: thread.threadId == _activeThreadId
            ? Theme.of(context).primaryColor.withOpacity(0.15)
            : thread.isUnread
                ? Theme.of(context).primaryColor.withOpacity(0.08)
                : Colors.transparent,
        hoverColor: Theme.of(context).primaryColor.withOpacity(0.1),
        title: Text(
          thread.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: thread.threadId == _activeThreadId
                ? FontWeight.bold
                : FontWeight.w500,
            fontSize: 12,
            color: thread.threadId == _activeThreadId
                ? Theme.of(context).primaryColor
                : null,
          ),
        ),
        trailing: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          iconSize: 18,
          onSelected: (value) async {
            if (value == 'rename') {
              final newTitle = await _showRenameDialog(thread.title);
              if (newTitle != null && newTitle.trim().isNotEmpty) {
                setState(() {
                  _threads[index] = Thread(
                    threadId: thread.threadId,
                    title: newTitle.trim(),
                    messages: thread.messages,
                    folderId: thread.folderId,
                    isUnread: thread.isUnread,
                  );
                });
                await StorageService.saveAllData(_threads, _folders);
              }
            } else if (value == 'delete') {
              final confirm = await _showConfirmDeleteDialog();
              if (confirm == true) {
                setState(() {
                  _threads.removeAt(index);
                  _filteredThreads
                      .removeWhere((t) => t.threadId == thread.threadId);
                });
                await StorageService.saveAllData(_threads, _folders);
              }
            } else if (value == 'copy') {
              await _copyThread(thread.threadId);
              setState(() {});
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'rename',
              child: Text('Rename', style: TextStyle(fontSize: 13)),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(fontSize: 13)),
            ),
            PopupMenuItem(
              value: 'copy',
              child: Text('Copy', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _activeThreadId = thread.threadId;
            thread.isUnread = false;
          });
          _loadMessages();
        },
      ),
    );
  }

  void updateThreadFolderId(Thread srcThread, String folderid) {
    for (int i = 0; i < _threads.length; i++) {
      if (_threads[i].threadId == srcThread.threadId) {
        _threads[i].folderId = folderid;
        break;
      }
    }
  }

  Future<String?> _showRenameDialog(String currentTitle) async {
    final TextEditingController _renameController =
        TextEditingController(text: currentTitle);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename Thread'),
          content: TextField(
            controller: _renameController,
            decoration: InputDecoration(hintText: 'Enter new title'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () => Navigator.pop(context, _renameController.text),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmDeleteDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Thread'),
          content: Text('Are you sure you want to delete this thread?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }

  int estimateTokens(List<Message> messages) {
    final joined = messages.map((m) => m.content).join(' ');
    return (joined.length / 4).ceil(); // 1 token ≒ about 4 characters
  }

  String _getThreadTitle() {
    final current = _threads.firstWhere(
      (t) => t.threadId == _activeThreadId,
      orElse: () => Thread(threadId: _activeThreadId),
    );

    return current.title.isNotEmpty ? current.title : current.threadId;
  }
}
