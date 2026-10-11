import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:youth_card/l10n/app_localizations.dart';

/// Additional information returned by the full iCMS activity endpoint.
class MetaSection extends StatelessWidget {
  const MetaSection(this.data, {super.key});

  final dynamic data;

  Map<String, dynamic>? get _fields {
    if (data is! Map) return null;
    final record = data['data'] is Map ? data['data'] : data;
    return Map<String, dynamic>.from(record as Map);
  }

  String? _text(Map<String, dynamic> fields, String key) {
    final value = fields[key];
    if (value == null || value == false) return null;
    final text = value.toString().trim();
    return text.isEmpty || text == 'null' ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    final fields = _fields;
    if (fields == null) return const SizedBox.shrink();
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final address = [
      _text(fields, 'address'),
      [
        _text(fields, 'postcode'),
        _text(fields, 'city'),
      ].whereType<String>().join(' '),
    ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
    final organizer = fields['organizer'] is Map
        ? fields['organizer']['name']?.toString()
        : _text(fields, 'organizer');
    final minAge = _text(fields, 'agemin');
    final maxAge = _text(fields, 'agemax');
    final ages = [minAge, maxAge].whereType<String>().join('–');
    final priceValue = _text(fields, 'price');
    final price = priceValue == null
        ? null
        : (double.tryParse(priceValue) == 0 ? strings.free : priceValue);
    final registered = _text(fields, 'registeredvisitorcount');
    final capacity = _text(fields, 'maxvisitors');
    final participants = capacity == null
        ? null
        : '${registered ?? '0'} / $capacity';
    final contact = _text(fields, 'contactinfo');
    final rows = <Widget>[
      if (address.isNotEmpty) _row(context, strings.address, address),
      if (ages.isNotEmpty) _row(context, strings.ageRange, ages),
      if (participants != null)
        _row(context, strings.participants, participants),
      if (price != null) _row(context, strings.price, price),
      if (organizer != null && organizer.isNotEmpty)
        _row(context, strings.organizer, organizer),
    ];
    if (rows.isEmpty && contact == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.about,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (rows.isNotEmpty) ...[const SizedBox(height: 12), ...rows],
        if (contact != null) ...[
          const SizedBox(height: 18),
          Text(
            strings.contactInformation,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Html(
            data: contact,
            style: {
              '*': Style(color: colors.onSurface),
              'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            },
          ),
        ],
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
