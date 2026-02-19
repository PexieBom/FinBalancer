import 'package:flutter/foundation.dart';

import '../models/account_link.dart';
import '../services/api_service.dart';

/// Drži listu povezanih računa (veze i hostovi čije podatke mogu gledati).
class LinkedAccountProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<AccountLinkItem> _links = [];
  List<LinkedHost> _linkedHosts = [];
  bool _isLoading = false;
  String? _error;

  List<AccountLinkItem> get links => _links;
  List<LinkedHost> get linkedHosts => _linkedHosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLinks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _links = await _api.getAccountLinks();
      _linkedHosts = await _api.getLinkedHosts();
    } catch (e) {
      _error = e.toString();
      _links = [];
      _linkedHosts = [];
    }
    _isLoading = false;
    notifyListeners();
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
}
