import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/perfume_chatbot_service.dart';

class PerfumeChatbotFab extends StatefulWidget {
  const PerfumeChatbotFab({super.key});

  @override
  State<PerfumeChatbotFab> createState() => _PerfumeChatbotFabState();
}

class _PerfumeChatbotFabState extends State<PerfumeChatbotFab>
    with SingleTickerProviderStateMixin {
  final PerfumeChatbotService _service = PerfumeChatbotService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatBubble> _messages = [
    const _ChatBubble(
      role: _ChatRole.assistant,
      text:
          'Hi, I’m ESSENCE. Ask me anything about perfumes, fragrance notes, layering, longevity, or choosing a scent.',
    ),
  ];

  bool _isOpen = false;
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isCompact = MediaQuery.sizeOf(context).width < 700;
    final viewHeight = MediaQuery.sizeOf(context).height;
    final panelWidth = isCompact ? MediaQuery.sizeOf(context).width - 24 : 380.0;
    final preferredHeight = isCompact ? 520.0 : 560.0;
    // Keep the panel within the viewport above the FAB.
    final maxPanelHeight = viewHeight - 120;
    final panelHeight =
        preferredHeight.clamp(360.0, maxPanelHeight).toDouble();

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.only(
            right: 16.w,
            bottom: 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: _isOpen
                    ? Material(
                        type: MaterialType.transparency,
                        child: Container(
                          key: const ValueKey('perfume-chat-panel'),
                          width: panelWidth,
                        height: panelHeight,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: brightness == Brightness.light
                              ? const Color(0xFFFFF9E6)
                              : const Color(0xFF111111),
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(8, 8),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(context),
                            Expanded(child: _buildMessageList(context)),
                            if (_messages.length <= 1) _buildQuickPrompts(context),
                            _buildComposer(context),
                          ],
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
              ),
              _buildFloatingButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _isOpen = !_isOpen),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD84D),
            border: Border.all(color: Colors.black, width: 3),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(5, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Icon(
            _isOpen ? Icons.close : Icons.chat_bubble_outline,
            color: Colors.black,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFFD84D),
        border: Border(bottom: BorderSide(color: Colors.black, width: 3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'ESSENCE BOT',
                  style: GoogleFonts.syne(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() => _isOpen = false),
                icon: const Icon(Icons.remove, color: Colors.black),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Perfume Assistant',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.syne(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          Text(
            'Ask only fragrance-related questions',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(14),
      itemCount: _messages.length + (_isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isSending && index == _messages.length) {
          return const _TypingBubble();
        }

        final message = _messages[index];
        final isUser = message.role == _ChatRole.user;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.black : Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: isUser ? Colors.white : Colors.black,
                  height: 1.35,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickPrompts(BuildContext context) {
    final prompts = <String>[
      'Recommend a summer perfume',
      'What notes are in oud?',
      'How do I layer scents?',
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        itemCount: prompts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            label: Text(
              prompt,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.black, width: 2),
            onPressed: _isSending
                ? null
                : () {
                    _controller.text = prompt;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: prompt.length),
                    );
                  },
          );
        },
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 3)),
        color: Color(0xFFFFF9E6),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_isSending,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Ask about perfumes...',
                hintStyle: GoogleFonts.spaceGrotesk(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSending ? null : _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    if (!_looksPerfumeRelated(text)) {
      setState(() {
        _messages.add(
          const _ChatBubble(
            role: _ChatRole.assistant,
            text:
                'I only answer perfume-related questions. Ask me about notes, longevity, layering, storage, or fragrance recommendations.',
          ),
        );
        _controller.clear();
      });
      _scrollToBottom();
      return;
    }

    setState(() {
      _messages.add(_ChatBubble(role: _ChatRole.user, text: text));
      _controller.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final history = _messages
          .take(_messages.length - 1)
          .map((message) => {
                'role': message.role == _ChatRole.user ? 'user' : 'assistant',
                'content': message.text,
              })
          .toList(growable: false);

      final reply = await _service.reply(
        userMessage: text,
        history: history,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(_ChatBubble(role: _ChatRole.assistant, text: reply));
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          _ChatBubble(
            role: _ChatRole.assistant,
            text: 'I could not load a perfume answer right now. Please try again.',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  bool _looksPerfumeRelated(String text) {
    final lower = text.toLowerCase();
    const keywords = [
      'perfume',
      'fragrance',
      'scent',
      'cologne',
      'notes',
      'oud',
      'musk',
      'amber',
      'floral',
      'woody',
      'fresh',
      'longevity',
      'projection',
      'layer',
      'spray',
      'bottle',
      'aroma',
      'smell',
    ];
    return keywords.any(lower.contains);
  }
}

enum _ChatRole { user, assistant }

class _ChatBubble {
  const _ChatBubble({required this.role, required this.text});

  final _ChatRole role;
  final String text;
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _TypingDot(),
            const SizedBox(width: 4),
            const _TypingDot(),
            const SizedBox(width: 4),
            const _TypingDot(),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot();

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = (0.4 + _controller.value * 0.6);
        return Opacity(
          opacity: value,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}