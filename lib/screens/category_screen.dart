import 'package:flutter/material.dart';
import '../services/expense_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _addC = TextEditingController();
  final _renameC = TextEditingController();
  String? _selectedId;

  @override
  void dispose() {
    _addC.dispose();
    _renameC.dispose();
    super.dispose();
  }

  void _showDetailPopup(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Category Details'),
        content: Text('Name: $name'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditPopup(String id, String oldName) {
    _renameC.text = oldName;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Category'),
        content: TextField(
          controller: _renameC,
          decoration: const InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final svc = ExpenseService.instance;
              final ok = svc.renameCategory(id, _renameC.text);
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama tidak valid / sudah ada')),
                );
              } else {
                Navigator.pop(context);
                _renameC.clear();
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;
    final cats = svc.categories;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Category',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.person, color: Colors.green),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cats.length,
                itemBuilder: (context, i) {
                  final c = cats[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        c.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            final ok = svc.deleteCategory(c.id);
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Tidak bisa hapus. Kategori sedang dipakai.',
                                  ),
                                ),
                              );
                            } else {
                              setState(() {});
                            }
                          } else if (value == 'edit') {
                            _showEditPopup(c.id, c.name);
                          } else if (value == 'details') {
                            _showDetailPopup(c.name);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'details',
                            child: Text('Details'),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addC,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Name',
                filled: true,
                fillColor: const Color(0xFFF5F8FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                final ok = svc.addCategory(_addC.text);
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama tidak valid / sudah ada'),
                    ),
                  );
                } else {
                  _addC.clear();
                  setState(() {});
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Add Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../services/expense_service.dart';

// class CategoryScreen extends StatefulWidget {
//   const CategoryScreen({super.key});

//   @override
//   State<CategoryScreen> createState() => _CategoryScreenState();
// }

// class _CategoryScreenState extends State<CategoryScreen> {
//   final _addC = TextEditingController();
//   final _renameC = TextEditingController();
//   String? _selectedId;

//   @override
//   void dispose() {
//     _addC.dispose();
//     _renameC.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final svc = ExpenseService.instance;
//     final cats = svc.categories;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Kelola Kategori')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.separated(
//                 itemCount: cats.length,
//                 separatorBuilder: (_, __) => const Divider(height: 1),
//                 itemBuilder: (_, i) {
//                   final c = cats[i];
//                   return ListTile(
//                     title: Text(c.name),
//                     selected: _selectedId == c.id,
//                     onTap: () => setState(() => _selectedId = c.id),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.delete),
//                       onPressed: () {
//                         final ok = svc.deleteCategory(c.id);
//                         if (!ok) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Tidak bisa hapus. Kategori sedang dipakai.')),
//                           );
//                         } else {
//                           setState(() {});
//                         }
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _addC,
//                     decoration: const InputDecoration(
//                       labelText: 'Nama kategori baru',
//                       isDense: true,
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     final ok = svc.addCategory(_addC.text);
//                     if (!ok) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Nama tidak valid / sudah ada')),
//                       );
//                     } else {
//                       _addC.clear();
//                       setState(() {});
//                     }
//                   },
//                   child: const Text('Tambah'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _renameC,
//                     decoration: InputDecoration(
//                       labelText: _selectedId == null ? 'Pilih kategori dulu' : 'Nama baru',
//                       isDense: true,
//                       border: const OutlineInputBorder(),
//                     ),
//                     enabled: _selectedId != null,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: _selectedId == null
//                       ? null
//                       : () {
//                           final ok = svc.renameCategory(_selectedId!, _renameC.text);
//                           if (!ok) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('Nama tidak valid / sudah ada')),
//                             );
//                           } else {
//                             _renameC.clear();
//                             setState(() {});
//                           }
//                         },
//                   child: const Text('Rename'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }