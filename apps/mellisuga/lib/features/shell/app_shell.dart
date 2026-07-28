import 'package:flutter/material.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

import '../../core/app_info.dart';
import '../../core/localization/app_locale_context.dart';
import '../../core/tools/tool_definition.dart';
import '../../core/tools/tool_registry.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../home/home_page.dart';
import '../legal/about_page.dart';
import '../legal/legal_page.dart';
import 'language_picker.dart';

/// The application frame: branding, tool navigation and theme control.
///
/// Tools are swapped in place rather than pushed as routes, and their state
/// lives above this widget, so switching tools — or stepping out to read the
/// privacy policy — never discards work in progress.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.locale,
    required this.onLocaleChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  /// `null` means "follow the system locale".
  final Locale? locale;
  final ValueChanged<AppLocale?> onLocaleChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// `null` means the home gallery is showing.
  ToolDefinition? _tool;

  void _selectTool(ToolDefinition? tool) {
    setState(() => _tool = tool);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screen) {
        final useRail = !screen.isCompact;

        return Scaffold(
          appBar: _buildAppBar(context, screen),
          drawer: useRail ? null : _buildDrawer(context),
          body: Row(
            children: [
              if (useRail) ...[
                _NavigationRailSidebar(
                  tools: ToolRegistry.tools,
                  selected: _tool,
                  extended: MediaQuery.sizeOf(context).width >= Breakpoints.extendedRail,
                  onSelect: _selectTool,
                ),
                const VerticalDivider(width: 1),
              ],
              Expanded(child: _buildBody()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    final tool = _tool;
    if (tool == null) {
      return HomePage(onOpenTool: _selectTool);
    }
    return ToolRegistry.buildScreen(context, tool);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ScreenSize screen) {
    final tool = _tool;
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Row(
        children: [
          if (!screen.isCompact || tool == null)
            InkWell(
              onTap: () => _selectTool(null),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: AppLogo(markSize: 26, showWordmark: !screen.isCompact),
              ),
            ),
          if (tool != null) ...[
            if (!screen.isCompact)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('/', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
              ),
            Flexible(
              child: Text(
                tool.titleIn(context),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          tooltip: switch (widget.themeMode) {
            ThemeMode.light => l10n.themeSwitchToDark,
            ThemeMode.dark => l10n.themeUseSystemTheme,
            ThemeMode.system => l10n.themeSwitchToLight,
          },
          icon: Icon(switch (widget.themeMode) {
            ThemeMode.light => Icons.light_mode_outlined,
            ThemeMode.dark => Icons.dark_mode_outlined,
            ThemeMode.system => Icons.brightness_auto_outlined,
          }),
          onPressed: () => widget.onThemeModeChanged(switch (widget.themeMode) {
            ThemeMode.light => ThemeMode.dark,
            ThemeMode.dark => ThemeMode.system,
            ThemeMode.system => ThemeMode.light,
          }),
        ),
        PopupMenuButton<String>(
          tooltip: l10n.aboutAndLegalTooltip,
          icon: const Icon(Icons.more_vert_rounded),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'language', child: Text(l10n.menuLanguage)),
            PopupMenuItem(value: 'about', child: Text(l10n.menuAboutMellisuga)),
            PopupMenuItem(value: 'privacy', child: Text(l10n.menuPrivacyPolicy)),
            PopupMenuItem(value: 'terms', child: Text(l10n.menuTermsOfUse)),
            PopupMenuItem(value: 'licences', child: Text(l10n.menuOpenSourceLicences)),
          ],
          onSelected: (value) {
            switch (value) {
              case 'language':
                showLanguagePicker(
                  context,
                  currentLocale: widget.locale,
                  onSelected: widget.onLocaleChanged,
                );
              case 'about':
                Navigator.of(context).push(AboutPage.route());
              case 'privacy':
                Navigator.of(context).push(LegalPage.route(LegalContent.privacy));
              case 'terms':
                Navigator.of(context).push(LegalPage.route(LegalContent.terms));
              case 'licences':
                showLicensePage(
                  context: context,
                  applicationName: AppInfo.name,
                  applicationVersion: AppInfo.versionLabel,
                  applicationLegalese:
                      '${AppInfo.copyright}\nReleased under the ${AppInfo.licenseName}.',
                );
            }
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: AppLogo(markSize: 34, showTagline: true),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_outlined),
                    title: Text(l10n.drawerAllTools),
                    selected: _tool == null,
                    onTap: () {
                      Navigator.of(context).pop();
                      _selectTool(null);
                    },
                  ),
                  for (final category in ToolCategory.values) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 16, 6),
                      child: Text(
                        category.labelIn(context.appLocale).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    for (final tool in ToolRegistry.inCategory(category))
                      ListTile(
                        leading: Icon(tool.icon),
                        title: Text(tool.titleIn(context)),
                        subtitle: tool.status.isAvailable ? null : Text(l10n.drawerSoon),
                        selected: _tool?.id == tool.id,
                        onTap: () {
                          Navigator.of(context).pop();
                          _selectTool(tool);
                        },
                      ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(l10n.drawerAboutAndLegal),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(AboutPage.route());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationRailSidebar extends StatelessWidget {
  const _NavigationRailSidebar({
    required this.tools,
    required this.selected,
    required this.extended,
    required this.onSelect,
  });

  final List<ToolDefinition> tools;
  final ToolDefinition? selected;
  final bool extended;
  final ValueChanged<ToolDefinition?> onSelect;

  @override
  Widget build(BuildContext context) {
    // Index 0 is the home gallery; tools follow in registry order.
    final index = selected == null ? 0 : tools.indexWhere((tool) => tool.id == selected!.id) + 1;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height - kToolbarHeight - 1,
        ),
        child: IntrinsicHeight(
          child: NavigationRail(
            extended: extended,
            selectedIndex: index < 0 ? 0 : index,
            groupAlignment: -1,
            labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            onDestinationSelected: (value) => onSelect(value == 0 ? null : tools[value - 1]),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.grid_view_outlined),
                selectedIcon: const Icon(Icons.grid_view_rounded),
                label: Text(l10n.navRailTools),
              ),
              for (final tool in tools)
                NavigationRailDestination(
                  icon: Icon(tool.icon),
                  label: Text(_shortLabel(context, tool), textAlign: TextAlign.center),
                  disabled: false,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rail labels have very little room, so English gets a shortened label per
  /// tool. Every other locale uses the full translated title instead of a
  /// second, separately maintained set of abbreviations per language — the
  /// rail wraps rather than breaking.
  static String _shortLabel(BuildContext context, ToolDefinition tool) {
    final title = tool.titleIn(context);
    if (context.appLocale != AppLocale.en) return title;
    return _railShortLabelsEnglish[tool.id] ?? title;
  }

  static const Map<String, String> _railShortLabelsEnglish = <String, String>{
    'photo-compose': 'Compose',
    'images-to-pdf': 'To PDF',
    'pdf-merge': 'Merge',
    'pdf-split': 'Split',
    'pdf-to-images': 'To images',
    'image-resize': 'Resize',
    'pdf-organise': 'Organise',
    'watermark': 'Watermark',
  };
}
