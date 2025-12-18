// lib/screens/ai_chat_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../data/ai_service.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

// Provider cho AIService
final aiServiceProvider = Provider((ref) => AIService());

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'time': time.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        text: j['text'] ?? '',
        isUser: j['isUser'] ?? false,
        time: DateTime.tryParse(j['time'] ?? '') ?? DateTime.now(),
      );
}

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _prefsKey = 'ai_chat_history';
  List<ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadHistory().then((_) {
      if (_messages.isEmpty) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Xin chào! Tôi có thể giúp gì cho bạn? Tôi có thể xem dữ liệu chi tiêu của bạn để hỗ trợ tốt hơn.',
            isUser: false, 
            time: DateTime.now()
          ));
        });
      }
    });
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List data = jsonDecode(raw) as List;
        _messages = data.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
        if (mounted) setState(() {});
        _scrollToBottom();
      } catch (_) {
        // ignore parse errors
      }
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString(_prefsKey, json);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    if (mounted) {
      setState(() {
        _messages = [
          ChatMessage(
            text: 'Xin chào! Tôi có thể giúp gì cho bạn? Tôi có thể xem dữ liệu chi tiêu của bạn để hỗ trợ tốt hơn.',
            isUser: false,
            time: DateTime.now()
          )
        ];
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final aiService = ref.read(aiServiceProvider);

    if (!aiService.isConfigured) {
      // Hiển thị cảnh báo rõ ràng nếu thiếu API key
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('API key thiếu'),
            content: const Text('Vui lòng cấu hình `GEMINI_API_KEY` trong file `.env` trước khi sử dụng trợ lý AI.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Đóng')),
            ],
          ),
        );
      }
      return;
    }

    setState(() {
      _isSending = true;
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
    });
    _controller.clear();
    await _saveHistory();
    _scrollToBottom();

    // 1. Kiểm tra từ khóa để lấy dữ liệu transaction nếu cần
    String contextData = "";
    final lowerText = text.toLowerCase();
    if (lowerText.contains('chi tiêu') || 
        lowerText.contains('thu nhập') || 
        lowerText.contains('giao dịch') || 
        lowerText.contains('thống kê') ||
        lowerText.contains('tiền') ||
        lowerText.contains('số dư') ||
        lowerText.contains('tổng') ||
        lowerText.contains('bao nhiêu')) {
      
      try {
        final user = ref.read(authStateChangesProvider).value;
        if (user != null) {
          // Lấy 30 giao dịch gần nhất
          final transactions = await ref.read(firestoreServiceProvider).getRecentTransactions(user.uid, limit: 30);
          
          if (transactions.isNotEmpty) {
            final sb = StringBuffer();
            sb.writeln("Dữ liệu giao dịch gần đây của người dùng (Context):");
            double totalIncome = 0;
            double totalExpense = 0;

            for (var tx in transactions) {
              final type = tx.isExpense ? "Chi tiêu" : "Thu nhập";
              final dateStr = DateFormat('dd/MM/yyyy').format(tx.date);
              final amountStr = NumberFormat('#,##0').format(tx.amount);
              sb.writeln("- $type: ${tx.title}, $amountStr đ, ngày $dateStr");
              
              if (tx.isExpense) {
                totalExpense += tx.amount;
              } else {
                totalIncome += tx.amount;
              }
            }
            sb.writeln("Tổng thu nhập (trong danh sách này): ${NumberFormat('#,##0').format(totalIncome)} đ");
            sb.writeln("Tổng chi tiêu (trong danh sách này): ${NumberFormat('#,##0').format(totalExpense)} đ");
            sb.writeln("Số dư tạm tính (trong danh sách này): ${NumberFormat('#,##0').format(totalIncome - totalExpense)} đ");
            
            contextData = sb.toString();
          } else {
            contextData = "Người dùng chưa có giao dịch nào gần đây.";
          }
        }
      } catch (e) {
        // ignore error - failed to fetch data for AI context
        // Error: $e
      }
    }

    // 2. Ghép context vào prompt
    final fullPrompt = contextData.isNotEmpty 
        ? "$contextData\n\nHãy trả lời câu hỏi sau của người dùng dựa trên dữ liệu trên nếu cần thiết:\n$text"
        : text;

    // 3. Gọi AI
    String? reply;
    try {
      reply = await aiService.askQuestion(fullPrompt);
    } catch (e) {
      reply = 'Lỗi gọi AI: $e';
    }

    if (!mounted) return;

    setState(() {
      _isSending = false;
      _messages.add(ChatMessage(text: reply ?? 'Không nhận được phản hồi từ AI.', isUser: false, time: DateTime.now()));
    });
    await _saveHistory();
    _scrollToBottom();
  }

  Widget _buildMessage(ChatMessage m) {
    final alignment = m.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = m.isUser ? Theme.of(context).colorScheme.primary : Colors.grey[300];
    final textColor = m.isUser ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(m.text, style: TextStyle(color: textColor)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ lý AI'),
        actions: [
          IconButton(
            tooltip: 'Xóa lịch sử chat',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xóa lịch sử?'),
                  content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử trò chuyện không?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
                    TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xóa')),
                  ],
                ),
              );
              if (confirmed == true) await _clearHistory();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  return Align(
                    alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: _buildMessage(m),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration.collapsed(hintText: 'Nhập câu hỏi hoặc lệnh...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSending
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
