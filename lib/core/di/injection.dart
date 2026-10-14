import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../data/repositories/memory_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/repositories/memory_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../presentation/blocs/artifacts/artifact_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/chat/chat_bloc.dart';
import '../../presentation/blocs/conversation/conversation_bloc.dart';
import '../../presentation/blocs/documents/document_bloc.dart';
import '../../presentation/blocs/memory/memory_bloc.dart';
import '../../presentation/blocs/settings/settings_bloc.dart';
import '../network/dio_client.dart';
import '../security/secure_storage_service.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  const secureStorage = FlutterSecureStorage();
  sl.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Core & Security
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl(), sl()),
  );

  sl.registerLazySingleton<DioClient>(
    () => DioClient(sl()),
  );

  // Datasources
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSource(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<MemoryRepository>(
    () => MemoryRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl(), sl()),
  );

  // BLoCs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl()),
  );

  sl.registerFactory<ConversationBloc>(
    () => ConversationBloc(sl()),
  );

  sl.registerFactory<ChatBloc>(
    () => ChatBloc(chatRepository: sl(), conversationRepository: sl()),
  );

  sl.registerFactory<ArtifactBloc>(
    () => ArtifactBloc(),
  );

  sl.registerFactory<DocumentBloc>(
    () => DocumentBloc(sl()),
  );

  sl.registerFactory<MemoryBloc>(
    () => MemoryBloc(sl()),
  );

  sl.registerFactory<SettingsBloc>(
    () => SettingsBloc(sl()),
  );
}
