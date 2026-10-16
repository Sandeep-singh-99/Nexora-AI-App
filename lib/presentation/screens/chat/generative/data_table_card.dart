import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

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
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.table_chart_outlined, size: 18, color: colors.textSecondary),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${_currentRows.length} rows',
                style: TextStyle(color: colors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _isAscending,
              headingRowColor: WidgetStateProperty.all(colors.surface),
              columns: widget.columns.asMap().entries.map((entry) {
                return DataColumn(
                  label: Text(
                    entry.value,
                    style: TextStyle(
                      color: colors.textPrimary,
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
                        style: TextStyle(color: colors.textSecondary, fontSize: 12),
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
