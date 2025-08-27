import 'package:json2dartgen/json2dartgen.dart';
import 'package:test/test.dart';

void main() {
  test('generate empty object', () {
    final jsonToDartGenerator = JsonToDartGenerator();

    final generated = jsonToDartGenerator.generate('Root', {"": null});

    expect(
      generated,
      'import \'package:json_annotation/json_annotation.dart\';\n'
      '\n'
      'part \'root.g.dart\';\n'
      '\n'
      '@JsonSerializable()\n'
      'class Root {\n'
      '  final dynamic ;\n'
      '  const Root({required this.});\n'
      '\n'
      '  Root copyWith({\n'
      '    dynamic? ,\n'
      '  }) {\n'
      '    return Root(\n'
      '      :  ?? this.,\n'
      '    );\n'
      '  }\n'
      '\n'
      '  factory Root.fromJson(Map<String, dynamic> json) =>\n'
      '      _\$RootFromJson(json);\n'
      '\n'
      '  Map<String, dynamic> toJson() => _\$RootToJson(this);\n'
      '}\n'
      '',
    );
  });

  test('generate object with int field', () {
    final generated = JsonToDartGenerator().generate('Root', {'field': 1});

    final expected =
        'import \'package:json_annotation/json_annotation.dart\';\n'
        '\n'
        'part \'root.g.dart\';\n'
        '\n'
        '@JsonSerializable()\n'
        'class Root {\n'
        '  final int field;\n'
        '  const Root({required this.field});\n'
        '\n'
        '  Root copyWith({\n'
        '    int? field,\n'
        '  }) {\n'
        '    return Root(\n'
        '      field: field ?? this.field,\n'
        '    );\n'
        '  }\n'
        '\n'
        '  factory Root.fromJson(Map<String, dynamic> json) =>\n'
        '      _\$RootFromJson(json);\n'
        '\n'
        '  Map<String, dynamic> toJson() => _\$RootToJson(this);\n'
        '}\n'
        '';

    expect(generated, expected);
  });

  test('generate object with nested object', () {
    final generated = JsonToDartGenerator().generate('Root', {
      'Root': {'field': 1},
    });

    final expectedMap =
        'import \'package:json_annotation/json_annotation.dart\';\n'
        '\n'
        'part \'root.g.dart\';\n'
        '\n'
        '@JsonSerializable()\n'
        'class Root {\n'
        '  final Root Root;\n'
        '  const Root({required this.Root});\n'
        '\n'
        '  Root copyWith({\n'
        '    Root? Root,\n'
        '  }) {\n'
        '    return Root(\n'
        '      Root: Root ?? this.Root,\n'
        '    );\n'
        '  }\n'
        '\n'
        '  factory Root.fromJson(Map<String, dynamic> json) =>\n'
        '      _\$RootFromJson(json);\n'
        '\n'
        '  Map<String, dynamic> toJson() => _\$RootToJson(this);\n'
        '}\n'
        '';

    expect(generated, expectedMap);
  });
}
