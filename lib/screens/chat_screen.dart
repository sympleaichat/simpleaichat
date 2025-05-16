import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/setting_service.dart';
import '../models/message.dart';
import '../models/thread.dart';
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
  List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();

  late String _activeThreadId;

  String? _backupJson;

  String? _editingMessageId;
  final TextEditingController _editController = TextEditingController();
  bool _isLoading = false;
  bool _sendModeThread = true;
  bool _isSidebarVisible = true;
  @override
  void initState() {
    super.initState();
    _activeThreadId = widget.threadId ?? StorageService.generateRandomId();
    _loadThreads();
    _loadMessages();

    if (!SettingService.isInit) {
      Future(() {
        SettingService.isInit = true;
        return Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
      });
    }
  }

  Future<void> _loadThreads() async {
    final loadedThreads = await StorageService.loadAllThreads();
    setState(() {
      _threads = loadedThreads;
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
      assistantReply = await ApiService.sendMessageWeb(content);
    } else {
      assistantReply = await ApiService.sendMessage(content);
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
      assistantReply = await ApiService.sendMessageWithHistoryWeb(allMessages);
    } else {
      assistantReply = await ApiService.sendMessageWithHistory(allMessages);
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
              width: 220,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xFF2a2d32)
                  : Colors.grey[200],
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _threads.length,
                      itemBuilder: (context, index) {
                        final thread = _threads[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              tileColor: thread.threadId == _activeThreadId
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2)
                                  : thread.isUnread
                                      ? Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1)
                                      : Colors.transparent,
                              hoverColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              title: Text(
                                thread.title,
                                style: TextStyle(
                                  fontWeight: thread.threadId == _activeThreadId
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 14,
                                  color: thread.threadId == _activeThreadId
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'rename') {
                                    final newTitle =
                                        await _showRenameDialog(thread.title);
                                    if (newTitle != null &&
                                        newTitle.trim().isNotEmpty) {
                                      setState(() {
                                        _threads[index] = Thread(
                                          threadId: thread.threadId,
                                          title: newTitle.trim(),
                                          messages: thread.messages,
                                        );
                                      });
                                      await StorageService.saveAllThreads(
                                          _threads);
                                      //  ScaffoldMessenger.of(context)
                                      //      .showSnackBar(
                                      //  SnackBar(
                                      //       content: Text('Thread renamed')),
                                      // );
                                    }
                                  } else if (value == 'delete') {
                                    final confirm =
                                        await _showConfirmDeleteDialog();
                                    if (confirm == true) {
                                      setState(() {
                                        _threads.removeAt(index);
                                      });
                                      await StorageService.saveAllThreads(
                                          _threads);
                                      //   ScaffoldMessenger.of(context).showSnackBar(
                                      //    SnackBar(content: Text('Thread deleted')),
                                      //  );
                                    }
                                  } else if (value == 'copy') {
                                    await _copyThread(thread.threadId);
                                    setState(() {});
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                      value: 'rename', child: Text('Rename')),
                                  PopupMenuItem(
                                      value: 'delete', child: Text('Delete')),
                                  PopupMenuItem(
                                      value: 'copy', child: Text('copy')),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _activeThreadId = thread.threadId;
                                });
                                _loadMessages();
                              }),
                        );
                      },
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
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    reverse: false,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg.role == 'user';

                      return Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          _editingMessageId == msg.messageId
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _editController
                                          ..text = msg.content,
                                        autofocus: true,
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        decoration: InputDecoration(
                                          fillColor: Theme.of(context)
                                              .cardColor
                                              .withOpacity(0.12),
                                          filled: true,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.check),
                                      onPressed: () async {
                                        setState(() {
                                          _editingMessageId = '';
                                          _messages[index] = Message(
                                            messageId: msg.messageId,
                                            role: msg.role,
                                            content: _editController.text,
                                          );
                                        });
                                        await StorageService.saveThread(
                                            _activeThreadId, _messages);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text('Message updated')),
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : Container(
                                  margin: EdgeInsets.symmetric(vertical: 6),
                                  padding: EdgeInsets.all(12),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.75,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.2)
                                        : Theme.of(context)
                                            .cardColor
                                            .withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(12),
                                  ),

                                  /*
                                  child: SelectableText(
                                    msg.content,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  */
                                  child: DartHighlightedCode(
                                    code: msg.content,
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Copied to clipboard')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, size: 18),
                                tooltip: 'Delete',
                                onPressed: () async {
                                  setState(() {
                                    _messages.removeAt(index);
                                  });
                                  await StorageService.saveThread(
                                      _activeThreadId, _messages);
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(content: Text('Message deleted')),
                                  // );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, size: 18),
                                tooltip: 'Edit',
                                onPressed: () {
                                  setState(() {
                                    _editingMessageId = msg.messageId;
                                    _editController.text = msg.content;
                                  });
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
                          ApiService.currentEngine == AIEngine.claude35 ||
                          ApiService.currentEngine == AIEngine.claude37)
                        const SizedBox(width: 8),
                      if (ApiService.currentEngine == AIEngine.chatgpt_4o ||
                          ApiService.currentEngine == AIEngine.claude35 ||
                          ApiService.currentEngine == AIEngine.claude37)
                        IconButton(
                          icon: Icon(Icons.language),
                          onPressed: () => _sendMessage(_controller.text, true),
                          tooltip: 'Web',
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
