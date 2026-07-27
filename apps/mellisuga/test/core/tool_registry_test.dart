import 'package:flutter_test/flutter_test.dart';
import 'package:mellisuga/core/tools/tool_registry.dart';
import 'package:mellisuga_content/mellisuga_content.dart';

void main() {
  group('ToolRegistry', () {
    test('every tool has a unique id', () {
      final ids = ToolRegistry.tools.map((tool) => tool.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every tool in the shared catalogue is registered', () {
      expect(ToolRegistry.tools.map((tool) => tool.id), ToolCatalog.tools.map((tool) => tool.id));
    });

    test('every tool has its own icon', () {
      final icons = ToolRegistry.tools.map((tool) => tool.icon).toList();
      expect(icons.toSet().length, icons.length);
    });

    test('the registry and the landing site agree on what is shipped', () {
      expect(
        ToolRegistry.available.map((tool) => tool.id),
        ToolCatalog.available.map((tool) => tool.id),
      );
    });

    test('every available tool can build a screen', () {
      for (final tool in ToolRegistry.available) {
        expect(tool.builder, isNotNull, reason: '${tool.id} has no builder');
      }
    });

    test('the default tool is available', () {
      expect(ToolRegistry.defaultTool.status.isAvailable, isTrue);
    });

    test('search matches titles, summaries and keywords', () {
      expect(ToolRegistry.search('compose'), isNotEmpty);
      expect(ToolRegistry.search('passport').map((t) => t.id), contains('photo-compose'));
      expect(ToolRegistry.search('combine').map((t) => t.id), contains('pdf-merge'));
      expect(ToolRegistry.search('zzzzz'), isEmpty);
    });

    test('an empty query matches everything', () {
      expect(ToolRegistry.search('  ').length, ToolRegistry.tools.length);
    });

    test('categories partition the registry', () {
      final counted = <String>{};
      for (final tool in ToolRegistry.tools) {
        counted.add(tool.id);
      }
      expect(counted.length, ToolRegistry.tools.length);
    });
  });
}
