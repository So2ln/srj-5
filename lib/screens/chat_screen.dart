// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srj_5/models/app_models.dart';
import 'package:srj_5/providers/user_provider.dart';
import 'package:srj_5/services/analysis_service.dart';
import 'package:srj_5/utils/app_styles.dart';

class ChatScreen extends StatefulWidget {
  final String initialMessage;
  const ChatScreen({super.key, required this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final BaseAnalysisService _analysisService = MockAnalysisService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(text: "오늘 하루는 어땠나요? 편하게 이야기해주세요.", isUserMessage: false),
    );
    if (widget.initialMessage.isNotEmpty) {
      _messages.add(
        ChatMessage(text: widget.initialMessage, isUserMessage: true),
      );
      _getBotResponse(widget.initialMessage);
    }
  }

  void _sendMessage() async {
    final messageText = _textController.text;
    if (messageText.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: messageText, isUserMessage: true));
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();
    await _getBotResponse(messageText);
  }

  Future<void> _getBotResponse(String userMessage) async {
    final userProfile = Provider.of<UserProvider>(
      context,
      listen: false,
    ).userProfile;
    if (userProfile == null) {
      setState(() {
        _messages.add(
          ChatMessage(text: "오류: 사용자 정보를 불러올 수 없습니다.", isUserMessage: false),
        );
        _isLoading = false;
      });
      return;
    }

    final botResponse = await _analysisService.getChatResponse(
      userMessage,
      userProfile,
    );

    if (botResponse != null) {
      setState(() => _messages.add(botResponse));
    } else {
      setState(
        () => _messages.add(
          ChatMessage(text: "죄송해요, 응답을 생성할 수 없어요.", isUserMessage: false),
        ),
      );
    }
    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final characterNickname =
        Provider.of<UserProvider>(context).userProfile?.nickname ?? "캐릭터";
    return Scaffold(
      appBar: AppBar(title: Text('$characterNickname님과의 대화')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildMessageBubble(_messages[index]),
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(color: AppColors.primary),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) => Align(
    alignment: message.isUserMessage
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: message.isUserMessage ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: message.isUserMessage ? Colors.white : AppColors.textColor,
        ),
      ),
    ),
  );

  Widget _buildChatInput() => Container(
    padding: const EdgeInsets.all(8.0),
    color: Theme.of(context).cardColor,
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: '메시지 보내기...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onSubmitted: (_) => _sendMessage(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send, color: AppColors.primary),
          onPressed: _isLoading ? null : _sendMessage,
        ),
      ],
    ),
  );
}
