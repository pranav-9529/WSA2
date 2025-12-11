// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MaterialApp(home: ReportAreaPage()));
// }

// class ReportAreaPage extends StatefulWidget {
//   const ReportAreaPage({super.key});

//   @override
//   State<ReportAreaPage> createState() => _ReportAreaPageState();
// }

// class _ReportAreaPageState extends State<ReportAreaPage> {
//   final TextEditingController areaNameController = TextEditingController();
//   double lat = 0.0;
//   double lon = 0.0;
//   String color = "red"; // default

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Report Area")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: areaNameController,
//               decoration: const InputDecoration(labelText: "Area Name"),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: "Latitude"),
//               onChanged: (value) => lat = double.tryParse(value) ?? 0.0,
//             ),
//             TextField(
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: "Longitude"),
//               onChanged: (value) => lon = double.tryParse(value) ?? 0.0,
//             ),
//             const SizedBox(height: 16),
//             DropdownButton<String>(
//               value: color,
//               items: const [
//                 DropdownMenuItem(value: "red", child: Text("Red")),
//                 DropdownMenuItem(value: "green", child: Text("Green")),
//                 DropdownMenuItem(value: "blue", child: Text("Blue")),
//               ],
//               onChanged: (value) => setState(() => color = value!),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 // Call your API to save the area
//                 await reportAreaAPI(areaNameController.text, lat, lon, color);
//                 Navigator.pop(context);
//               },
//               child: const Text("Submit"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> reportAreaAPI(
//     String name,
//     double lat,
//     double lon,
//     String color,
//   ) async {
//     // Call your backend API here
//     // Example: POST {name, lat, lon, color}
//     print("API called: $name, $lat, $lon, $color");
//   }
// }
