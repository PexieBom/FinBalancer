import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/subscription.dart';
import '../services/api_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  SubscriptionStatus _status = const SubscriptionStatus(isPremium: false);
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _error;
  String? _pendingUserId;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  SubscriptionStatus get status => _status;
  List<SubscriptionPlan> get plans => _plans;
  bool get isPremium => _status.isPremium;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get error => _error;

  /// Check if in-app purchase is available (iOS/Android only).
  Future<bool> get isStoreAvailable async {
    try {
      return await InAppPurchase.instance.isAvailable();
    } catch (_) {
      return false;
    }
  }

  SubscriptionProvider() {
    _listenToPurchases();
  }

  void _listenToPurchases() {
    try {
      final purchaseUpdated = InAppPurchase.instance.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (e) => _handleError(e.toString()),
      );
    } catch (_) {
      // Store not available (e.g. Windows, Web)
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        // Show pending UI
      } else if (purchase.status == PurchaseStatus.error) {
        _handleError(purchase.error?.message ?? 'Purchase failed');
        _isPurchasing = false;
        notifyListeners();
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _verifyAndActivatePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.canceled) {
        _isPurchasing = false;
        _error = null;
        notifyListeners();
      }
    }
  }

  Future<void> _verifyAndActivatePurchase(PurchaseDetails purchase) async {
    final productId = purchase.productID;
    final verificationData = purchase.verificationData.serverVerificationData;
    final src = purchase.verificationData.source.toString();
    final isApple = src.contains('appStore') || src.contains('app_store');

    _isPurchasing = false;
    notifyListeners();

    if (verificationData.isEmpty || _pendingUserId == null) return;

    final userId = _pendingUserId!;
    _pendingUserId = null;

    await validatePurchaseWithBackend(
      userId: userId,
      platform: isApple ? 'apple' : 'google',
      productId: productId,
      purchaseToken: isApple ? null : verificationData,
      receiptData: isApple ? verificationData : null,
    );
    await loadStatus(userId);
  }

  Future<void> loadStatus(String? userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _status = await _api.getSubscriptionStatus(userId: userId);
    } catch (e) {
      _status = const SubscriptionStatus(isPremium: false);
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPlans() async {
    try {
      _plans = await _api.getSubscriptionPlans();
      notifyListeners();
    } catch (_) {
      _plans = [];
    }
  }

  Future<bool> purchaseSubscription({
    required String userId,
    required ProductDetails product,
  }) async {
    if (userId.isEmpty) {
      _handleError('Please sign in to subscribe');
      return false;
    }

    final available = await isStoreAvailable;
    if (!available) {
      _handleError('In-app purchases are only available on iOS and Android');
      return false;
    }

    _pendingUserId = userId;
    _isPurchasing = true;
    _error = null;
    notifyListeners();

    try {
      final purchaseParam = PurchaseParam(productDetails: product);

      final success = await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
      if (!success) {
        _isPurchasing = false;
        _handleError('Could not start purchase');
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _isPurchasing = false;
      _handleError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  /// Web: subscribe via PayPal. Opens approval URL; after return call confirmPayPalReturn.
  Future<bool> subscribeWithPayPal(SubscriptionPlan plan, String returnUrl, String cancelUrl) async {
    _isPurchasing = true;
    _error = null;
    notifyListeners();
    try {
      final result = await ApiService().createPayPalSubscription(
        productCode: plan.productId,
        paypalPlanId: plan.paypalPlanId,
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
      );
      if (result.approvalUrl != null && result.approvalUrl!.isNotEmpty) {
        final uri = Uri.parse(result.approvalUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      }
      _handleError('Could not open PayPal');
      return false;
    } catch (e) {
      _handleError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isPurchasing = false;
      notifyListeners();
    }
  }

  /// Web: after PayPal approval redirect, confirm subscription.
  Future<void> confirmPayPalReturn(String? userId, String subscriptionId, String productCode) async {
    if (userId == null || userId.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      final status = await ApiService().confirmPayPalSubscription(
        subscriptionId: subscriptionId,
        productCode: productCode,
      );
      if (status != null && status.isPremium) {
        _status = status;
        _error = null;
      } else {
        _handleError('Subscription could not be confirmed');
      }
    } catch (e) {
      _handleError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restorePurchases(String? userId) async {
    if (userId == null || userId.isEmpty) {
      _handleError('Please sign in to restore');
      return;
    }

    _pendingUserId = userId;

    final available = await isStoreAvailable;
    if (!available) {
      await loadStatus(userId);
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await InAppPurchase.instance.restorePurchases();
      await Future.delayed(const Duration(milliseconds: 500));
      await loadStatus(userId);
    } catch (e) {
      _handleError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> validatePurchaseWithBackend({
    required String userId,
    required String platform,
    required String productId,
    String? purchaseToken,
    String? receiptData,
    String? orderId,
  }) async {
    try {
      final status = await _api.confirmMobilePurchase(
        platform: platform,
        productCode: productId,
        storeProductId: productId,
        purchaseToken: purchaseToken,
        receiptData: receiptData,
        orderId: orderId,
      );
      if (status != null) {
        _status = status;
        _error = null;
        notifyListeners();
      }
    } catch (_) {}
  }

  void _handleError(String message) {
    _error = message;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
