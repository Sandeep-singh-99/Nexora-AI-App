import 'package:equatable/equatable.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../domain/entities/conversation_entity.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();
  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<ConversationEntity> allConversations;
  final String? selectedConversationId;
  final String searchQuery;

  const ConversationLoaded({
    required this.allConversations,
    this.selectedConversationId,
    this.searchQuery = '',
  });

  List<ConversationEntity> get filteredConversations {
    if (searchQuery.trim().isEmpty) {
      return allConversations;
    }
    final q = searchQuery.toLowerCase();
    return allConversations.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  List<ConversationEntity> get pinnedConversations {
    return filteredConversations.where((c) => c.isPinned && !c.isArchived).toList();
  }

  Map<String, List<ConversationEntity>> get categorizedUnpinned {
    final Map<String, List<ConversationEntity>> categories = {
      'Today': [],
      'Yesterday': [],
      'Previous 7 Days': [],
      'Older': [],
    };

    for (final c in filteredConversations) {
      if (c.isPinned || c.isArchived) continue;
      final category = DateHelpers.categorizeDate(c.updatedAt);
      categories[category]?.add(c);
    }

    return categories;
  }

  List<ConversationEntity> get archivedConversations {
    return filteredConversations.where((c) => c.isArchived).toList();
  }

  ConversationEntity? get currentConversation {
    if (selectedConversationId == null) return null;
    try {
      return allConversations.firstWhere((c) => c.id == selectedConversationId);
    } catch (_) {
      return null;
    }
  }

  ConversationLoaded copyWith({
    List<ConversationEntity>? allConversations,
    String? selectedConversationId,
    bool clearSelectedId = false,
    String? searchQuery,
  }) {
    return ConversationLoaded(
      allConversations: allConversations ?? this.allConversations,
      selectedConversationId: clearSelectedId
          ? null
          : (selectedConversationId ?? this.selectedConversationId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allConversations, selectedConversationId, searchQuery];
}

class ConversationError extends ConversationState {
  final String message;
  const ConversationError(this.message);
  @override
  List<Object?> get props => [message];
}
