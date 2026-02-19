import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../providers/notifications_provider.dart';
import '../models/in_app_notification.dart';

/// Ikona obavijesti za app bar s badge-om za nepročitane.
class NotificationsIcon extends StatelessWidget {
  const NotificationsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, provider, _) {
        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined),
              if (provider.unreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.expense(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1),
                    ),
                    child: Text(
                      provider.unreadCount > 99 ? '99+' : '${provider.unreadCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => _showNotificationsPanel(context, provider),
        );
      },
    );
  }

  void _showNotificationsPanel(BuildContext context, NotificationsProvider provider) async {
    await provider.loadNotifications();
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _NotificationsPanel(
          provider: provider,
          scrollController: scrollController,
          onClose: () => Navigator.pop(ctx),
        ),
      ),
    );
  }
}

class _NotificationsPanel extends StatelessWidget {
  final NotificationsProvider provider;
  final ScrollController scrollController;
  final VoidCallback onClose;

  const _NotificationsPanel({
    required this.provider,
    required this.scrollController,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = _l10n(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (provider.unreadCount > 0)
                  TextButton(
                    onPressed: () async {
                      await provider.markAllAsRead();
                    },
                    child: Text(_markAllRead(context)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading && provider.notifications.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              _noNotifications(context),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: provider.notifications.length,
                        itemBuilder: (_, i) {
                          final n = provider.notifications[i];
                          return _NotificationTile(
                            notification: n,
                            onTap: () async {
                              if (!n.isRead) await provider.markAsRead(n.id);
                              final route = n.actionRoute;
                              final nav = Navigator.of(context);
                              nav.pop();
                              if (route != null) nav.pushNamed(route);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _l10n(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'hr' ? 'Obavijesti' : 'Notifications';
  }

  String _markAllRead(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'hr' ? 'Označi sve kao pročitano' : 'Mark all as read';
  }

  String _noNotifications(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'hr' ? 'Nema obavijesti' : 'No notifications';
  }
}

class _NotificationTile extends StatelessWidget {
  final InAppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: notification.isRead
            ? theme.colorScheme.surfaceContainerHighest
            : AppTheme.accent(context).withOpacity(0.2),
        child: Icon(
          _iconForType(notification.type),
          color: notification.isRead
              ? theme.colorScheme.onSurfaceVariant
              : AppTheme.accent(context),
        ),
      ),
      title: Text(
        notification.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.body,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(notification.createdAt),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.accent(context),
                shape: BoxShape.circle,
              ),
            ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'AccountLinkInvite':
        return Icons.people_outline;
      case 'BudgetAlert':
        return Icons.pie_chart_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Upravo';
    if (diff.inMinutes < 60) return 'Prije ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Prije ${diff.inHours} h';
    if (diff.inDays < 7) return 'Prije ${diff.inDays} d';
    return DateFormat('dd.MM.').format(dt);
  }
}
