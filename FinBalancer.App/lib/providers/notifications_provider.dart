import 'package:flutter/foundation.dart';

import '../models/in_app_notification.dart';
import '../services/api_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<InAppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<InAppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _api.getNotifications();
      _unreadCount = await _api.getNotificationsUnreadCount();
    } catch (_) {
      _notifications = [];
      _unreadCount = 0;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _api.getNotificationsUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    try {
      await _api.markNotificationAsRead(id);
      _notifications = _notifications.map((n) {
        if (n.id == id) return InAppNotification(
          id: n.id, type: n.type, title: n.title, body: n.body,
          isRead: true, createdAt: n.createdAt, relatedId: n.relatedId, actionRoute: n.actionRoute,
        );
        return n;
      }).toList();
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.markAllNotificationsAsRead();
      _notifications = _notifications.map((n) => InAppNotification(
        id: n.id, type: n.type, title: n.title, body: n.body,
        isRead: true, createdAt: n.createdAt, relatedId: n.relatedId, actionRoute: n.actionRoute,
      )).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }
}
