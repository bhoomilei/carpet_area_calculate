import 'package:flutter/material.dart';

void main() => runApp(CarpetApp());

class CarpetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carpet Area Calculator',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: CarpetHome(),
    );
  }
}

class CarpetHome extends StatefulWidget {
  @override
  _CarpetHomeState createState() => _CarpetHomeState();
}

class _CarpetHomeState extends State<CarpetHome> {
  final _bhkController = TextEditingController();
  final Map<String, TextEditingController> _controllers = {};

  String _result = "";

  // Parse input like "12 6 x 10 3" or "12 x 10"
  List<double> _parseDimension(String input) {
    if (input.trim().isEmpty) return [0, 0];
    try {
      var parts = input.toLowerCase().replaceAll("x", " ").split(" ");
      parts.removeWhere((p) => p.isEmpty);
      if (parts.length == 4) {
        int f1 = int.parse(parts[0]);
        int i1 = int.parse(parts[1]);
        int f2 = int.parse(parts[2]);
        int i2 = int.parse(parts[3]);
        return [f1 + i1 / 12.0, f2 + i2 / 12.0];
      } else if (parts.length == 2) {
        int f1 = int.parse(parts[0]);
        int f2 = int.parse(parts[1]);
        return [f1.toDouble(), f2.toDouble()];
      }
    } catch (_) {}
    return [0, 0];
  }

  void _calculate() {
    int bhk = int.tryParse(_bhkController.text) ?? 0;
    if (bhk < 2 || bhk > 4) {
      setState(() {
        _result = "⚠️ Please enter BHK as 2, 3, or 4.";
      });
      return;
    }

    Map<String, List<double>> rooms = {};
    Map<String, double> areas = {};

    // Common rooms
    List<String> common = [
      "Foyer",
      "Drawing Room",
      "Kitchen/Dining",
      "Store",
      "Utility",
      "Common Toilet"
    ];

    for (var room in common) {
      var dim = _parseDimension(_controllers[room]!.text);
      rooms[room] = dim;
      areas[room] = dim[0] * dim[1];
    }

    // Bedrooms + Toilets
    for (int i = 1; i <= bhk; i++) {
      var bed = _parseDimension(_controllers["Bedroom-$i"]!.text);
      rooms["Bedroom-$i"] = bed;
      areas["Bedroom-$i"] = bed[0] * bed[1];

      var toilet = _parseDimension(_controllers["Toilet-$i"]!.text);
      rooms["Toilet-$i"] = toilet;
      areas["Toilet-$i"] = toilet[0] * toilet[1];
    }

    // Balcony
    var balcony = _parseDimension(_controllers["Balcony"]!.text);
    rooms["Balcony"] = balcony;
    areas["Balcony"] = balcony[0] * balcony[1];

    // Carpet calculations
    double carpet = areas.entries
        .where((e) => e.key != "Balcony")
        .map((e) => e.value)
        .fold(0, (a, b) => a + b);

    double carpetWithBalcony =
        areas.values.fold(0, (a, b) => a + b);

    // Format result
    StringBuffer sb = StringBuffer();
    sb.writeln("📏 Room-wise Areas (sq.ft.):");
    areas.forEach((room, area) {
      if (area > 0) sb.writeln("• $room: ${area.toStringAsFixed(2)}");
    });
    sb.writeln("\n✅ Carpet Area (excl. balcony): ${carpet.toStringAsFixed(2)} sq.ft.");
    sb.writeln("✅ Carpet Area (incl. balcony): ${carpetWithBalcony.toStringAsFixed(2)} sq.ft.");

    setState(() {
      _result = sb.toString();
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    for (var r in [
      "Foyer",
      "Drawing Room",
      "Kitchen/Dining",
      "Store",
      "Utility",
      "Common Toilet",
      "Balcony",
      "Bedroom-1",
      "Toilet-1",
      "Bedroom-2",
      "Toilet-2",
      "Bedroom-3",
      "Toilet-3",
      "Bedroom-4",
      "Toilet-4",
    ]) {
      _controllers[r] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Carpet Area Calculator")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _bhkController,
              decoration: InputDecoration(labelText: "Enter BHK (2, 3, or 4)"),
              keyboardType: TextInputType.number,
            ),
            ..._controllers.entries.map((entry) => TextField(
                  controller: entry.value,
                  decoration: InputDecoration(
                      labelText: "Enter ${entry.key} size (e.g. 12 6 x 10 3)"),
                )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              child: Text("Calculate"),
            ),
            SizedBox(height: 20),
            Text(
              _result,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
