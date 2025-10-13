import 'package:flutter/material.dart';
import '../utils/export_utils.dart';
import 'success_export_screen.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  bool _isExporting = false;

  // Tambahan filter
  String _selectedRange = '7 hari terakhir';
  String _selectedType = 'Semua';
  String? _selectedCategory;
  String _selectedFormat = 'PDF';
  DateTime? _selectedDate = DateTime.now();

  // Dummy list kategori
  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Entertainment'
  ];

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      if (_selectedFormat == 'PDF') {
        await ExportPdf.exportAll();
      } else {
        await ExportCsv.exportAll();
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SuccessExportScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal export: $e')),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Export',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFEFFFEF),
              child: Icon(Icons.person, color: Colors.black87),
            ),
          ),
        ],
      ),
      body: _isExporting
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF34C759)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Pilih Rentang Waktu"),
                  _buildDatePicker(context),
                  const SizedBox(height: 8),
                  _buildRangeButtons(),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Filter Berdasarkan Tipe"),
                  _buildTypeButtons(),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Filter Berdasarkan Kategori"),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Pilih Format"),
                  _buildFormatButtons(),
                  const SizedBox(height: 32),

                  _buildExportButton(),
                ],
              ),
            ),
    );
  }

  // ======================== UI Components ==========================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selectedDate != null
                  ? "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}"
                  : "Pilih Tanggal",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined,
                color: Colors.black54, size: 20),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRangeButtons() {
    final ranges = ['7 hari terakhir', 'Bulan Ini', 'Semua'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ranges.map((r) {
        final isActive = _selectedRange == r;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedRange = r),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isActive ? const Color(0xFFDFFFE2) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  r,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive
                        ? const Color(0xFF34C759)
                        : Colors.grey.shade700,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeButtons() {
    final types = ['Income', 'Expense', 'Semua'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: types.map((t) {
        final isActive = _selectedType == t;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = t),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isActive ? const Color(0xFFDFFFE2) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  t,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive
                        ? const Color(0xFF34C759)
                        : Colors.grey.shade700,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          hint: const Text('Category', style: TextStyle(color: Colors.grey)),
          isExpanded: true,
          items: _categories
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
        ),
      ),
    );
  }

  Widget _buildFormatButtons() {
    final formats = ['PDF', 'CSV'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: formats.map((f) {
        final isActive = _selectedFormat == f;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFormat = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: const Color(0xFF34C759).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF34C759)
                        : Colors.grey.shade300,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      f == 'PDF'
                          ? Icons.picture_as_pdf_rounded
                          : Icons.table_chart_rounded,
                      size: 36,
                      color: isActive
                          ? const Color(0xFF34C759)
                          : Colors.grey.shade500,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      f,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive
                            ? const Color(0xFF34C759)
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _exportData,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF34C759),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Export Data',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
