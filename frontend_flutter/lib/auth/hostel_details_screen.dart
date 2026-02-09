import 'package:flutter/material.dart';

import '../services/student_service.dart';
import 'biometric_register_screen.dart'; 

class HostelDetailsScreen extends StatefulWidget {
  final String rollNo;

  const HostelDetailsScreen({
    super.key,
    required this.rollNo,
  });

  @override
  State<HostelDetailsScreen> createState() => _HostelDetailsScreenState();
}

class _HostelDetailsScreenState extends State<HostelDetailsScreen> {
  String? selectedHostel;
  String? selectedBlock;
  final TextEditingController roomController = TextEditingController();
  bool isLoading = false;

  final Map<String, List<String>> hostelBlockMap = {
    "Aryabhatta Hostel": ["Block A", "Block B"],
    "Vivekananda Hostel": ["Block C", "Block D"],
  };

  List<String> get hostels => hostelBlockMap.keys.toList();
  List<String> get blocks =>
      selectedHostel != null ? hostelBlockMap[selectedHostel]! : [];

  Future<void> _submitHostelDetails() async {
    if (selectedHostel == null ||
        selectedBlock == null ||
        roomController.text.trim().isEmpty) {
      _showError("All fields are required");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await StudentService.assignHostel(
        rollNo: widget.rollNo,
        hostel: selectedHostel!,
        block: selectedBlock!,
        roomNumber: roomController.text.trim(),
      );

      if (result["status"] == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BiometricRegisterScreen(
              rollNo: widget.rollNo,
            ),
          ),
        );
      } else {
        _showError(result["body"]["error"] ?? "Hostel assignment failed");
      }
    } catch (e) {
      _showError("Network error. Try again.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hostel Allocation"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hostel Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              value: selectedHostel,
              items: hostels
                  .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  selectedHostel = v;
                  selectedBlock = null;
                });
              },
              decoration: const InputDecoration(
                labelText: "Hostel",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedBlock,
              items: blocks
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged:
                  selectedHostel == null ? null : (v) => setState(() => selectedBlock = v),
              decoration: const InputDecoration(
                labelText: "Block",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: roomController,
              decoration: const InputDecoration(
                labelText: "Room Number",
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitHostelDetails,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("CONFIRM HOSTEL DETAILS"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
