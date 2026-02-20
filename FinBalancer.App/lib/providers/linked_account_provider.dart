import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account_link.dart';
import '../services/api_service.dart';

const _kLinkStatusPrefix = 'link_status_';

/// Drži listu povezanih računa (veze i hostovi čije podatke mogu gledati).
class LinkedAccountProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<AccountLinkItem> _links = [];
  List<LinkedHost> _linkedHosts = [];
  bool _isLoading = false;
  String? _error;
  List<LinkStatusChangeNotification> _pendingNotificationMessages = [];

  List<AccountLinkItem> get links => _links;
  List<LinkedHost> get linkedHosts => _linkedHosts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<LinkStatusChangeNotification> get pendingNotificationMessages =>
      List.unmodifiable(_pendingNotificationMessages);

  void clearPendingNotifications() {
    _pendingNotificationMessages = [];
    notifyListeners();
  }

  Future<List<LinkStatusChangeNotification>> loadLinks() async {
    _isLoading = true;
    _error = null;
    _pendingNotificationMessages = [];
    notifyListeners();
    try {
      _links = await _api.getAccountLinks();
      _linkedHosts = await _api.getLinkedHosts();

      final prefs = await SharedPreferences.getInstance();
      final linkIdsToAcknowledge = <String>[];
      for (final link in _links) {
        if (!link.isCurrentUserHost) continue;
        final key = '$_kLinkStatusPrefix${link.id}';
        final prevStatusStr = prefs.getString(key);
        final prevStatus = prevStatusStr == null
            ? null
            : (prevStatusStr == 'accepted'
                ? AccountLinkStatus.accepted
                : prevStatusStr == 'revoked'
                    ? AccountLinkStatus.revoked
                    : AccountLinkStatus.pending);

        if (prevStatus == AccountLinkStatus.pending) {
          if (link.status == AccountLinkStatus.accepted) {
            _pendingNotificationMessages.add(LinkStatusChangeNotification(
              otherName: link.otherDisplayName,
              accepted: true,
              linkId: link.id,
            ));
            linkIdsToAcknowledge.add(link.id);
          } else if (link.status == AccountLinkStatus.revoked) {
            _pendingNotificationMessages.add(LinkStatusChangeNotification(
              otherName: link.otherDisplayName,
              accepted: false,
              linkId: link.id,
            ));
            linkIdsToAcknowledge.add(link.id);
          }
        }
      }
      for (final link in _links) {
        if (linkIdsToAcknowledge.contains(link.id)) continue;
        final key = '$_kLinkStatusPrefix${link.id}';
        final newStatusStr = link.status == AccountLinkStatus.accepted
            ? 'accepted'
            : link.status == AccountLinkStatus.revoked
                ? 'revoked'
                : 'pending';
        await prefs.setString(key, newStatusStr);
      }
    } catch (e) {
      _error = e.toString();
      _links = [];
      _linkedHosts = [];
    }
    _isLoading = false;
    notifyListeners();
    return _pendingNotificationMessages;
  }

  Future<String?> inviteByEmail(String guestEmail) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _api.inviteAccountLink(guestEmail);
      if (result.success) {
        await loadLinks();
        return null;
      }
      return result.errorCode;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 'Unknown';
    }
  }

  Future<bool> acceptInvite(String linkId) async {
    _error = null;
    try {
      await _api.acceptAccountLink(linkId);
      await loadLinks();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> revokeLink(String linkId) async {
    _error = null;
    try {
      await _api.revokeAccountLink(linkId);
      await loadLinks();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Pozovi nakon prikaza notifikacija da se status spremi i ne prikazuje ponovo.
  Future<void> acknowledgeLinkNotifications(List<String> linkIds) async {
    if (linkIds.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    for (final link in _links) {
      if (!linkIds.contains(link.id)) continue;
      final key = '$_kLinkStatusPrefix${link.id}';
      final newStatusStr = link.status == AccountLinkStatus.accepted
          ? 'accepted'
          : link.status == AccountLinkStatus.revoked
              ? 'revoked'
              : 'pending';
      await prefs.setString(key, newStatusStr);
    }
    _pendingNotificationMessages =
        _pendingNotificationMessages.where((n) => !linkIds.contains(n.linkId)).toList();
    notifyListeners();
  }
}

/// Notifikacija za invitera kad gost accepta ili odbije.
class LinkStatusChangeNotification {
  final String otherName;
  final bool accepted;
  final String linkId;

  LinkStatusChangeNotification({
    required this.otherName,
    required this.accepted,
    required this.linkId,
  });
}
