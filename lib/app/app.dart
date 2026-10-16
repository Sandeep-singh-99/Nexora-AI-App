import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/injection.dart';
import '../core/security/secure_storage_service.dart';
import '../presentation/blocs/artifacts/artifact_bloc.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_event.dart';
import '../presentation/blocs/chat/chat_bloc.dart';
import '../presentation/blocs/conversation/conversation_bloc.dart';
import '../presentation/blocs/documents/document_bloc.dart';
import '../presentation/blocs/memory/memory_bloc.dart';
import '../presentation/blocs/settings/settings_bloc.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class NexoraApp extends StatefulWidget {
  const NexoraApp({super.key});

  @override
  State<NexoraApp> createState() => _NexoraAppState();
}

class _NexoraAppState extends State<NexoraApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(sl<SecureStorageService>());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<ConversationBloc>(
          create: (_) => sl<ConversationBloc>(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => sl<ChatBloc>(),
        ),
        BlocProvider<ArtifactBloc>(
          create: (_) => sl<ArtifactBloc>(),
        ),
        BlocProvider<DocumentBloc>(
          create: (_) => sl<DocumentBloc>(),
        ),
        BlocProvider<MemoryBloc>(
          create: (_) => sl<MemoryBloc>(),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => sl<SettingsBloc>()..add(LoadSettings()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            title: 'Nexora AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            routerConfig: _appRouter.router,
          );
        },
      ),
    );
  }
}
