import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

/// Converts any Eastern Arabic-Indic digits (٠-٩) in [input] to Western
/// (Latin) digits (0-9). Used so the app always renders plain 0-9 numerals
/// regardless of the active locale (Arabic text stays Arabic, only the
/// digits become Latin).
String toLatinDigits(String input) {
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  String out = input;
  for (int i = 0; i < eastern.length; i++) {
    out = out.replaceAll(eastern[i], western[i]);
  }
  return out;
}

/// Forces intl's Arabic ('ar') number symbols to use Latin digits so that any
/// DateFormat/NumberFormat operating in the 'ar' locale emits 0-9 instead of
/// ٠-٩. Safe to call multiple times.
void forceLatinDigitsForArabic() {
  final ar = numberFormatSymbols['ar'];
  if (ar != null && ar.ZERO_DIGIT != '0') {
    numberFormatSymbols['ar'] = _LatinArabicNumberSymbols(ar);
  }
}

class _LatinArabicNumberSymbols extends NumberSymbols {
  final NumberSymbols _base;

  _LatinArabicNumberSymbols(this._base)
      : super(
          NAME: _base.NAME,
          DECIMAL_SEP: _base.DECIMAL_SEP,
          GROUP_SEP: _base.GROUP_SEP,
          PERCENT: _base.PERCENT,
          ZERO_DIGIT: '0',
          PLUS_SIGN: _base.PLUS_SIGN,
          MINUS_SIGN: _base.MINUS_SIGN,
          EXP_SYMBOL: _base.EXP_SYMBOL,
          PERMILL: _base.PERMILL,
          INFINITY: _base.INFINITY,
          NAN: _base.NAN,
          DECIMAL_PATTERN: _base.DECIMAL_PATTERN,
          SCIENTIFIC_PATTERN: _base.SCIENTIFIC_PATTERN,
          PERCENT_PATTERN: _base.PERCENT_PATTERN,
          CURRENCY_PATTERN: _base.CURRENCY_PATTERN,
          DEF_CURRENCY_CODE: _base.DEF_CURRENCY_CODE,
        );
}
