import 'package:flutter/material.dart';

class FilterPreset {
  final String name;
  final List<double> matrix;
  final Color previewColor;

  const FilterPreset({
    required this.name,
    required this.matrix,
    required this.previewColor,
  });
}

class FilterLibrary {
  static const List<double> NO_FILTER = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Professional Clarendon Style (High Contrast, Vivid)
  static const List<double> CLARENDON = [
    1.2, 0, 0, 0, 0,
    0, 1.1, 0, 0, 0,
    0, 0, 1.4, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Professional Gingham (Vintage, Warm, Fade)
  static const List<double> GINGHAM = [
    0.9, 0, 0, 0, 30,
    0, 0.9, 0, 0, 10,
    0, 0, 0.9, 0, 20,
    0, 0, 0, 1, 0,
  ];

  // Professional Moon (B&W High Contrast)
  static const List<double> MOON = [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Professional Lark (Cool, Desaturated)
  static const List<double> LARK = [
    0.9, 0, 0, 0, 10,
    0, 1, 0, 0, 10,
    0, 0, 1.2, 0, 10,
    0, 0, 0, 1, 0,
  ];

  // Professional Juno (Warm, Bright)
  static const List<double> JUNO = [
    1.1, 0, 0, 0, 20,
    0, 1, 0, 0, 10,
    0, 0, 0.9, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Professional Aura (Dreamy, Soft)
  static const List<double> AURA = [
    1, 0, 0, 0, 10,
    0, 0.9, 0, 0, 10,
    0, 0, 1.1, 0, 20,
    0, 0, 0, 1, 0,
  ];

  static const List<FilterPreset> presets = [
    FilterPreset(name: "Normal", matrix: NO_FILTER, previewColor: Colors.grey),
    FilterPreset(name: "Clarendon", matrix: CLARENDON, previewColor: Colors.blueAccent),
    FilterPreset(name: "Gingham", matrix: GINGHAM, previewColor: Colors.brown),
    FilterPreset(name: "Moon", matrix: MOON, previewColor: Colors.black),
    FilterPreset(name: "Lark", matrix: LARK, previewColor: Colors.cyan),
    FilterPreset(name: "Juno", matrix: JUNO, previewColor: Colors.orange),
    FilterPreset(name: "Aura", matrix: AURA, previewColor: Colors.purpleAccent),
  ];
}
