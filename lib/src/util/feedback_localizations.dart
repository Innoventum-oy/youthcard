import 'package:feedback/feedback.dart';
import 'package:flutter/widgets.dart';

/// Adds the app's languages missing from the feedback package's translations.
class YouthCardFeedbackLocalizationsDelegate
    extends GlobalFeedbackLocalizationsDelegate {
  YouthCardFeedbackLocalizationsDelegate() {
    supportedLocales.addAll({
      const Locale('fi'): const _FinnishFeedbackLocalizations(),
      const Locale('sv'): const _SwedishFeedbackLocalizations(),
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

class _SwedishFeedbackLocalizations extends FeedbackLocalizations {
  const _SwedishFeedbackLocalizations();

  @override
  String get submitButtonText => 'Skicka';
  @override
  String get feedbackDescriptionText => 'Vad kan vi förbättra?';
  @override
  String get navigate => 'Bläddra';
  @override
  String get draw => 'Rita';
}
