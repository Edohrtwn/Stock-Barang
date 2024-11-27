import 'dart:io';
import 'package:flutter/material.dart';
import 'add_barang_page.dart';
import 'edit_barang_page.dart';
import 'database_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Barang',
      theme: ThemeData.dark(), // Mengatur tema menjadi gelap
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> _barangList = [];
  List<Map<String, dynamic>> _allBarangList = [];
  String? _selectedCategory;
  String? _selectedMerk;

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
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final data = await DatabaseHelper.instance.queryAllBarang();
    setState(() {
      _barangList = data;
      _allBarangList = data;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedMerk = null;
      _barangList = List.from(_allBarangList);
    });
    _searchFocusNode.unfocus();
  }

  void _searchItems(String query) {
    final data = _allBarangList.where((item) {
      return item['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _barangList = data;
    });

    _searchFocusNode.unfocus(); // Hapus fokus setelah pencarian
  }

  void _filterItems() {
    setState(() {
      _barangList = _allBarangList.where((item) {
        final matchesCategory =
            _selectedCategory == null || item['category'] == _selectedCategory;
        final matchesMerk =
            _selectedMerk == null || item['merk'] == _selectedMerk;
        return matchesCategory && matchesMerk;
      }).toList();
    });
    _sortBarangByStock();
  }

  void _sortBarangByStock() {
    _barangList.sort((a, b) => a['quantity'].compareTo(b['quantity']));
  }

  Future<void> _editBarang(Map<String, dynamic> barang) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBarangPage(barang: barang),
      ),
    );
    if (result == true) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Stock Barang'),
      ),
      body: GestureDetector(
        onTap: () => _searchFocusNode.unfocus(),
        child: RefreshIndicator(
          onRefresh: () async {
            _clearFilters();
            await _fetchData();
          },
          child: Container(
            color: Colors.black,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Cari Barang',
                      labelStyle: TextStyle(color: Colors.white),
                      suffixIcon: Icon(Icons.search, color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: _searchItems,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey,
                    ),
                    itemCount: _barangList.length,
                    itemBuilder: (context, index) {
                      final barang = _barangList[index];

                      Color stockColor;
                      if (barang['quantity'] >= 50) {
                        stockColor = Colors.green;
                      } else if (barang['quantity'] >= 20 &&
                          barang['quantity'] <= 49) {
                        stockColor = Colors.yellow;
                      } else {
                        stockColor = Colors.red;
                      }

                      return Dismissible(
                        key: Key(barang['id'].toString()),
                        background: Container(
                          color: const Color.fromARGB(255, 255, 246, 72),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            final confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.black,
                                  title: const Text('Konfirmasi Hapus',
                                      style: TextStyle(color: Colors.white)),
                                  content: const Text(
                                      'Apakah Anda yakin ingin menghapus barang ini?',
                                      style: TextStyle(color: Colors.white)),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Tidak',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Ya',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirmDelete == true) {
                              await DatabaseHelper.instance
                                  .deleteBarang(barang['id']);
                              _fetchData();
                            }
                            return confirmDelete;
                          } else {
                            _editBarang(barang);
                            return false;
                          }
                        },
                        child: ListTile(
                          leading: barang['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(barang['image']),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image,
                                      color: Colors.grey),
                                ),
                          title: Text(barang['name'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Merk: ${barang['merk']}',
                                  style: const TextStyle(color: Colors.grey)),
                              Text('Kategori: ${barang['category']}',
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          trailing: Text(
                            '${barang['quantity']}',
                            style: TextStyle(
                                color: stockColor, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Tambah',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'Filter',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBarangPage()),
            ).then((_) => _fetchData());
          } else if (index == 1) {
            _searchItems(_searchController.text);
          } else if (index == 2) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.black,
                  title: const Text('Filter Barang',
                      style: TextStyle(color: Colors.white)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedMerk,
                        items: _merks
                            .map((merk) => DropdownMenuItem(
                                  value: merk,
                                  child: Text(merk),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMerk = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Merk',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _filterItems();
                        Navigator.pop(context);
                      },
                      child: const Text('Terapkan',
                      style: TextStyle(color: Colors.green),),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
