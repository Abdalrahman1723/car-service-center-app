import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportFilterWidget extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? selectedCategory;
  final List<String> availableCategories;
  final Function(DateTime? fromDate, DateTime? toDate, String? category)
  onApplyFilter;
  final Function() onClearFilter;
  final String title;

  const ReportFilterWidget({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.selectedCategory,
    required this.availableCategories,
    required this.onApplyFilter,
    required this.onClearFilter,
    required this.title,
  });

  @override
  State<ReportFilterWidget> createState() => _ReportFilterWidgetState();
}

class _ReportFilterWidgetState extends State<ReportFilterWidget> {
  late DateTime? _fromDate;
  late DateTime? _toDate;
  late String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.filter_list, color: Colors.white),
      onPressed: _showFilterDialog,
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.title),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date Range Section
              const Text(
                'نطاق التاريخ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('من تاريخ'),
                subtitle: Text(
                  _fromDate != null
                      ? DateFormat('dd/MM/yyyy').format(_fromDate!)
                      : 'اختر التاريخ',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _fromDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _fromDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('إلى تاريخ'),
                subtitle: Text(
                  _toDate != null
                      ? DateFormat('dd/MM/yyyy').format(_toDate!)
                      : 'اختر التاريخ',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _toDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _toDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Category Filter Section
              if (widget.availableCategories.isNotEmpty) ...[
                const Text(
                  'تصفية حسب الفئة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    hint: const Text('اختر الفئة'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('جميع الفئات'),
                      ),
                      ...widget.availableCategories.map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Quick Date Presets
              const Text(
                'فترات سريعة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickDateButton('اليوم', () {
                    final now = DateTime.now();
                    setState(() {
                      _fromDate = DateTime(now.year, now.month, now.day);
                      _toDate = DateTime(now.year, now.month, now.day);
                    });
                  }),
                  _buildQuickDateButton('الأسبوع', () {
                    final now = DateTime.now();
                    final weekStart = now.subtract(
                      Duration(days: now.weekday - 1),
                    );
                    setState(() {
                      _fromDate = DateTime(
                        weekStart.year,
                        weekStart.month,
                        weekStart.day,
                      );
                      _toDate = DateTime(now.year, now.month, now.day);
                    });
                  }),
                  _buildQuickDateButton('الشهر', () {
                    final now = DateTime.now();
                    setState(() {
                      _fromDate = DateTime(now.year, now.month, 1);
                      _toDate = DateTime(now.year, now.month, now.day);
                    });
                  }),
                  _buildQuickDateButton('السنة', () {
                    final now = DateTime.now();
                    setState(() {
                      _fromDate = DateTime(now.year, 1, 1);
                      _toDate = DateTime(now.year, now.month, now.day);
                    });
                  }),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _fromDate = null;
                _toDate = null;
                _selectedCategory = null;
              });
              widget.onClearFilter();
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء الفلتر'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onApplyFilter(_fromDate, _toDate, _selectedCategory);
            },
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
