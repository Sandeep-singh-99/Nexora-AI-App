import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/memory_entity.dart';
import '../../../domain/repositories/memory_repository.dart';

abstract class MemoryEvent extends Equatable {
  const MemoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadMemories extends MemoryEvent {
  final String? category;
  final String? query;
  const LoadMemories({this.category, this.query});
  @override
  List<Object?> get props => [category, query];
}

class CreateMemoryEvent extends MemoryEvent {
  final String content;
  final String category;
  const CreateMemoryEvent({required this.content, required this.category});
  @override
  List<Object?> get props => [content, category];
}

class DeleteMemoryEvent extends MemoryEvent {
  final String id;
  const DeleteMemoryEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class LoadKnowledgeGraphEvent extends MemoryEvent {}

abstract class MemoryState extends Equatable {
  const MemoryState();
  @override
  List<Object?> get props => [];
}

class MemoryInitial extends MemoryState {}

class MemoryLoading extends MemoryState {}

class MemoryLoaded extends MemoryState {
  final List<MemoryEntity> memories;
  final KnowledgeGraphEntity? graph;
  final String? selectedCategory;
  final String searchQuery;

  const MemoryLoaded({
    required this.memories,
    this.graph,
    this.selectedCategory,
    this.searchQuery = '',
  });

  List<MemoryEntity> get filteredMemories {
    return memories.where((m) {
      final matchesCategory = selectedCategory == null ||
          selectedCategory == 'All' ||
          m.category.toLowerCase() == selectedCategory!.toLowerCase();
      final matchesQuery = searchQuery.isEmpty ||
          m.content.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Set<String> get availableCategories {
    return {'All', ...memories.map((m) => m.category)};
  }

  MemoryLoaded copyWith({
    List<MemoryEntity>? memories,
    KnowledgeGraphEntity? graph,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return MemoryLoaded(
      memories: memories ?? this.memories,
      graph: graph ?? this.graph,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [memories, graph, selectedCategory, searchQuery];
}

class MemoryError extends MemoryState {
  final String message;
  const MemoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class MemoryBloc extends Bloc<MemoryEvent, MemoryState> {
  final MemoryRepository _memoryRepository;

  MemoryBloc(this._memoryRepository) : super(MemoryInitial()) {
    on<LoadMemories>(_onLoadMemories);
    on<CreateMemoryEvent>(_onCreateMemory);
    on<DeleteMemoryEvent>(_onDeleteMemory);
    on<LoadKnowledgeGraphEvent>(_onLoadKnowledgeGraph);
  }

  Future<void> _onLoadMemories(
    LoadMemories event,
    Emitter<MemoryState> emit,
  ) async {
    emit(MemoryLoading());
    try {
      final list = await _memoryRepository.getMemories(
        category: event.category == 'All' ? null : event.category,
        query: event.query,
      );
      KnowledgeGraphEntity? graph;
      try {
        graph = await _memoryRepository.getKnowledgeGraph();
      } catch (_) {}

      emit(MemoryLoaded(
        memories: list,
        graph: graph,
        selectedCategory: event.category ?? 'All',
        searchQuery: event.query ?? '',
      ));
    } catch (e) {
      emit(MemoryError(e.toString()));
    }
  }

  Future<void> _onCreateMemory(
    CreateMemoryEvent event,
    Emitter<MemoryState> emit,
  ) async {
    try {
      final newMem = await _memoryRepository.createMemory(
        content: event.content,
        category: event.category,
      );
      if (state is MemoryLoaded) {
        final s = state as MemoryLoaded;
        emit(s.copyWith(memories: [newMem, ...s.memories]));
      } else {
        emit(MemoryLoaded(memories: [newMem]));
      }
    } catch (e) {
      emit(MemoryError(e.toString()));
    }
  }

  Future<void> _onDeleteMemory(
    DeleteMemoryEvent event,
    Emitter<MemoryState> emit,
  ) async {
    if (state is MemoryLoaded) {
      final s = state as MemoryLoaded;
      try {
        await _memoryRepository.deleteMemory(event.id);
        emit(s.copyWith(
          memories: s.memories.where((m) => m.id != event.id).toList(),
        ));
      } catch (e) {
        emit(MemoryError(e.toString()));
      }
    }
  }

  Future<void> _onLoadKnowledgeGraph(
    LoadKnowledgeGraphEvent event,
    Emitter<MemoryState> emit,
  ) async {
    if (state is MemoryLoaded) {
      final s = state as MemoryLoaded;
      try {
        final graph = await _memoryRepository.getKnowledgeGraph();
        emit(s.copyWith(graph: graph));
      } catch (_) {}
    }
  }
}
