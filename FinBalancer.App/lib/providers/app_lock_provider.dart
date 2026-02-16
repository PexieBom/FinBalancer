import 'package:flutter/widgets.dart';
import '../services/app_lock_service.dart';

/// Provider za upravljanje zaključavanjem aplikacije PIN-om.
/// Na mobilnim uređajima, ako je omogućeno, aplikacija se zaključa
/// pri pokretanju ili povratku iz pozadine.
class AppLockProvider extends ChangeNotifier with WidgetsBindingObserver {
  final AppLockService _service = AppLockService();

  bool _isLocked = true;
  bool _isEnabled = false;
  bool _isLoading = true;

  bool get isLocked => _isLocked;
  bool get isEnabled => _isEnabled;
  bool get isLoading => _isLoading;
  bool get isMobile => AppLockService.isMobile;

  AppLockProvider() {
    _init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isEnabled || !isMobile) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _lock();
    }
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _isEnabled = await _service.isEnabled();
    _isLocked = _isEnabled;
    _isLoading = false;
    notifyListeners();
  }

  void _lock() {
    if (_isEnabled && _isLocked == false) {
      _isLocked = true;
      notifyListeners();
    }
  }

  /// Provjeri PIN bez otključavanja (za promjenu PIN-a u postavkama)
  Future<bool> verifyPin(String pin) async => _service.verify(pin);

  /// Otključaj aplikaciju s PIN-om
  Future<bool> unlock(String pin) async {
    final ok = await _service.verify(pin);
    if (ok) {
      _isLocked = false;
      notifyListeners();
    }
    return ok;
  }

  /// Omogući zaključavanje i postavi PIN
  Future<void> setPin(String pin) async {
    await _service.enable(pin);
    _isEnabled = true;
    _isLocked = false;
    notifyListeners();
  }

  /// Onemogući zaključavanje
  Future<void> removePin() async {
    await _service.disable();
    _isEnabled = false;
    _isLocked = false;
    notifyListeners();
  }

  /// Promijeni PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    final ok = await _service.changePin(oldPin, newPin);
    if (ok) notifyListeners();
    return ok;
  }

  /// Osvježi stanje (npr. nakon login-a za provjeru ima li korisnik PIN)
  Future<void> refresh() async {
    await _init();
  }
}
