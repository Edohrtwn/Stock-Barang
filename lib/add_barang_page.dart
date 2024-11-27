import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';

class AddBarangPage extends StatefulWidget {
  const AddBarangPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddBarangPageState createState() => _AddBarangPageState();
}

class _AddBarangPageState extends State<AddBarangPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String? _categorySelected;
  String? _merkSelected;
  File? _image;

  final List<String> _categories = [
    'Oli',
    'Spare part mesin',
    'Spare part CVT',
    'Ban',
    'Lampu',
    'Shock',
    'Variasi'
  ];
  final List<String> _merks = [
    'Honda',
    'Yamaha',
    'Suzuki',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addBarang() async {
    if (_nameController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _categorySelected != null &&
        _merkSelected != null &&
        _image != null) {
      await DatabaseHelper.instance.insertBarang({
        'name': _nameController.text,
        'quantity': int.parse(_quantityController.text),
        'category': _categorySelected,
        'merk': _merkSelected,
        'image': _image!.path,
      });
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Kembali ke halaman utama
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Menghindari overflow saat keyboard muncul
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Tambah Barang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image != null
                    ? InteractiveViewer(
                        child: Image.file(_image!, fit: BoxFit.contain),
                      )
                    : const Center(child: Text('Klik untuk memilih gambar')),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Kuantitas',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categorySelected,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() => _categorySelected = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _merkSelected,
              items: _merks.map((merk) {
                return DropdownMenuItem(
                  value: merk,
                  child: Text(merk),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Merk',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() => _merkSelected = value),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addBarang,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              child: const Text('Tambah Barang'),
            ),
            const SizedBox(height: 16), // Tambahkan padding bawah untuk ruang tambahan
          ],
        ),
      ),
    );
  }
}
