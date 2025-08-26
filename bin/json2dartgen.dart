import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:json2dartgen/json2dartgen.dart';

/// The entry point of the `json2dartgen` CLI tool.
///
/// This function parses the command line arguments and calls the
/// [JsonToDartGenerator.generateModels] method to generate Dart models from
/// JSON files.
///
/// The `arguments` parameter is a list of command line arguments passed to the
/// tool.
void main(List<String> arguments) {
  final parser = ArgParser()
    ..addFlag(
      'camel-case',
      abbr: 'c',
      negatable: false,
      help: 'Convert snake_case to camelCase field names',
    )
    ..addOption(
      'output-dir',
      abbr: 'o',
      help:
          'Output directory for generated .dart files. '
          'Defaults to current directory if not provided.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message.',
    );

  final argResults = parser.parse(arguments);

  if (argResults['help'] as bool) {
    print('JSON to Dart Model Generator');
    print('');
    print('Usage: dart run json2dartgen <input.json> [options]');
    print('');
    print(parser.usage);
    exit(0);
  }

  if (argResults.rest.isEmpty) {
    print('Error: No input file provided.');
    print('Use --help for usage information.');
    exit(1);
  }

  final inputFile = argResults.rest.first;
  final useCamelCase = argResults['camel-case'] as bool;
  final outputDir =
      argResults['output-dir'] as String? ?? Directory.current.path;

  final raw = File(inputFile).readAsStringSync();
  final jsonData = jsonDecode(raw);

  final classes = JsonToDartGenerator().generateModels(
    jsonData,
    useCamelCase: useCamelCase,
  );

  final dir = Directory(outputDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);

  for (final entry in classes.entries) {
    final fileName = '${entry.key.toLowerCase()}.dart';
    final outFile = File('${dir.path}/$fileName');
    outFile.writeAsStringSync(entry.value);
    print('Generated: ${outFile.path}');
  }

  print('\n✅ Generation complete.');
}
