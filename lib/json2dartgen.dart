/// A utility class that generates Dart model classes from JSON data.
///
/// This class provides functionality to convert JSON data into strongly-typed
/// Dart classes with proper serialization/deserialization support using
/// `json_annotation` package.
///
/// Features:
/// - Supports nested objects and arrays
/// - Handles both camelCase and snake_case property names
/// - Generates `copyWith` methods for immutable classes
/// - Supports custom JSON key names via `@JsonKey` annotations
/// - Handles basic Dart types (int, double, bool, String) and custom objects
class JsonToDartGenerator {
  /// Cache of generated class definitions to avoid duplicates
  final Map<String, String> generatedClasses = {};

  /// Generates a Dart class from JSON data.
  ///
  /// [className] The name of the generated Dart class
  /// [json] The JSON data to generate the class from (can be Map or List)
  /// [useCamelCase] Whether to convert snake_case property names to camelCase
  /// [useNullableCopyWith] Whether to generate nullable copyWith method with ability to null values
  ///
  /// Returns the generated Dart class as a String
  ///
  /// Throws [ArgumentError] if the root JSON is not an object or array
  String generate(
    String className,
    dynamic json, {
    bool useCamelCase = false,
    bool useNullableCopyWith = false,
  }) {
    if (json == null) {
      throw ArgumentError('JSON data cannot be null');
    }
    if (json is Map<String, dynamic>) {
      return _generateClass(
        className,
        json,
        useCamelCase: useCamelCase,
        useNullableCopyWith: useNullableCopyWith,
      );
    } else if (json is List) {
      return generate(
        className,
        json.isNotEmpty ? json.first : {},
        useCamelCase: useCamelCase,
        useNullableCopyWith: useNullableCopyWith,
      );
    } else {
      throw ArgumentError('Root must be object or array');
    }
  }

  /// Internal method to generate a single class definition
  String _generateClass(
    String className,
    Map<String, dynamic> json, {
    required bool useCamelCase,
    bool useNullableCopyWith = false,
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
    _writeToBufferConstructor(buffer, className, json, useCamelCase);

    // copyWith
    _writeToBufferCopyWith(
      buffer,
      className,
      json,
      useCamelCase,
      useNullableCopyWith: useNullableCopyWith,
    );

    // fromJson / toJson
    _writeToBufferToJsonFromJson(buffer, className);

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

  void _writeToBufferConstructor(
    StringBuffer buffer,
    String className,
    Map<String, dynamic> json,
    bool useCamelCase,
  ) {
    buffer.write('  const $className({');
    buffer.write(
      json.keys
          .map((k) => 'required this.${useCamelCase ? _toCamelCase(k) : k}')
          .join(', '),
    );
    buffer.writeln('});');
  }

  void _writeToBufferCopyWith(
    StringBuffer buffer,
    String className,
    Map<String, dynamic> json,
    bool useCamelCase, {
    bool useNullableCopyWith = false,
  }) {
    buffer.writeln('');

    if (useNullableCopyWith) {
      // Add sentinel
      buffer.writeln('  static const _sentinel = Object();');
      buffer.writeln('');

      buffer.writeln('  $className copyWith({');
      json.forEach((key, value) {
        final dartName = useCamelCase ? _toCamelCase(key) : key;
        buffer.writeln('    Object? $dartName = _sentinel,');
      });
      buffer.writeln('  }) {');
      buffer.writeln('    return $className(');

      json.forEach((key, value) {
        final dartName = useCamelCase ? _toCamelCase(key) : key;
        final type = _inferType(dartName, value);
        buffer.writeln(
          '      $dartName: identical($dartName, _sentinel) ? this.$dartName : $dartName as $type,',
        );
      });

      buffer.writeln('    );');
      buffer.writeln('  }');
    } else {
      // Default style
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
    }
  }

  void _writeToBufferToJsonFromJson(StringBuffer buffer, String className) {
    buffer.writeln('');
    buffer.writeln(
      '  factory $className.fromJson(Map<String, dynamic> json) =>',
    );
    buffer.writeln('      _\$${className}FromJson(json);');
    buffer.writeln('');
    buffer.writeln(
      '  Map<String, dynamic> toJson() => _\$${className}ToJson(this);',
    );
  }

  /// Converts snake_case to camelCase
  ///
  /// Example: 'user_name' → 'userName'
  String _toCamelCase(String s) {
    if (!s.contains('_')) return s;
    final parts = s.split('_');
    return parts.first + parts.skip(1).map((w) => _capitalize(w)).join();
  }

  /// Capitalizes the first letter of a string
  ///
  /// Example: 'user' → 'User'
  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// Infers the appropriate Dart type for a given JSON value
  ///
  /// Handles basic types and recursively processes nested objects and lists
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
