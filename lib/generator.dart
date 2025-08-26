class JsonToDartGenerator {
  final Map<String, String> generatedClasses = {};

  String generate(String className, dynamic json, {bool useCamelCase = false}) {
    if (json is Map<String, dynamic>) {
      return _generateClass(className, json, useCamelCase: useCamelCase);
    } else if (json is List) {
      return generate(
        className,
        json.isNotEmpty ? json.first : {},
        useCamelCase: useCamelCase,
      );
    } else {
      throw ArgumentError('Root must be object or array');
    }
  }

  Map<String, String> generateModels(
    Map<String, dynamic> json, {
    bool useCamelCase = false,
  }) {
    generatedClasses.clear();

    _generateClass('Root', json, useCamelCase: useCamelCase);

    return Map.of(generatedClasses); // return copy
  }

  String _generateClass(
    String className,
    Map<String, dynamic> json, {
    required bool useCamelCase,
  }) {
    if (generatedClasses.containsKey(className)) {
      return generatedClasses[className]!;
    }

    final buffer = StringBuffer();

    buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
    buffer.writeln('');
    buffer.writeln("part '${className.toLowerCase()}.g.dart';");
    buffer.writeln('');
    buffer.writeln('@JsonSerializable()');
    buffer.writeln('class $className {');

    json.forEach((key, value) {
      final dartName = useCamelCase ? _toCamelCase(key) : key;
      final type = _inferType(dartName, value);

      if (dartName != key) {
        buffer.writeln("  @JsonKey(name: '$key')");
      }
      buffer.writeln('  final $type $dartName;');
    });

    // constructor
    buffer.write('  const $className({');
    buffer.write(
      json.keys
          .map((k) => 'required this.${useCamelCase ? _toCamelCase(k) : k}')
          .join(', '),
    );
    buffer.writeln('});');

    // copyWith
    buffer.writeln('');
    buffer.writeln('  $className copyWith({');
    json.forEach((key, value) {
      final dartName = useCamelCase ? _toCamelCase(key) : key;
      final type = _inferType(dartName, value);
      buffer.writeln('    $type? $dartName,');
    });
    buffer.writeln('  }) {');
    buffer.writeln('    return $className(');
    json.forEach((key, value) {
      final dartName = useCamelCase ? _toCamelCase(key) : key;
      buffer.writeln('      $dartName: $dartName ?? this.$dartName,');
    });
    buffer.writeln('    );');
    buffer.writeln('  }');

    // fromJson / toJson
    buffer.writeln('');
    buffer.writeln(
      '  factory $className.fromJson(Map<String, dynamic> json) =>',
    );
    buffer.writeln('      _\$${className}FromJson(json);');
    buffer.writeln('');
    buffer.writeln(
      '  Map<String, dynamic> toJson() => _\$${className}ToJson(this);',
    );

    buffer.writeln('}');

    final code = buffer.toString();
    generatedClasses[className] = code;

    // nested
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        generate(_capitalize(key), value, useCamelCase: useCamelCase);
      } else if (value is List && value.isNotEmpty && value.first is Map) {
        generate(
          _capitalize(key),
          value.first as Map<String, dynamic>,
          useCamelCase: useCamelCase,
        );
      }
    });

    return code;
  }

  /// Converts snake_case → camelCase
  String _toCamelCase(String s) {
    if (!s.contains('_')) return s;
    final parts = s.split('_');
    return parts.first + parts.skip(1).map((w) => _capitalize(w)).join();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _inferType(String key, dynamic value) {
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is String) return 'String';
    if (value is Map<String, dynamic>) return _capitalize(key);
    if (value is List && value.isNotEmpty) {
      final innerType = _inferType(key, value.first);
      return 'List<$innerType>';
    }
    return 'dynamic';
  }
}
