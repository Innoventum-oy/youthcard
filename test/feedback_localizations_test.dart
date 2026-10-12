import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youth_card/src/util/feedback_localizations.dart';

void main() {
  test('feedback uses local translations for all app-only languages', () async {
    final delegate = YouthCardFeedbackLocalizationsDelegate();
    final messages = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) messages.add(message);
    };

    try {
      for (final (locale, submitText) in [
        (const Locale('fi', 'FI'), 'Lähetä'),
        (const Locale('cs', 'CZ'), 'Odeslat'),
        (const Locale('hr', 'HR'), 'Pošalji'),
      ]) {
        expect(delegate.isSupported(locale), isTrue);
        expect((await delegate.load(locale)).submitButtonText, submitText);
      }
      expect(messages, isEmpty);
    } finally {
      debugPrint = originalDebugPrint;
    }
  });
}
