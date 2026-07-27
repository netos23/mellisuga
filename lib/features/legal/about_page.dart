import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_info.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/responsive.dart';
import 'legal_content.dart';
import 'legal_page.dart';

/// About screen: what the app is, who made it, and every legal document.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static Route<void> route() => MaterialPageRoute(
    builder: (context) => Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const AboutPage(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Text(AppInfo.description, style: theme.textTheme.bodyLarge?.copyWith(height: 1.55)),
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
                            'Nothing is uploaded',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Every tool runs on your own device. The web version '
                            'is a static site with no backend, so there is no '
                            'server that could receive your files.',
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
              'Legal',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _LinkTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: LegalContent.privacy.summary,
              onTap: () => Navigator.of(context).push(LegalPage.route(LegalContent.privacy)),
            ),
            _LinkTile(
              icon: Icons.gavel_rounded,
              title: 'Terms of Use',
              subtitle: LegalContent.terms.summary,
              onTap: () => Navigator.of(context).push(LegalPage.route(LegalContent.terms)),
            ),
            _LinkTile(
              icon: Icons.workspace_premium_outlined,
              title: 'Open source licences',
              subtitle:
                  '${AppInfo.name} is under the ${AppInfo.licenseName}. '
                  'Includes notices for every bundled package.',
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
              'Project',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _LinkTile(
              icon: Icons.code_rounded,
              title: 'Source code',
              subtitle: AppInfo.repositoryUrl,
              external: true,
              onTap: () =>
                  launchUrl(Uri.parse(AppInfo.repositoryUrl), mode: LaunchMode.externalApplication),
            ),
            _LinkTile(
              icon: Icons.bug_report_outlined,
              title: 'Report a problem',
              subtitle: 'Bugs, feature requests and questions',
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
