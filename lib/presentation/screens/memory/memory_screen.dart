import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/color_palette.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../domain/entities/memory_entity.dart';
import '../../blocs/memory/memory_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<MemoryBloc>().add(const LoadMemories());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddMemoryDialog() {
    final contentController = TextEditingController();
    final categoryController = TextEditingController(text: 'General');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: ColorPalette.elevatedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ColorPalette.subtleBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Remember Fact / Preference',
                style: TextStyle(
                  color: ColorPalette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: contentController,
                labelText: 'Fact / Memory Content',
                hintText: 'e.g. Always generate Dart 3 code with strict typing',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: categoryController,
                labelText: 'Category',
                hintText: 'Coding / Personal / Work',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      variant: ButtonVariant.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Save Memory',
                      onPressed: () {
                        final content = contentController.text.trim();
                        final cat = categoryController.text.trim();
                        if (content.isNotEmpty) {
                          Navigator.of(context).pop();
                          context.read<MemoryBloc>().add(
                                CreateMemoryEvent(
                                  content: content,
                                  category: cat.isNotEmpty ? cat : 'General',
                                ),
                              );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.obsidianBackground,
      appBar: AppBar(
        title: const Text('Long-Term Memory & Graph'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ColorPalette.violetAccent,
          labelColor: ColorPalette.textPrimary,
          unselectedLabelColor: ColorPalette.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.bookmark_outline, size: 18), text: 'Memories'),
            Tab(icon: Icon(Icons.hub_outlined, size: 18), text: 'Knowledge Graph'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: ColorPalette.violetAccent),
            tooltip: 'Add Memory',
            onPressed: _showAddMemoryDialog,
          ),
        ],
      ),
      body: BlocBuilder<MemoryBloc, MemoryState>(
        builder: (context, state) {
          if (state is MemoryLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.violetAccent),
              ),
            );
          }

          if (state is MemoryLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildMemoriesTab(context, state),
                _buildGraphTab(context, state.graph),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMemoriesTab(BuildContext context, MemoryLoaded state) {
    final categories = state.availableCategories.toList();
    final memories = state.filteredMemories;

    return Column(
      children: [
        // Category Filter Chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = state.selectedCategory == cat;

              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: ColorPalette.violetAccent.withValues(alpha: 0.25),
                backgroundColor: ColorPalette.elevatedSurface,
                side: BorderSide(
                  color: isSelected ? ColorPalette.violetAccent : ColorPalette.subtleBorder,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? ColorPalette.violetAccent : ColorPalette.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) {
                  HapticUtils.selectionClick();
                  context.read<MemoryBloc>().add(LoadMemories(category: cat));
                },
              );
            },
          ),
        ),

        // Memories List
        Expanded(
          child: memories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.psychology_outlined, size: 48, color: ColorPalette.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'No memories saved yet',
                        style: TextStyle(color: ColorPalette.textSecondary, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Nexora AI remembers context and preferences across sessions.',
                        style: TextStyle(color: ColorPalette.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Add Fact',
                        variant: ButtonVariant.secondary,
                        onPressed: _showAddMemoryDialog,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: memories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = memories[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ColorPalette.elevatedSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorPalette.subtleBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: ColorPalette.violetAccent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.category,
                                        style: const TextStyle(
                                          color: ColorPalette.violetAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateHelpers.formatShortDate(item.createdAt),
                                      style: const TextStyle(color: ColorPalette.textMuted, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.content,
                                  style: const TextStyle(
                                    color: ColorPalette.textPrimary,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: ColorPalette.textMuted),
                            onPressed: () {
                              HapticUtils.lightImpact();
                              context.read<MemoryBloc>().add(DeleteMemoryEvent(item.id));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGraphTab(BuildContext context, KnowledgeGraphEntity? graph) {
    if (graph == null || graph.nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hub_outlined, size: 48, color: ColorPalette.textMuted),
            const SizedBox(height: 12),
            const Text(
              'No Knowledge Graph Relationships',
              style: TextStyle(color: ColorPalette.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              'Entity relations are formed automatically during conversational inference.',
              style: TextStyle(color: ColorPalette.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.5,
          maxScale: 2.5,
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: KnowledgeGraphPainter(graph: graph),
          ),
        );
      },
    );
  }
}

class KnowledgeGraphPainter extends CustomPainter {
  final KnowledgeGraphEntity graph;

  KnowledgeGraphPainter({required this.graph});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;

    // Position nodes radially
    final Map<String, Offset> nodePositions = {};
    for (int i = 0; i < graph.nodes.length; i++) {
      final angle = (2 * math.pi * i) / graph.nodes.length;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      nodePositions[graph.nodes[i].id] = Offset(x, y);
    }

    // Draw Edges
    final edgePaint = Paint()
      ..color = ColorPalette.violetAccent.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final edge in graph.edges) {
      final p1 = nodePositions[edge.sourceId];
      final p2 = nodePositions[edge.targetId];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, edgePaint);
      }
    }

    // Draw Nodes
    final nodeBgPaint = Paint()
      ..color = ColorPalette.elevatedCard
      ..style = PaintingStyle.fill;

    final nodeBorderPaint = Paint()
      ..color = ColorPalette.violetAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < graph.nodes.length; i++) {
      final node = graph.nodes[i];
      final pos = nodePositions[node.id]!;

      // Circle
      canvas.drawCircle(pos, 24, nodeBgPaint);
      canvas.drawCircle(pos, 24, nodeBorderPaint);

      // Label
      textPainter.text = TextSpan(
        text: node.label,
        style: const TextStyle(
          color: ColorPalette.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout(maxWidth: 80);
      textPainter.paint(
        canvas,
        Offset(pos.dx - (textPainter.width / 2), pos.dy + 28),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
