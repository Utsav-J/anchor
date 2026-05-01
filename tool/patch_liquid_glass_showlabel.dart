// ignore_for_file: avoid_print

import 'dart:io';

/// flutter_liquid_glass_plus 0.0.7 omits [showLabel] when building [_BottomBarTab]
/// in expanded mode, so [LGBottomBar.showLabel] has no effect. Run after `dart pub get`
/// if labels reappear:
///
/// ```sh
/// dart run tool/patch_liquid_glass_showlabel.dart
/// ```
///
/// Applies a one-line fix to the dependency in the pub cache.
void main() {
  final configFile = File(
    '${Directory.current.path}${Platform.pathSeparator}.dart_tool'
    '${Platform.pathSeparator}package_config.json',
  );
  if (!configFile.existsSync()) {
    stderr.writeln('Run from project root (no .dart_tool/package_config.json).');
    exit(1);
  }
  final raw = configFile.readAsStringSync();
  final match = RegExp(
    r'"name"\s*:\s*"flutter_liquid_glass_plus"\s*,\s*"rootUri"\s*:\s*"([^"]+)"',
  ).firstMatch(raw);
  if (match == null) {
    stderr.writeln('flutter_liquid_glass_plus not in package_config.');
    exit(1);
  }

  Uri rootUri = Uri.parse(match.group(1)!);
  if (!rootUri.isAbsolute) rootUri = Uri.file(match.group(1)!);

  final path = rootUri.toFilePath() +
      Platform.pathSeparator +
      ['lib', 'surfaces', 'liquid_glass_bottom_bar.dart'].join(Platform.pathSeparator);
  final f = File(path);
  if (!f.existsSync()) {
    stderr.writeln('Expected file missing: $path');
    exit(1);
  }

  var body = f.readAsStringSync();
  if (body.contains('onTabSelected(i),\n                  showLabel: widget.showLabel')) {
    print('Already patched.');
    exit(0);
  }

  const oldSnippet = '''                  onTap: () => widget.onTabSelected(i),
                ),
              ),
            ),''';

  const newSnippet = '''                  onTap: () => widget.onTabSelected(i),
                  showLabel: widget.showLabel,
                ),
              ),
            ),''';

  if (!body.contains(oldSnippet)) {
    stderr.writeln('Patch mismatch — package contents may have changed.');
    exit(1);
  }

  body = body.replaceFirst(oldSnippet, newSnippet);
  f.writeAsStringSync(body);
  print('Patched flutter_liquid_glass_plus expanded tab bar (showLabel).');
}
