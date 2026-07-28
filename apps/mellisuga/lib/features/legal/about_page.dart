import 'package:flutter/material.dart';
import 'package:mellisuga_content/mellisuga_content.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/analytics/analytics_consent.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/app_info.dart';
import '../../core/localization/app_locale_context.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import 'legal_page.dart';

/// About screen: what the app is, who made it, and every legal document.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static Route<void> route() => MaterialPageRoute(
    builder: (context) => Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).aboutPageTitle)),
      body: const AboutPage(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = context.appLocale;

    return SingleChildScrollView(
      child: ReadableWidth(
        maxWidth: 640,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppLogoBadge(size: 68),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppInfo.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppInfo.versionLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              locale.brandDescriptionIn(),
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.nothingUploadedTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.nothingUploadedBody,
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.privacyAnalyticsSectionTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const _AnalyticsToggle(),
            const SizedBox(height: 24),
            Text(
              l10n.legalSectionTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _LinkTile(
              icon: Icons.privacy_tip_outlined,
              title: l10n.menuPrivacyPolicy,
              subtitle: LegalContent.privacy.summary,
              onTap: () => Navigator.of(context).push(LegalPage.route(LegalContent.privacy)),
            ),
            _LinkTile(
              icon: Icons.gavel_rounded,
              title: l10n.menuTermsOfUse,
              subtitle: LegalContent.terms.summary,
              onTap: () => Navigator.of(context).push(LegalPage.route(LegalContent.terms)),
            ),
            _LinkTile(
              icon: Icons.workspace_premium_outlined,
              title: l10n.menuOpenSourceLicences,
              subtitle: l10n.licencesSubtitle(AppInfo.name, AppInfo.licenseName),
              onTap: () => showLicensePage(
                context: context,
                applicationName: AppInfo.name,
                applicationVersion: AppInfo.versionLabel,
                applicationLegalese:
                    '${AppInfo.copyright}\nReleased under the ${AppInfo.licenseName}.',
                applicationIcon: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: AppLogoBadge(size: 56),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.projectSectionTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _LinkTile(
              icon: Icons.public_rounded,
              title: l10n.websiteTile,
              subtitle: AppInfo.websiteUrl,
              external: true,
              onTap: () =>
                  launchUrl(Uri.parse(AppInfo.websiteUrl), mode: LaunchMode.externalApplication),
            ),
            _LinkTile(
              icon: Icons.code_rounded,
              title: l10n.sourceCodeTile,
              subtitle: AppInfo.repositoryUrl,
              external: true,
              onTap: () =>
                  launchUrl(Uri.parse(AppInfo.repositoryUrl), mode: LaunchMode.externalApplication),
            ),
            _LinkTile(
              icon: Icons.bug_report_outlined,
              title: l10n.reportProblemTile,
              subtitle: l10n.reportProblemSubtitle,
              external: true,
              onTap: () =>
                  launchUrl(Uri.parse(AppInfo.issuesUrl), mode: LaunchMode.externalApplication),
            ),
            const SizedBox(height: 32),
            Text(
              AppInfo.copyright,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the current analytics consent state and lets it be changed. Hidden
/// behind a disabled explanation when this build has no analytics vendor
/// configured at all, since there is nothing to toggle in that case.
class _AnalyticsToggle extends StatelessWidget {
  const _AnalyticsToggle();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final available = AnalyticsService.instance.hasAnyBackendConfigured;

    return ValueListenableBuilder<bool?>(
      valueListenable: AnalyticsConsent.instance.granted,
      builder: (context, granted, _) {
        final subtitle = !available
            ? l10n.analyticsToggleSubtitleUnavailable
            : (granted == true ? l10n.analyticsToggleSubtitleOn : l10n.analyticsToggleSubtitleOff);

        return Card(
          child: SwitchListTile(
            title: Text(l10n.analyticsToggleTitle),
            subtitle: Text(subtitle),
            value: available && granted == true,
            onChanged: !available ? null : (value) => AnalyticsConsent.instance.setConsent(value),
          ),
        );
      },
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.external = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool external;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          title: Text(title),
          subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: Icon(
            external ? Icons.open_in_new_rounded : Icons.chevron_right_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
