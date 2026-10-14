import 'package:flutter/material.dart';
import '../../../../app/theme/color_palette.dart';

class DataTableCard extends StatefulWidget {
  final String title;
  final List<String> columns;
  final List<List<dynamic>> rows;

  const DataTableCard({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
  });

  @override
  State<DataTableCard> createState() => _DataTableCardState();
}

class _DataTableCardState extends State<DataTableCard> {
  int? _sortColumnIndex;
  bool _isAscending = true;
  late List<List<dynamic>> _currentRows;

  @override
  void initState() {
    super.initState();
    _currentRows = List.from(widget.rows);
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
      _currentRows.sort((a, b) {
        final aVal = a[columnIndex];
        final bVal = b[columnIndex];
        final compare = Comparable.compare(aVal.toString(), bVal.toString());
        return ascending ? compare : -compare;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.elevatedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart_outlined, size: 18, color: ColorPalette.indigoAccent),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: const TextStyle(
                  color: ColorPalette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${_currentRows.length} rows',
                style: const TextStyle(color: ColorPalette.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _isAscending,
              headingRowColor: WidgetStateProperty.all(ColorPalette.obsidianBackground),
              columns: widget.columns.asMap().entries.map((entry) {
                return DataColumn(
                  label: Text(
                    entry.value,
                    style: const TextStyle(
                      color: ColorPalette.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  onSort: (colIndex, ascending) => _sort(colIndex, ascending),
                );
              }).toList(),
              rows: _currentRows.map((row) {
                return DataRow(
                  cells: row.map((cell) {
                    return DataCell(
                      Text(
                        cell.toString(),
                        style: const TextStyle(color: ColorPalette.textSecondary, fontSize: 12),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
