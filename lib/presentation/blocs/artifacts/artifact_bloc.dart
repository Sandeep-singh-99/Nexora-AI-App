import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/message_entity.dart';

enum ArtifactTab { preview, code }
enum ArtifactViewport { responsive, mobile, desktop }

abstract class ArtifactEvent extends Equatable {
  const ArtifactEvent();
  @override
  List<Object?> get props => [];
}

class OpenArtifactEvent extends ArtifactEvent {
  final ArtifactMetadata artifact;
  const OpenArtifactEvent(this.artifact);
  @override
  List<Object?> get props => [artifact];
}

class CloseArtifactEvent extends ArtifactEvent {}

class ChangeArtifactTabEvent extends ArtifactEvent {
  final ArtifactTab tab;
  const ChangeArtifactTabEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}

class ChangeArtifactViewportEvent extends ArtifactEvent {
  final ArtifactViewport viewport;
  const ChangeArtifactViewportEvent(this.viewport);
  @override
  List<Object?> get props => [viewport];
}

abstract class ArtifactState extends Equatable {
  const ArtifactState();
  @override
  List<Object?> get props => [];
}

class ArtifactClosed extends ArtifactState {}

class ArtifactOpen extends ArtifactState {
  final ArtifactMetadata artifact;
  final ArtifactTab activeTab;
  final ArtifactViewport activeViewport;

  const ArtifactOpen({
    required this.artifact,
    this.activeTab = ArtifactTab.preview,
    this.activeViewport = ArtifactViewport.responsive,
  });

  ArtifactOpen copyWith({
    ArtifactMetadata? artifact,
    ArtifactTab? activeTab,
    ArtifactViewport? activeViewport,
  }) {
    return ArtifactOpen(
      artifact: artifact ?? this.artifact,
      activeTab: activeTab ?? this.activeTab,
      activeViewport: activeViewport ?? this.activeViewport,
    );
  }

  @override
  List<Object?> get props => [artifact, activeTab, activeViewport];
}

class ArtifactBloc extends Bloc<ArtifactEvent, ArtifactState> {
  ArtifactBloc() : super(ArtifactClosed()) {
    on<OpenArtifactEvent>((event, emit) {
      emit(ArtifactOpen(artifact: event.artifact));
    });
    on<CloseArtifactEvent>((event, emit) {
      emit(ArtifactClosed());
    });
    on<ChangeArtifactTabEvent>((event, emit) {
      if (state is ArtifactOpen) {
        emit((state as ArtifactOpen).copyWith(activeTab: event.tab));
      }
    });
    on<ChangeArtifactViewportEvent>((event, emit) {
      if (state is ArtifactOpen) {
        emit((state as ArtifactOpen).copyWith(activeViewport: event.viewport));
      }
    });
  }
}
