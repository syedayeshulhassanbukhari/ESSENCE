import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/exchange_listing.dart';
import '../providers/exchange_chat_provider.dart';
import '../providers/responsive_provider.dart';
import '../providers/theme_provider.dart';
import '../services/exchange_chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/neo_widgets.dart';

class ExchangeListingDetailScreen extends StatefulWidget {
  const ExchangeListingDetailScreen({super.key, this.listing});

  final ExchangeListing? listing;

  @override
  State<ExchangeListingDetailScreen> createState() =>
      _ExchangeListingDetailScreenState();
}

class _ExchangeListingDetailScreenState
    extends State<ExchangeListingDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _queuedInitialLoad = false;

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Text(
            'No exchange listing selected.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        Provider(create: (_) => ExchangeChatService()),
        ChangeNotifierProvider(
          create: (context) => ExchangeChatProvider(
            service: context.read<ExchangeChatService>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final colors = context.watch<ThemeProvider>().colors;
          final brightness = Theme.of(context).brightness;
          final responsive = context.watch<ResponsiveProvider>();
          final isSmall = responsive.isSmall;
          final currentUser = _currentUser();
          final isSeller = currentUser != null &&
              listing.ownerId.isNotEmpty &&
              currentUser.uid == listing.ownerId;

          if (!_queuedInitialLoad &&
              currentUser != null &&
              listing.ownerId.isNotEmpty) {
            _queuedInitialLoad = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              final chatProvider = context.read<ExchangeChatProvider>();
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
            });
          }

          final bgColor = brightness == Brightness.light
              ? colors.backgroundLight
              : colors.backgroundDark;

          return Scaffold(
            backgroundColor: bgColor,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildListingSummary(
                          context,
                          listing: listing,
                          isSmall: isSmall,
                        ),
                        SizedBox(height: AppTheme.spacing8.h),
                        _buildChatSection(
                          context,
                          listing: listing,
                          currentUser: currentUser,
                          isSeller: isSeller,
                          isSmall: isSmall,
                        ),
                      ],
                    ),
                  ),
                  const AppFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  User? _currentUser() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  Widget _buildListingSummary(
    BuildContext context, {
    required ExchangeListing listing,
    required bool isSmall,
  }) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    final textTheme = Theme.of(context).textTheme;

    final image = SizedBox(
      width: isSmall ? double.infinity : 360.w,
      height: isSmall ? 240.h : 280.h,
      child: Image.network(
        listing.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: colors.gray400,
            alignment: Alignment.center,
            child: Text(
              'Image unavailable',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.black,
              ),
            ),
          );
        },
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listing.name,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: AppTheme.spacing2.h),
        Text(
          listing.priceLabel,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        Text(
          listing.description,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        Text(
          listing.ownerId.isNotEmpty
              ? 'Seller verified by Firebase Auth.'
              : 'Seller not linked yet.',
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: brightness == Brightness.light
                ? colors.black
                : colors.primaryYellow,
          ),
        ),
      ],
    );

    final content = isSmall
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image,
              SizedBox(height: AppTheme.spacing4.h),
              details,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image,
              SizedBox(width: AppTheme.spacing6.w),
              Expanded(child: details),
            ],
          );

    return NeoCard(
      backgroundColor: colors.white,
      padding: EdgeInsets.all(AppTheme.spacing6.w),
      child: content,
    );
  }

  Widget _buildChatSection(
    BuildContext context, {
    required ExchangeListing listing,
    required User? currentUser,
    required bool isSeller,
    required bool isSmall,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.watch<ThemeProvider>().colors;
    final chatProvider = context.watch<ExchangeChatProvider>();

    if (currentUser == null) {
      return _buildStatusCard(
        context,
        message: 'Sign in to start a chat about this listing.',
      );
    }

    if (listing.ownerId.isEmpty) {
      return _buildStatusCard(
        context,
        message: 'Chat is unavailable because the seller is not linked yet.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSeller ? 'Buyer Chats' : 'Chat With Seller',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: AppTheme.spacing4.h),
        if (isSeller)
          _buildSellerChat(
            context,
            provider: chatProvider,
            currentUser: currentUser,
            isSmall: isSmall,
          )
        else
          _buildBuyerChat(
            context,
            provider: chatProvider,
            currentUser: currentUser,
            isSmall: isSmall,
          ),
        if (chatProvider.errorMessage.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: AppTheme.spacing2.h),
            child: Text(
              chatProvider.errorMessage,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.accentPink,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSellerChat(
    BuildContext context, {
    required ExchangeChatProvider provider,
    required User currentUser,
    required bool isSmall,
  }) {
    final content = isSmall
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildThreadList(context, provider: provider, isSmall: true),
              SizedBox(height: AppTheme.spacing4.h),
              _buildChatWindow(
                context,
                provider: provider,
                currentUser: currentUser,
                isSmall: true,
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildThreadList(
                  context,
                  provider: provider,
                  isSmall: false,
                ),
              ),
              SizedBox(width: AppTheme.spacing6.w),
              Expanded(
                flex: 3,
                child: _buildChatWindow(
                  context,
                  provider: provider,
                  currentUser: currentUser,
                  isSmall: false,
                ),
              ),
            ],
          );

    return content;
  }

  Widget _buildBuyerChat(
    BuildContext context, {
    required ExchangeChatProvider provider,
    required User currentUser,
    required bool isSmall,
  }) {
    return _buildChatWindow(
      context,
      provider: provider,
      currentUser: currentUser,
      isSmall: isSmall,
    );
  }

  Widget _buildThreadList(
    BuildContext context, {
    required ExchangeChatProvider provider,
    required bool isSmall,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.watch<ThemeProvider>().colors;

    Widget content;
    if (provider.isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (provider.threads.isEmpty) {
      content = Center(
        child: Text(
          'No buyer chats yet.',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      content = ListView.separated(
        itemCount: provider.threads.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final thread = provider.threads[index];
          final isActive = provider.activeThread?.id == thread.id;
          final buyerLabel = _shortId(thread.buyerId);
          return ListTile(
            title: Text(
              'Buyer $buyerLabel',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              thread.lastMessage.isNotEmpty
                  ? thread.lastMessage
                  : 'No messages yet.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: isActive
                ? Icon(Icons.chat_bubble, color: colors.accentCyan)
                : null,
            onTap: () => provider.selectThread(thread),
          );
        },
      );
    }

    return NeoCard(
      backgroundColor: colors.white,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: isSmall ? 260.h : 420.h,
        child: content,
      ),
    );
  }

  Widget _buildChatWindow(
    BuildContext context, {
    required ExchangeChatProvider provider,
    required User currentUser,
    required bool isSmall,
  }) {
    final colors = context.watch<ThemeProvider>().colors;
    final textTheme = Theme.of(context).textTheme;
    final hasThread = provider.activeThread != null;

    final messageList = provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : provider.messages.isEmpty
            ? Center(
                child: Text(
                  hasThread
                      ? 'No messages yet. Say hello.'
                      : 'Select a buyer thread to start chatting.',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: provider.messages.length,
                padding: EdgeInsets.all(AppTheme.spacing4.w),
                itemBuilder: (context, index) {
                  final message = provider.messages[index];
                  final isMine = message.senderId == currentUser.uid;
                  return _buildMessageBubble(
                    context,
                    message: message.body,
                    isMine: isMine,
                  );
                },
              );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeoCard(
          backgroundColor: colors.white,
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: isSmall ? 320.h : 420.h,
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
                    // Reset error after user starts typing again.
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
                  if (!hasThread) {
                    return;
                  }
                  final sent = await provider.sendMessage(
                    senderId: currentUser.uid,
                    body: _messageController.text,
                  );
                  if (sent) {
                    _messageController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(
    BuildContext context, {
    required String message,
    required bool isMine,
  }) {
    final colors = context.watch<ThemeProvider>().colors;
    final brightness = Theme.of(context).brightness;
    final bubbleColor = isMine
        ? colors.accentCyan
        : (brightness == Brightness.light ? colors.white : colors.zinc800);
    final textColor = isMine
        ? colors.black
        : (brightness == Brightness.light ? colors.black : colors.white);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: AppTheme.spacing2.h),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4.w,
          vertical: AppTheme.spacing2.h,
        ),
        decoration: AppTheme.neoBorder(
          colors,
          brightness,
          backgroundColor: bubbleColor,
          shadow: true,
          shadowOffset: AppTheme.shadowSmall,
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, {required String message}) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.watch<ThemeProvider>().colors;

    return NeoCard(
      backgroundColor: colors.white,
      child: Text(
        message,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _shortId(String value) {
    if (value.isEmpty) {
      return 'Unknown';
    }
    return value.length <= 6 ? value : value.substring(0, 6).toUpperCase();
  }
}
