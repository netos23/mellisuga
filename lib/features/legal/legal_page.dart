import 'package:flutter/material.dart';

import '../../core/widgets/responsive.dart';
import 'legal_content.dart';

/// Renders one of the app's legal documents.
class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.document});

  final LegalDocument document;

  static Route<void> route(LegalDocument document) => MaterialPageRoute(
    builder: (context) => Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: LegalPage(document: document),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: ReadableWidth(
        maxWidth: 720,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.title,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              document.summary,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last updated ${document.lastUpdated}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            for (final section in document.sections) ...[
              Text(
                section.heading,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              for (final paragraph in section.paragraphs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(paragraph, style: theme.textTheme.bodyMedium?.copyWith(height: 1.55)),
                ),
              for (final bullet in section.bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 10),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          bullet,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
