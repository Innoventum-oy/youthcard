import 'package:feedback/feedback.dart';
import 'package:flutter/widgets.dart';

/// Adds the app's languages missing from the feedback package's translations.
class YouthCardFeedbackLocalizationsDelegate
    extends GlobalFeedbackLocalizationsDelegate {
  YouthCardFeedbackLocalizationsDelegate() {
    supportedLocales.addAll({
      const Locale('fi'): const _FinnishFeedbackLocalizations(),
      const Locale('cs'): const _CzechFeedbackLocalizations(),
      const Locale('hr'): const _CroatianFeedbackLocalizations(),
    });
  }
}

class _FinnishFeedbackLocalizations extends FeedbackLocalizations {
  const _FinnishFeedbackLocalizations();

  @override
  String get submitButtonText => 'Lähetä';
  @override
  String get feedbackDescriptionText => 'Mitä voisimme tehdä paremmin?';
  @override
  String get navigate => 'Selaa';
  @override
  String get draw => 'Piirrä';
}

class _CzechFeedbackLocalizations extends FeedbackLocalizations {
  const _CzechFeedbackLocalizations();

  @override
  String get submitButtonText => 'Odeslat';
  @override
  String get feedbackDescriptionText => 'Co bychom mohli zlepšit?';
  @override
  String get navigate => 'Procházet';
  @override
  String get draw => 'Kreslit';
}

class _CroatianFeedbackLocalizations extends FeedbackLocalizations {
  const _CroatianFeedbackLocalizations();

  @override
  String get submitButtonText => 'Pošalji';
  @override
  String get feedbackDescriptionText => 'Što bismo mogli poboljšati?';
  @override
  String get navigate => 'Pregledaj';
  @override
  String get draw => 'Crtaj';
}
