import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/exchange_listing.dart';
import '../models/user_profile.dart';
import '../providers/exchange_chat_provider.dart';
import '../providers/responsive_provider.dart';
import '../providers/theme_provider.dart';
import '../services/exchange_chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/neo_widgets.dart';

class ExchangeChatScreen extends StatefulWidget {
  const ExchangeChatScreen({super.key, this.listing});

  final ExchangeListing? listing;

  @override
  State<ExchangeChatScreen> createState() => _ExchangeChatScreenState();
}

class _ExchangeChatScreenState extends State<ExchangeChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  // Track whether we have started the thread load so we don't double-fire.
  bool _threadLoadStarted = false;

  @override
  void initState() {
    super.initState();
    // Kick off the thread load after the first frame so we have a listing.
    WidgetsBinding.instance.addPostFrameCallback((_) => _kickOffThreadLoad());
  }

  void _kickOffThreadLoad() {
    if (_threadLoadStarted || !mounted) return;
    final listing = widget.listing ??
        ModalRoute.of(context)?.settings.arguments as ExchangeListing?;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (listing == null || currentUser == null || listing.ownerId.isEmpty) return;

    _threadLoadStarted = true;
    final chatService = context.read<ExchangeChatService>();
    final chatProvider = context.read<ExchangeChatProvider>();
    
    final generatedChatId = chatService.generateChatId(
      listingId: listing.id,
      userA: currentUser.uid, 
      userB: listing.ownerId,
    );
    debugPrint('Current userId: ${currentUser.uid}');
    debugPrint('Seller userId from listing: ${listing.ownerId}');
    debugPrint('Generated chatId: $generatedChatId');
    debugPrint('Active chatId BEFORE navigation: ${chatProvider.activeChatId ?? 'none'}');
 
    final isSeller = currentUser.uid == listing.ownerId;
    if (isSeller) {
      chatProvider.ensureSellerThreads(
        listingId: listing.id,
        sellerId: currentUser.uid,
      );
    } else {
      chatProvider.ensureBuyerThread(
        listingId: listing.id,
        buyerId: currentUser.uid,
        sellerId: listing.ownerId,
      );
    }

    debugPrint('Active chatId AFTER navigation: $generatedChatId');
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing ??
        ModalRoute.of(context)?.settings.arguments as ExchangeListing?;

    if (listing == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No exchange listing selected.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }

    return Builder(
        builder: (context) {
          final colors = context.watch<ThemeProvider>().colors;
          final brightness = Theme.of(context).brightness;
          final responsive = context.watch<ResponsiveProvider>();
          final isSmall = responsive.isSmall;
          final currentUser = FirebaseAuth.instance.currentUser;
          final isSeller = currentUser != null && listing.ownerId.isNotEmpty && currentUser.uid == listing.ownerId;

          return Scaffold(
            backgroundColor: brightness == Brightness.light
                ? colors.backgroundLight
                : colors.backgroundDark,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppHeader(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing6.w,
                      vertical: AppTheme.spacing6.h,
                    ),
                    child: _buildChatLayout(
                      context,
                      listing: listing,
                      currentUser: currentUser,
                      isSeller: isSeller,
                      isSmall: isSmall,
                    ),
                  ),
                  const AppFooter(),
                ],
              ),
            ),
          );
        },
      );
  }

  Widget _buildChatLayout(
    BuildContext context, {
    required ExchangeListing listing,
    required User? currentUser,
    required bool isSeller,
    required bool isSmall,
  }) {
    if (currentUser == null) {
      return _buildStatusCard(context, 'Sign in to open exchange chats.');
    }

    if (listing.ownerId.isEmpty) {
      return _buildStatusCard(context, 'Chat is unavailable because the seller is not linked yet.');
    }

    final provider = context.watch<ExchangeChatProvider>();

    if (isSmall) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSidebar(context, listing: listing, isSeller: isSeller),
          SizedBox(height: AppTheme.spacing4.h),
          _buildConversation(context, listing: listing, provider: provider, currentUser: currentUser),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 380.w,
          child: _buildSidebar(context, listing: listing, isSeller: isSeller),
        ),
        SizedBox(width: AppTheme.spacing6.w),
        Expanded(
          child: _buildConversation(context, listing: listing, provider: provider, currentUser: currentUser),
        ),
      ],
    );
  }

  Widget _buildSidebar(
    BuildContext context, {
    required ExchangeListing listing,
    required bool isSeller,
  }) {
    final colors = context.watch<ThemeProvider>().colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder<UserProfile?>(
          future: _loadUserProfile(listing.ownerId),
          builder: (context, snapshot) {
            final sellerName = snapshot.data?.displayName.isNotEmpty == true
                ? snapshot.data!.displayName
                : 'Seller ${listing.ownerId.substring(0, listing.ownerId.length.clamp(0, 6))}';

            return NeoCard(
              backgroundColor: colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seller',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: AppTheme.spacing2.h),
                  Text(
                    sellerName,
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: AppTheme.spacing2.h),
                  Text(
                    listing.name,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: AppTheme.spacing2.h),
                  Text(
                    listing.priceLabel,
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: AppTheme.spacing4.h),
                  Text(
                    isSeller
                        ? 'You are the seller on this listing.'
                        : 'Chat directly with the seller from here.',
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: AppTheme.spacing4.h),
        NeoCard(
          backgroundColor: colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Listing',
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: AppTheme.spacing2.h),
              Text(
                listing.description,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConversation(
    BuildContext context, {
    required ExchangeListing listing,
    required ExchangeChatProvider provider,
    required User? currentUser,
  }) {
    final colors = context.watch<ThemeProvider>().colors;
    final textTheme = Theme.of(context).textTheme;
    final hasThread = provider.activeThread != null;

    final messageList = provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : provider.messages.isEmpty
            ? Center(
                child: Text(
                  hasThread ? 'No messages yet. Say hello.' : 'Open a chat to begin.',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              )
            : ListView.builder(
                itemCount: provider.messages.length,
                padding: EdgeInsets.all(AppTheme.spacing4.w),
                itemBuilder: (context, index) {
                  final message = provider.messages[index];
                  final isMine = currentUser != null && message.senderId == currentUser.uid;
                  return _buildMessageBubble(context, message: message.body, isMine: isMine);
                },
              );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeoCard(
          backgroundColor: colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chat',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
                SizedBox(height: AppTheme.spacing2.h),
              Text(
                listing.name,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        NeoCard(
          backgroundColor: colors.white,
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 480.h,
            child: messageList,
          ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        NeoCard(
          backgroundColor: colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeoInput(
                label: 'Message',
                placeholder: 'Type your message...',
                controller: _messageController,
                onChanged: (_) {
                  if (provider.errorMessage.isNotEmpty) {
                    provider.clearError();
                  }
                },
              ),
              SizedBox(height: AppTheme.spacing4.h),
              NeoButton(
                label: provider.isSending ? 'Sending...' : 'Send',
                isFullWidth: true,
                isLoading: provider.isSending,
                onPressed: () async {
                  if (currentUser == null) return;
                  final trimmed = _messageController.text.trim();
                  if (trimmed.isEmpty) return;

                  // If the thread isn't ready yet, wait for the in-flight
                  // Firestore fetch to finish (or kick one off).  This
                  // handles the race where the user taps Send before the
                  // initial load completes.
                  if (provider.activeThread == null) {
                    await provider.ensureBuyerThread(
                      listingId: listing.id,
                      buyerId: currentUser.uid,
                      sellerId: listing.ownerId,
                    );
                  }

                  if (!mounted) return;
                  final sent = await provider.sendMessage(
                    senderId: currentUser.uid,
                    body: trimmed,
                  );
                  if (sent && mounted) {
                    _messageController.clear();
                  }
                },
              ),
              if (provider.errorMessage.isNotEmpty) ...[
                SizedBox(height: AppTheme.spacing2.h),
                Text(
                  provider.errorMessage,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.accentPink,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, String message) {
    final colors = context.watch<ThemeProvider>().colors;
    return NeoCard(
      backgroundColor: colors.white,
      child: Text(
        message,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context, {
    required String message,
    required bool isMine,
  }) {
    final colors = context.watch<ThemeProvider>().colors;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: AppTheme.spacing2.h),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4.w,
          vertical: AppTheme.spacing2.h,
        ),
        decoration: BoxDecoration(
          color: isMine ? colors.primaryYellow : colors.white,
          border: Border.all(color: colors.black, width: AppTheme.borderWidth),
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<UserProfile?> _loadUserProfile(String uid) async {
    if (uid.isEmpty) {
      return null;
    }
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return UserProfile.fromSnapshot(snapshot);
  }
}