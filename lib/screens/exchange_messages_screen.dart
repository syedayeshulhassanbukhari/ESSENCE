import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/exchange_chat_thread.dart';
import '../models/exchange_listing.dart';
import '../models/user_profile.dart';
import '../providers/exchange_chat_provider.dart';
import '../providers/responsive_provider.dart';
import '../providers/theme_provider.dart';
import '../services/exchange_chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/layout_widgets.dart';

class ExchangeMessagesScreen extends StatefulWidget {
  const ExchangeMessagesScreen({super.key, this.initialListing});
  final ExchangeListing? initialListing;

  @override
  State<ExchangeMessagesScreen> createState() => _ExchangeMessagesScreenState();
}

class _ExchangeMessagesScreenState extends State<ExchangeMessagesScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _msgScroll = ScrollController();
  String? _selectedThreadId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleInitialListing());
  }

  @override
  void didUpdateWidget(covariant ExchangeMessagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialListing?.id != oldWidget.initialListing?.id) {
      _handleInitialListing();
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _msgScroll.dispose();
    super.dispose();
  }

  Future<void> _handleInitialListing() async {
    final listing = widget.initialListing ??
        ModalRoute.of(context)?.settings.arguments as ExchangeListing?;
    if (listing == null) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("[EXCHANGE_MESSAGES] Error: No logged-in user.");
      return;
    }

    final chatService = context.read<ExchangeChatService>();
    final generatedChatId = chatService.generateChatId(listingId: listing.id, userA: user.uid, userB: listing.ownerId);

    debugPrint("Current userId: ${user.uid}");
    debugPrint("Seller userId from listing: ${listing.ownerId}");
    debugPrint("Generated chatId: $generatedChatId");
    debugPrint("Active chatId BEFORE navigation: ${context.read<ExchangeChatProvider>().activeChatId ?? 'none'}");

    final provider = context.read<ExchangeChatProvider>();
    final isSeller = user.uid == listing.ownerId;
    
    if (isSeller) {
      debugPrint("[EXCHANGE_MESSAGES] User is Seller. Loading all buyer threads.");
      await provider.ensureSellerThreads(listingId: listing.id, sellerId: user.uid);
    } else {
      debugPrint("[EXCHANGE_MESSAGES] User is Buyer. Opening chat with seller.");
      await provider.ensureBuyerThread(
        listingId: listing.id,
        buyerId: user.uid,
        sellerId: listing.ownerId,
      );
    }

    if (!mounted) return;

    final activeThread = provider.activeThread;
    if (activeThread != null && _selectedThreadId != activeThread.id) {
      setState(() => _selectedThreadId = activeThread.id);
      debugPrint("Active chatId AFTER navigation: ${activeThread.id}");
    }
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_msgScroll.hasClients) {
        _msgScroll.animateTo(
          _msgScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _selectThread(ExchangeChatThread thread, String viewerId) async {
    setState(() => _selectedThreadId = thread.id);
    debugPrint("Active chatId BEFORE navigation: ${context.read<ExchangeChatProvider>().activeChatId ?? 'none'}");
    debugPrint("Active chatId AFTER navigation: ${thread.id}");
    await context.read<ExchangeChatProvider>().openExistingThread(thread: thread, viewerId: viewerId);
    SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _send(String senderId) async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<ExchangeChatProvider>();
    // Guard: activeThread must exist to send
    if (provider.activeThread == null) {
      provider.setError('No chat selected. Please select a conversation first.');
      return;
    }

    final sent = await provider.sendMessage(senderId: senderId, body: text);
    if (sent && mounted) {
      _inputCtrl.clear();
      // Scroll to show the new message
      SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final provider = context.watch<ExchangeChatProvider>();
    final service = context.watch<ExchangeChatService>();

    return MultiProvider(
      providers: [
        Provider.value(value: service),
        ChangeNotifierProvider.value(value: provider),
      ],
      child: Builder(
        builder: (context) {
          final colors = context.watch<ThemeProvider>().colors;
          final brightness = Theme.of(context).brightness;
          final isSmall = context.watch<ResponsiveProvider>().isSmall;
          final bg = brightness == Brightness.light
              ? colors.backgroundLight
              : colors.backgroundDark;

          return Scaffold(
            backgroundColor: bg,
            body: Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: user == null
                      ? _buildEmpty(context, 'Sign in to view your messages.')
                      : isSmall
                          ? _buildMobile(context, user)
                          : _buildDesktop(context, user),
                ),
                const AppFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Desktop: fixed-height side-by-side panels ──────────────────────────────
  Widget _buildDesktop(BuildContext context, User user) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    final borderColor = brightness == Brightness.light ? colors.black : colors.primaryYellow;

    return Padding(
      padding: EdgeInsets.all(AppTheme.spacing6.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thread list panel ──
          SizedBox(
            width: 340.w,
            child: _buildThreadPanel(context, user, borderColor, colors),
          ),
          SizedBox(width: AppTheme.spacing4.w),
          // ── Chat panel ──
          Expanded(
            child: _buildChatPanel(context, user, borderColor, colors),
          ),
        ],
      ),
    );
  }

  // ── Mobile: stacked with bottom sheet-style thread list ────────────────────
  Widget _buildMobile(BuildContext context, User user) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    final borderColor = brightness == Brightness.light ? colors.black : colors.primaryYellow;
    final provider = context.watch<ExchangeChatProvider>();
    final hasActive = provider.activeThread != null;

    return Column(
      children: [
        if (!hasActive) ...[
          Expanded(child: _buildThreadPanel(context, user, borderColor, colors)),
        ] else ...[
          // Back button strip
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor, width: 2)),
            ),
            child: ListTile(
              leading: Icon(Icons.arrow_back, color: colors.black),
              title: Text(
                'Back to chats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              onTap: () {
                context.read<ExchangeChatProvider>().clearActiveThread();
                setState(() => _selectedThreadId = null);
              },
            ),
          ),
          Expanded(child: _buildChatPanel(context, user, borderColor, colors)),
        ],
      ],
    );
  }

  // ── Thread list ────────────────────────────────────────────────────────────
  Widget _buildThreadPanel(
      BuildContext context, User user, Color borderColor, ThemeColors colors) {
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: AppTheme.borderWidth),
        boxShadow: [AppTheme.neoShadow(colors, brightness)],
        color: brightness == Brightness.light ? colors.white : colors.zinc900,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4.w, vertical: AppTheme.spacing4.h),
            decoration: BoxDecoration(
              color: colors.primaryYellow,
              border: Border(bottom: BorderSide(color: borderColor, width: 2)),
            ),
            child: Text(
              'MESSAGES',
              style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900, color: colors.black),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ExchangeChatThread>>(
              stream: context.read<ExchangeChatService>().streamThreadsForUser(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    (snapshot.data?.isEmpty ?? true)) {
                  return const Center(child: CircularProgressIndicator());
                }
                final threads = snapshot.data ?? [];
                if (threads.isEmpty) {
                  return _buildEmpty(context, 'No conversations yet.\nOpen a listing to start one.');
                }
                // Auto-select first thread ONLY if no listing was requested
                if (_selectedThreadId == null && threads.isNotEmpty && widget.initialListing == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _selectedThreadId == null) {
                      debugPrint("[EXCHANGE_MESSAGES] Auto-selecting first available thread.");
                      _selectThread(threads.first, user.uid);
                    }
                  });
                }
                return ListView.builder(
                  itemCount: threads.length,
                  itemBuilder: (context, i) =>
                      _buildThreadTile(context, threads[i], user, borderColor, colors),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadTile(BuildContext context, ExchangeChatThread thread,
      User user, Color borderColor, ThemeColors colors) {
    final isActive = _selectedThreadId == thread.id;
    final brightness = Theme.of(context).brightness;
    final textTheme = Theme.of(context).textTheme;
    final counterpartId =
        thread.sellerId == user.uid ? thread.buyerId : thread.sellerId;
    final unread = thread.unreadCountForUser(user.uid);
    final isMe = thread.lastSenderId == user.uid;
    final time = _formatTime(thread.lastMessageAt ?? thread.updatedAt ?? thread.createdAt);

    return GestureDetector(
      onTap: () => _selectThread(thread, user.uid),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isActive
              ? colors.primaryYellow.withValues(alpha: 0.18)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
                color: borderColor.withValues(alpha: 0.25), width: 1),
            left: isActive
                ? BorderSide(color: colors.primaryYellow, width: 4)
                : BorderSide.none,
          ),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4.w, vertical: AppTheme.spacing4.h),
        child: Row(
          children: [
            // Avatar circle
            _ChatAvatar(uid: counterpartId, colors: colors, brightness: brightness),
            SizedBox(width: AppTheme.spacing2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<UserProfile?>(
                          future: _loadProfile(counterpartId),
                          builder: (context, snap) => Text(
                            snap.data?.displayName.isNotEmpty == true
                                ? snap.data!.displayName
                                : 'User ${_shortId(counterpartId)}',
                            style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(time,
                          style: textTheme.bodySmall
                              ?.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      if (isMe)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.done_all,
                              size: 14,
                              color: colors.accentCyan),
                        ),
                      Expanded(
                        child: Text(
                          thread.lastMessage.isNotEmpty
                              ? thread.lastMessage
                              : 'No messages yet.',
                          style: textTheme.bodySmall?.copyWith(
                              fontWeight: unread > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primaryYellow,
                            border: Border.all(
                                color: colors.black, width: 1.5),
                          ),
                          child: Text(
                            '$unread',
                            style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.black,
                                fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chat panel ─────────────────────────────────────────────────────────────
  Widget _buildChatPanel(
      BuildContext context, User user, Color borderColor, ThemeColors colors) {
    final provider = context.watch<ExchangeChatProvider>();
    final brightness = Theme.of(context).brightness;
    final initialListing = widget.initialListing;
    final fallbackCounterpartId = initialListing?.ownerId ?? '';
    final isLaunchedFromListing = initialListing != null;

    if (provider.activeThread == null && !provider.isLoading) {
      if (isLaunchedFromListing) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: AppTheme.borderWidth),
            boxShadow: [AppTheme.neoShadow(colors, brightness)],
            color: brightness == Brightness.light ? colors.white : colors.zinc900,
          ),
          child: Column(
            children: [
              _buildChatHeader(
                context,
                fallbackCounterpartId,
                null,
                user,
                borderColor,
                colors,
              ),
              Expanded(
                child: provider.errorMessage.isNotEmpty
                    ? _buildEmpty(context, provider.errorMessage)
                    : _buildEmpty(context, 'Opening your chat...'),
              ),
              if (provider.errorMessage.isNotEmpty)
                Container(
                  color: colors.accentPink.withValues(alpha: 0.12),
                  padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4.w, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: colors.accentPink),
                      SizedBox(width: AppTheme.spacing2.w),
                      Expanded(
                        child: Text(provider.errorMessage,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.accentPink,
                                fontWeight: FontWeight.w700)),
                      ),
                      GestureDetector(
                        onTap: provider.clearError,
                        child: Icon(Icons.close, size: 16, color: colors.accentPink),
                      ),
                    ],
                  ),
                ),
              _buildInputRow(
                context,
                user.uid,
                borderColor,
                colors,
                brightness,
                enabled: false,
                hintText: 'Chat is opening...',
              ),
            ],
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: AppTheme.borderWidth),
          color: brightness == Brightness.light ? colors.white : colors.zinc900,
        ),
        child: _buildEmpty(context, 'Select a conversation\nto start messaging.'),
      );
    }

    final thread = provider.activeThread;
    final counterpartId = thread != null
        ? (thread.sellerId == user.uid ? thread.buyerId : thread.sellerId)
      : (widget.initialListing?.ownerId ?? '');

    // Auto-scroll when messages update
    if (provider.messages.isNotEmpty) _scrollToBottom();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: AppTheme.borderWidth),
        boxShadow: [AppTheme.neoShadow(colors, brightness)],
        color: brightness == Brightness.light ? colors.white : colors.zinc900,
      ),
      child: Column(
        children: [
          // ── Chat header ──
          _buildChatHeader(context, counterpartId, thread, user, borderColor, colors),
          // ── Messages ──
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.messages.isEmpty
                    ? _buildEmpty(context, 'No messages yet.\nSay hello! 👋')
                    : ListView.builder(
                        controller: _msgScroll,
                        padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing4.w,
                            vertical: AppTheme.spacing4.h),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, i) {
                          final msg = provider.messages[i];
                          final isMine = msg.senderId == user.uid;
                          return _buildBubble(context, msg.body, isMine,
                              msg.createdAt, colors, brightness);
                        },
                      ),
          ),
          // ── Error ──
          if (provider.errorMessage.isNotEmpty)
            Container(
              color: colors.accentPink.withValues(alpha: 0.12),
              padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing4.w, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: colors.accentPink),
                  SizedBox(width: AppTheme.spacing2.w),
                  Expanded(
                    child: Text(provider.errorMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.accentPink,
                            fontWeight: FontWeight.w700)),
                  ),
                  GestureDetector(
                    onTap: provider.clearError,
                    child: Icon(Icons.close, size: 16, color: colors.accentPink),
                  ),
                ],
              ),
            ),
          // ── Input row ──
          _buildInputRow(context, user.uid, borderColor, colors, brightness),
        ],
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context, String counterpartId,
      ExchangeChatThread? thread, User user, Color borderColor, ThemeColors colors) {
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;
    final unread = thread?.unreadCountForUser(user.uid) ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4.w, vertical: AppTheme.spacing2.h),
      decoration: BoxDecoration(
        color: colors.primaryYellow,
        border: Border(bottom: BorderSide(color: borderColor, width: 2)),
      ),
      child: Row(
        children: [
          _ChatAvatar(uid: counterpartId, colors: colors, brightness: brightness, size: 38),
          SizedBox(width: AppTheme.spacing2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<UserProfile?>(
                  future: _loadProfile(counterpartId),
                  builder: (context, snap) => Text(
                    snap.data?.displayName.isNotEmpty == true
                        ? snap.data!.displayName
                        : counterpartId.isEmpty
                            ? 'Select a chat'
                            : 'User ${_shortId(counterpartId)}',
                    style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900, color: colors.black),
                  ),
                ),
                if (thread != null)
                  Text(
                    'Listing: ${thread.listingId.length > 12 ? thread.listingId.substring(0, 12) : thread.listingId}',
                    style: textTheme.bodySmall?.copyWith(
                        color: colors.black.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.black,
                border: Border.all(color: colors.black, width: 1.5),
              ),
              child: Text('$unread new',
                  style: textTheme.bodySmall?.copyWith(
                      color: colors.primaryYellow, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context, String body, bool isMine,
      DateTime? time, ThemeColors colors, Brightness brightness) {
    final textTheme = Theme.of(context).textTheme;
    final bubbleColor = isMine
        ? colors.primaryYellow
        : (brightness == Brightness.light ? const Color(0xFFF4F4F5) : colors.zinc800);
    final textColor = isMine
        ? colors.black
        : (brightness == Brightness.light ? colors.black : colors.white);
    final borderColor = brightness == Brightness.light ? colors.black : colors.primaryYellow;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480.w),
        child: Container(
          margin: EdgeInsets.only(bottom: AppTheme.spacing2.h),
          padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing4.w, vertical: AppTheme.spacing2.h),
          decoration: BoxDecoration(
            color: bubbleColor,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [AppTheme.neoShadow(colors, brightness, offset: AppTheme.shadowSmall)],
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(body,
                  style: textTheme.bodyMedium?.copyWith(
                      color: textColor, fontWeight: FontWeight.w600)),
              if (time != null) ...[
                SizedBox(height: 2.h),
                Text(
                  _formatTime(time),
                  style: textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: textColor.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow(BuildContext context, String senderId,
      Color borderColor, ThemeColors colors, Brightness brightness,
      {bool enabled = true, String hintText = 'Type a message...'}) {
    final provider = context.watch<ExchangeChatProvider>();
    final textTheme = Theme.of(context).textTheme;
    final inputBg = brightness == Brightness.light ? const Color(0xFFF9F9F9) : colors.zinc800;
    final canSend = enabled && !provider.isSending && provider.activeThread != null && _inputCtrl.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4.w, vertical: AppTheme.spacing2.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor, width: 2)),
        color: brightness == Brightness.light ? colors.white : colors.zinc900,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: inputBg,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: TextField(
                controller: _inputCtrl,
                minLines: 1,
                maxLines: 4,
                readOnly: !enabled,
                onChanged: (_) {
                  if (mounted) {
                    setState(() {});
                  }
                  if (provider.errorMessage.isNotEmpty) provider.clearError();
                },
                onSubmitted: (_) => _send(senderId),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: textTheme.bodyMedium
                      ?.copyWith(color: colors.gray400, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4.w,
                      vertical: AppTheme.spacing2.h),
                ),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacing2.w),
          GestureDetector(
            onTap: canSend ? () => _send(senderId) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: canSend ? colors.primaryYellow : colors.gray400,
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [AppTheme.neoShadow(colors, brightness, offset: AppTheme.shadowSmall)],
              ),
              child: Center(
                child: provider.isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: colors.black))
                    : Icon(Icons.send_rounded, color: colors.black, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing6.w),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _shortId(String v) =>
      v.isEmpty ? '???' : v.substring(0, v.length.clamp(0, 6)).toUpperCase();

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final local = dt.toLocal();
    if (now.difference(local).inDays == 0) {
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    return '${local.month}/${local.day}';
  }

  Future<UserProfile?> _loadProfile(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!snap.exists) return null;
      return UserProfile.fromSnapshot(snap);
    } catch (_) {
      return null;
    }
  }
}

// ── Reusable chat avatar ────────────────────────────────────────────────────
class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({
    required this.uid,
    required this.colors,
    required this.brightness,
    this.size = 44,
  });

  final String uid;
  final ThemeColors colors;
  final Brightness brightness;
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        brightness == Brightness.light ? colors.black : colors.primaryYellow;
    final initials = uid.isNotEmpty ? uid[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primaryYellow,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: Text(initials,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: size * 0.38,
                color: colors.black)),
      ),
    );
  }
}
