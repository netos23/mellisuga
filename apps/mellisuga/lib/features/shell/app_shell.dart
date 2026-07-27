import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/tools/tool_definition.dart';
import '../../core/tools/tool_registry.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/responsive.dart';
import '../home/home_page.dart';
import '../legal/about_page.dart';
import '../legal/legal_content.dart';
import '../legal/legal_page.dart';

/// The application frame: branding, tool navigation and theme control.
///
/// Tools are swapped in place rather than pushed as routes, and their state
/// lives above this widget, so switching tools — or stepping out to read the
/// privacy policy — never discards work in progress.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.themeMode, required this.onThemeModeChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// `null` means the home gallery is showing.
  ToolDefinition? _tool;

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
                  onSelect: (tool) => setState(() => _tool = tool),
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
      return HomePage(onOpenTool: (tool) => setState(() => _tool = tool));
    }
    return ToolRegistry.buildScreen(context, tool);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ScreenSize screen) {
    final tool = _tool;
    return AppBar(
      title: Row(
        children: [
          if (!screen.isCompact || tool == null)
            InkWell(
              onTap: () => setState(() => _tool = null),
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
                tool.title,
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
            ThemeMode.light => 'Switch to dark theme',
            ThemeMode.dark => 'Use the system theme',
            ThemeMode.system => 'Switch to light theme',
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
          tooltip: 'About and legal',
          icon: const Icon(Icons.more_vert_rounded),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'about', child: Text('About Mellisuga')),
            PopupMenuItem(value: 'privacy', child: Text('Privacy Policy')),
            PopupMenuItem(value: 'terms', child: Text('Terms of Use')),
            PopupMenuItem(value: 'licences', child: Text('Open source licences')),
          ],
          onSelected: (value) {
            switch (value) {
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
                    title: const Text('All tools'),
                    selected: _tool == null,
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() => _tool = null);
                    },
                  ),
                  for (final category in ToolCategory.values) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 16, 6),
                      child: Text(
                        category.label.toUpperCase(),
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
                        title: Text(tool.title),
                        subtitle: tool.status.isAvailable ? null : const Text('Soon'),
                        selected: _tool?.id == tool.id,
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() => _tool = tool);
                        },
                      ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About & legal'),
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
              const NavigationRailDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: Text('Tools'),
              ),
              for (final tool in tools)
                NavigationRailDestination(
                  icon: Icon(tool.icon),
                  label: Text(_shortLabel(tool), textAlign: TextAlign.center),
                  disabled: false,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rail labels have very little room, so long tool names are shortened.
  static String _shortLabel(ToolDefinition tool) => switch (tool.id) {
    'photo-compose' => 'Compose',
    'images-to-pdf' => 'To PDF',
    'pdf-merge' => 'Merge',
    'pdf-split' => 'Split',
    'pdf-to-images' => 'To images',
    'image-resize' => 'Resize',
    'pdf-organise' => 'Organise',
    'watermark' => 'Watermark',
    _ => tool.title,
  };
}
