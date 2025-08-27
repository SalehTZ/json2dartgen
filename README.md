# json2dartgen

[![pub package](https://img.shields.io/pub/v/json2dartgen.svg)](https://pub.dev/packages/json2dartgen)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A CLI tool to **generate Dart model classes from JSON**. Supports `json_serializable`, `copyWith`, and optional snake\_case → camelCase conversion.

---

## Features

* Automatically generate Dart classes from any JSON file
* `json_serializable` compatible (`fromJson` / `toJson`)
* Generates `copyWith` method
* Optional snake\_case → camelCase conversion
* Output as separate `.dart` files
* Configurable output directory
* CLI help included

---

## Getting Started

### Install

Activate globally via Dart:

```bash
dart pub global activate json2dartgen
```

---

### Usage

```bash
dart run json2dartgen <input.json> [options]
```

**Options:**

| Flag               | Description                                                     |
| ------------------ | --------------------------------------------------------------- |
| `-c, --camel-case` | Convert snake\_case JSON keys to camelCase field names          |
| `-o, --output-dir` | Output directory for `.dart` files (default: current directory) |
| `-h, --help`       | Show usage instructions                                         |

---

### Examples

Generate models in the current directory:

```bash
dart run json2dartgen api_response.json
```

Generate models with camelCase fields:

```bash
dart run json2dartgen api_response.json --camel-case
```

Generate models in a specific directory:

```bash
dart run json2dartgen api_response.json --camel-case --output-dir lib/models
```

---

### Generated Code Example

Input JSON:

```json
{
  "building_id": 1130,
  "floor_count": 5,
  "location_name": "North Wing"
}
```

Generated Dart model:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'root.g.dart';

@JsonSerializable()
class Root {
  @JsonKey(name: 'building_id')
  final int buildingId;

  @JsonKey(name: 'floor_count')
  final int floorCount;

  @JsonKey(name: 'location_name')
  final String locationName;

  const Root({
    required this.buildingId,
    required this.floorCount,
    required this.locationName,
  });

  Root copyWith({
    int? buildingId,
    int? floorCount,
    String? locationName,
  }) {
    return Root(
      buildingId: buildingId ?? this.buildingId,
      floorCount: floorCount ?? this.floorCount,
      locationName: locationName ?? this.locationName,
    );
  }

  factory Root.fromJson(Map<String, dynamic> json) => _$RootFromJson(json);
  Map<String, dynamic> toJson() => _$RootToJson(this);
}
```

---

### Notes

* Ensure `json_annotation` and `json_serializable` are in your `pubspec.yaml` dependencies for Flutter/Dart projects.
* Run `build_runner` to generate the `.g.dart` files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

### Author

**Saleh Talebizadeh**
[https://salehtz.ir](https://salehtz.ir)
