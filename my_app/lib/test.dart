// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class CategoriesTestPage extends StatefulWidget {
//   const CategoriesTestPage({super.key});

//   @override
//   State<CategoriesTestPage> createState() => _CategoriesTestPageState();
// }

// class _CategoriesTestPageState extends State<CategoriesTestPage> {
//   bool isLoading = true;
//   Map<String, dynamic>? selectedCategory;
//   Map<String, List<Map<String, dynamic>>> groupedCategories = {};

//   final String baseUrl = 'http://192.168.48.106:1337'; // Your IP

//   @override
//   void initState() {
//     super.initState();
//     fetchCategories();
//   }

//   Future<void> fetchCategories() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/api/categories'));

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body)['data'];

//         final Map<String, List<Map<String, dynamic>>> grouped = {};

//         for (var item in data) {
//           final name = item['name'] ?? 'Untitled';
//           final group = item['description'] ?? 'Other';
//           final id = item['id'];

//           if (!grouped.containsKey(group)) {
//             grouped[group] = [];
//           }

//           grouped[group]!.add({'name': name, 'id': id});
//         }

//         setState(() {
//           groupedCategories = grouped;
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Failed to load categories: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text("Select a Category"),
//         backgroundColor: Colors.blue,
//       ),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ...groupedCategories.entries.map((entry) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 20),
//                           Text(
//                             entry.key,
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           ...entry.value.map(
//                             (cat) => _buildCategoryCard(cat['name'], cat['id']),
//                           ),
//                         ],
//                       );
//                     }).toList(),
//                     const SizedBox(height: 30),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.arrow_forward),
//                       label: const Text("Continue"),
//                       onPressed:
//                           selectedCategory != null
//                               ? () {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       "Selected: ${selectedCategory!['name']} (ID: ${selectedCategory!['id']})",
//                                     ),
//                                   ),
//                                 );
//                               }
//                               : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         minimumSize: const Size(double.infinity, 50),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }

//   Widget _buildCategoryCard(String? name, int id) {
//     final bool isSelected = selectedCategory?['id'] == id;

//     return InkWell(
//       onTap: () {
//         setState(() {
//           selectedCategory = {'name': name, 'id': id};
//         });
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[100] : Colors.white,
//           border: Border.all(
//             color: isSelected ? Colors.blue : Colors.grey.shade300,
//             width: 1.5,
//           ),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             if (isSelected)
//               BoxShadow(
//                 color: Colors.blue.withOpacity(0.2),
//                 blurRadius: 6,
//                 offset: const Offset(0, 3),
//               ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.folder_copy_outlined,
//               color: isSelected ? Colors.blue : Colors.grey,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 name ?? 'Untitled',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: isSelected ? Colors.blue[900] : Colors.black87,
//                 ),
//               ),
//             ),
//             if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
//           ],
//         ),
//       ),
//     );
//   }
// }
