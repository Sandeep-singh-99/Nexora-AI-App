import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/color_palette.dart';
import '../../../domain/entities/analytics_entity.dart';
import '../../../domain/repositories/settings_repository.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class SaveByokSettingsEvent extends SettingsEvent {
  final String provider;
  final String key;
  final String model;

  const SaveByokSettingsEvent({
    required this.provider,
    required this.key,
    required this.model,
  });

  @override
  List<Object?> get props => [provider, key, model];
}

class ClearByokSettingsEvent extends SettingsEvent {}

class LoadAnalyticsEvent extends SettingsEvent {
  final String timeframe;
  const LoadAnalyticsEvent({this.timeframe = 'week'});
  @override
  List<Object?> get props => [timeframe];
}

class UpdateBaseUrlEvent extends SettingsEvent {
  final String baseUrl;
  const UpdateBaseUrlEvent(this.baseUrl);
  @override
  List<Object?> get props => [baseUrl];
}

class UpdateActiveModelEvent extends SettingsEvent {
  final String model;
  const UpdateActiveModelEvent(this.model);
  @override
  List<Object?> get props => [model];
}

class UpdateThemeModeEvent extends SettingsEvent {
  final ThemeMode mode;
  const UpdateThemeModeEvent(this.mode);
  @override
  List<Object?> get props => [mode];
}

class UpdateAccentColorEvent extends SettingsEvent {
  final Color color;
  const UpdateAccentColorEvent(this.color);
  @override
  List<Object?> get props => [color];
}

class SettingsState extends Equatable {
  final String baseUrl;
  final String activeModel;
  final ThemeMode themeMode;
  final Color accentColor;
  final String? byokProvider;
  final String? byokKey;
  final String? byokModel;
  final AnalyticsEntity? analytics;
  final bool isLoading;
  final String? error;

  const SettingsState({
    required this.baseUrl,
    required this.activeModel,
    this.themeMode = ThemeMode.dark,
    this.accentColor = ColorPalette.indigoAccent,
    this.byokProvider,
    this.byokKey,
    this.byokModel,
    this.analytics,
    this.isLoading = false,
    this.error,
  });

  bool get hasByok => byokKey != null && byokKey!.isNotEmpty;

  SettingsState copyWith({
    String? baseUrl,
    String? activeModel,
    ThemeMode? themeMode,
    Color? accentColor,
    String? byokProvider,
    String? byokKey,
    String? byokModel,
    AnalyticsEntity? analytics,
    bool? isLoading,
    String? error,
    bool clearByok = false,
  }) {
    return SettingsState(
      baseUrl: baseUrl ?? this.baseUrl,
      activeModel: activeModel ?? this.activeModel,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      byokProvider: clearByok ? null : (byokProvider ?? this.byokProvider),
      byokKey: clearByok ? null : (byokKey ?? this.byokKey),
      byokModel: clearByok ? null : (byokModel ?? this.byokModel),
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        baseUrl,
        activeModel,
        themeMode,
        accentColor,
        byokProvider,
        byokKey,
        byokModel,
        analytics,
        isLoading,
        error,
      ];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc(this._settingsRepository)
      : super(SettingsState(
          baseUrl: _settingsRepository.getBaseUrl(),
          activeModel: _settingsRepository.getActiveModel(),
        )) {
    on<LoadSettings>(_onLoadSettings);
    on<SaveByokSettingsEvent>(_onSaveByokSettings);
    on<ClearByokSettingsEvent>(_onClearByokSettings);
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<UpdateBaseUrlEvent>(_onUpdateBaseUrl);
    on<UpdateActiveModelEvent>(_onUpdateActiveModel);
    on<UpdateThemeModeEvent>(_onUpdateThemeMode);
    on<UpdateAccentColorEvent>(_onUpdateAccentColor);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final byok = await _settingsRepository.getByokChat();
    final baseUrl = _settingsRepository.getBaseUrl();
    final activeModel = _settingsRepository.getActiveModel();
    final themeStr = _settingsRepository.getThemeMode();

    ThemeMode mode = ThemeMode.dark;
    if (themeStr == 'light') mode = ThemeMode.light;
    if (themeStr == 'system') mode = ThemeMode.system;

    emit(state.copyWith(
      baseUrl: baseUrl,
      activeModel: activeModel,
      themeMode: mode,
      byokProvider: byok['provider'],
      byokKey: byok['key'],
      byokModel: byok['model'],
    ));

    // Try loading analytics
    add(const LoadAnalyticsEvent());
  }

  Future<void> _onSaveByokSettings(
    SaveByokSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _settingsRepository.saveByokChat(
      provider: event.provider,
      key: event.key,
      model: event.model,
    );
    emit(state.copyWith(
      byokProvider: event.provider,
      byokKey: event.key,
      byokModel: event.model,
    ));
  }

  Future<void> _onClearByokSettings(
    ClearByokSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _settingsRepository.clearByok();
    emit(state.copyWith(clearByok: true));
  }

  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final analytics = await _settingsRepository.getAnalytics(timeframe: event.timeframe);
      emit(state.copyWith(analytics: analytics));
    } catch (_) {}
  }

  Future<void> _onUpdateBaseUrl(
    UpdateBaseUrlEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _settingsRepository.setBaseUrl(event.baseUrl);
    emit(state.copyWith(baseUrl: event.baseUrl));
  }

  Future<void> _onUpdateActiveModel(
    UpdateActiveModelEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _settingsRepository.setActiveModel(event.model);
    emit(state.copyWith(activeModel: event.model));
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    String str = 'dark';
    if (event.mode == ThemeMode.light) str = 'light';
    if (event.mode == ThemeMode.system) str = 'system';
    await _settingsRepository.setThemeMode(str);
    emit(state.copyWith(themeMode: event.mode));
  }

  void _onUpdateAccentColor(
    UpdateAccentColorEvent event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(accentColor: event.color));
  }
}
