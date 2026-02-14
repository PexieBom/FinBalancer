import 'package:intl/intl.dart';
import '../providers/locale_provider.dart';

String formatCurrency(double amount, LocaleProvider localeProvider) {
  final locale = _localeToString(localeProvider.localeCode);
  final symbol = _getCurrencySymbol(localeProvider.currency);
  return NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: 2,
  ).format(amount);
}

NumberFormat currencyNumberFormat(LocaleProvider localeProvider) {
  final locale = _localeToString(localeProvider.localeCode);
  final symbol = _getCurrencySymbol(localeProvider.currency);
  return NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: 2,
  );
}

String _localeToString(String code) {
  const map = {
    'en': 'en_US',
    'hr': 'hr_HR',
    'de': 'de_DE',
    'fr': 'fr_FR',
    'es': 'es_ES',
    'it': 'it_IT',
    'pt': 'pt_PT',
    'nl': 'nl_NL',
    'pl': 'pl_PL',
    'cs': 'cs_CZ',
    'ru': 'ru_RU',
    'zh': 'zh_CN',
    'ja': 'ja_JP',
    'tr': 'tr_TR',
    'ar': 'ar_SA',
    'sk': 'sk_SK',
    'hu': 'hu_HU',
    'el': 'el_GR',
    'sv': 'sv_SE',
    'da': 'da_DK',
    'no': 'nb_NO',
    'fi': 'fi_FI',
    'ko': 'ko_KR',
  };
  return map[code] ?? '${code}_${code.toUpperCase()}';
}

String _getCurrencySymbol(String code) {
  const symbols = {
    'EUR': '€',
    'USD': '\$',
    'GBP': '£',
    'HRK': 'kn',
    'CHF': 'CHF',
    'JPY': '¥',
    'CNY': '¥',
    'RUB': '₽',
    'PLN': 'zł',
    'CZK': 'Kč',
    'HUF': 'Ft',
    'RON': 'lei',
    'BGN': 'лв',
    'TRY': '₺',
    'INR': '₹',
    'BRL': 'R\$',
    'MXN': '\$',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'KRW': '₩',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
  };
  return symbols[code] ?? code;
}
