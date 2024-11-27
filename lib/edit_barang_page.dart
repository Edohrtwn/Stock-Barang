import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';

class EditBarangPage extends StatefulWidget {
  final Map<String, dynamic> barang;

  const EditBarangPage({super.key, required this.barang});

  @override
  // ignore: library_private_types_in_public_api
  _EditBarangPageState createState() => _EditBarangPageState();
}

class _EditBarangPageState extends State<EditBarangPage> {
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

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.barang['name'];
    _quantityController.text = widget.barang['quantity'].toString();
    _categorySelected = widget.barang['category'];
    _merkSelected = widget.barang['merk'];
    if (widget.barang['image'] != null) {
      _image = File(widget.barang['image']);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  void _saveBarang() async {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lengkapi semua field')),
      );
      return;
    }

    final updatedBarang = {
      'id': widget.barang['id'],
      'name': _nameController.text,
      'quantity': int.tryParse(_quantityController.text),
      'category': _categorySelected,
      'merk': _merkSelected,
      'image': _image?.path
    };

    await DatabaseHelper.instance.updateBarang(updatedBarang);
    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Menghindari overflow saat keyboard muncul
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Edit Barang'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? InteractiveViewer(
                          child: Image.file(_image!, fit: BoxFit.contain),
                        )
                      : const Center(
                          child: Text(
                            'Pilih Gambar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Kuantitas',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categorySelected,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownColor: Colors.black,
                onChanged: (value) => setState(() => _categorySelected = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _merkSelected,
                items: _merks.map((merk) {
                  return DropdownMenuItem(
                    value: merk,
                    child: Text(merk, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Merk',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownColor: Colors.black,
                onChanged: (value) => setState(() => _merkSelected = value),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveBarang,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16), // Tambahkan padding bawah agar konten tidak tertutup
            ],
          ),
        ),
      ),
    );
  }
}
