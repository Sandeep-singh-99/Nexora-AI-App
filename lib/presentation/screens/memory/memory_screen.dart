import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_colors.dart';
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

  void _showAddMemoryDialog(AppColors colors) {
    final contentController = TextEditingController();
    final categoryController = TextEditingController(text: 'General');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Remember Fact / Preference',
                style: TextStyle(
                  color: colors.textPrimary,
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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Long-Term Memory & Graph',
          style: TextStyle(color: colors.textPrimary),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.primary,
          labelColor: colors.textPrimary,
          unselectedLabelColor: colors.textMuted,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(icon: Icon(Icons.bookmark_outline, size: 18), text: 'Memories'),
            Tab(icon: Icon(Icons.hub_outlined, size: 18), text: 'Knowledge Graph'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: colors.textSecondary),
            tooltip: 'Add Memory',
            onPressed: () => _showAddMemoryDialog(colors),
          ),
        ],
      ),
      body: BlocBuilder<MemoryBloc, MemoryState>(
        builder: (context, state) {
          if (state is MemoryLoading) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            );
          }

          if (state is MemoryLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildMemoriesTab(context, state, colors),
                _buildGraphTab(context, state.graph, colors),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMemoriesTab(BuildContext context, MemoryLoaded state, AppColors colors) {
    final categories = state.availableCategories.toList();
    final memories = state.filteredMemories;

    return Column(
      children: [
        // Category Filter Chips
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat == state.selectedCategory;

              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: colors.primary,
                backgroundColor: colors.surface,
                side: BorderSide(color: isSelected ? colors.primary : colors.border),
                labelStyle: TextStyle(
                  color: isSelected ? colors.onPrimary : colors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) {
                  HapticUtils.selectionClick();
                  context.read<MemoryBloc>().add(LoadMemories(category: isSelected ? null : cat));
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
                      Icon(Icons.psychology_outlined, size: 48, color: colors.textMuted),
                      const SizedBox(height: 12),
                      Text('No Memories Recorded', style: TextStyle(color: colors.textSecondary, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Memories ground agent context and persona.', style: TextStyle(color: colors.textMuted, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: memories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = memories[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Text(
                                  item.category.toUpperCase(),
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                DateHelpers.formatShortDate(item.createdAt),
                                style: TextStyle(color: colors.textMuted, fontSize: 11),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 18, color: colors.textMuted),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                onPressed: () {
                                  HapticUtils.lightImpact();
                                  context.read<MemoryBloc>().add(DeleteMemoryEvent(item.id));
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.content,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 13,
                              height: 1.45,
                            ),
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

  Widget _buildGraphTab(BuildContext context, KnowledgeGraphEntity? graph, AppColors colors) {
    if (graph == null || graph.nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hub_outlined, size: 48, color: colors.textMuted),
            const SizedBox(height: 12),
            Text('No Knowledge Graph Nodes', style: TextStyle(color: colors.textSecondary, fontSize: 15)),
            const SizedBox(height: 4),
            Text('Concepts and relational links extracted automatically from chats.', style: TextStyle(color: colors.textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: KnowledgeGraphPainter(graph, colors),
        );
      },
    );
  }
}

class KnowledgeGraphPainter extends CustomPainter {
  final KnowledgeGraphEntity graph;
  final AppColors colors;

  KnowledgeGraphPainter(this.graph, this.colors);

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
      ..color = colors.border
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
      ..color = colors.card
      ..style = PaintingStyle.fill;

    final nodeBorderPaint = Paint()
      ..color = colors.primary
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
        style: TextStyle(
          color: colors.textPrimary,
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
