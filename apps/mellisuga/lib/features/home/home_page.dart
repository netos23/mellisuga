import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/tools/tool_definition.dart';
import '../../core/tools/tool_registry.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/responsive.dart';

/// The tool gallery: every utility the app offers, grouped by category.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenTool});

  final ValueChanged<ToolDefinition> onOpenTool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: ReadableWidth(
        maxWidth: 1080,
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLogoBadge(size: 64),
            const SizedBox(height: 22),
            Text(
              AppInfo.tagline,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Text(
                AppInfo.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 36),
            for (final category in ToolCategory.values) ...[
              _CategoryHeader(category: category),
              const SizedBox(height: 14),
              _ToolGrid(tools: ToolRegistry.inCategory(category), onOpenTool: onOpenTool),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category});

  final ToolCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(category.icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          category.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _ToolGrid extends StatelessWidget {
  const _ToolGrid({required this.tools, required this.onOpenTool});

  final List<ToolDefinition> tools;
  final ValueChanged<ToolDefinition> onOpenTool;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth) {
          >= 900 => 3,
          >= 560 => 2,
          _ => 1,
        };
        const gap = 14.0;
        final cardWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tool in tools)
              SizedBox(
                width: cardWidth,
                child: _ToolCard(tool: tool, onTap: () => onOpenTool(tool)),
              ),
          ],
        );
      },
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool, required this.onTap});

  final ToolDefinition tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final available = tool.status.isAvailable;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: available ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      tool.icon,
                      size: 20,
                      color: available ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (!available)
                    Text(
                      'Soon',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                tool.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: available ? null : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tool.summary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
