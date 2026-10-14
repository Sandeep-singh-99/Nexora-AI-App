class ApiConstants {
  ApiConstants._();

  // Default base URL - configurable via SettingsBloc / SecureStorage
  static const String defaultBaseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator default
  static const String defaultLocalhostUrl = 'http://localhost:8000/api/v1';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Conversations endpoints
  static const String conversations = '/chat/conversations';
  static String conversation(String id) => '/chat/conversations/$id';
  static String generateTitle(String id) => '/chat/conversations/$id/generate-title';
  static String conversationMessages(String id) => '/chat/conversations/$id/messages';

  // Real-time Chat SSE
  static const String chatStream = '/ai/chat/stream';

  // Documents & RAG endpoints
  static const String documents = '/documents';
  static const String documentUpload = '/documents/upload';
  static String document(String id) => '/documents/$id';
  static const String documentYoutube = '/documents/youtube';
  static const String documentQuery = '/documents/query';

  // Memory endpoints
  static const String memory = '/memory';
  static String memoryItem(String id) => '/memory/$id';
  static const String memoryGraph = '/memory/graph';

  // Analytics
  static const String analytics = '/chat/analytics';
}

class StorageConstants {
  StorageConstants._();

  static const String accessToken = 'nexora_access_token';
  static const String refreshToken = 'nexora_refresh_token';
  static const String csrfToken = 'nexora_csrf_token';
  static const String userProfile = 'nexora_user_profile';
  static const String baseUrl = 'nexora_api_base_url';
  static const String activeModel = 'nexora_active_model';
  static const String themeMode = 'nexora_theme_mode';
  static const String accentColor = 'nexora_accent_color';

  // BYOK Secure Storage Keys
  static const String byokPrefix = 'nexora_byok_';
  static const String byokChatKey = 'nexora_byok_chat_key';
  static const String byokChatProvider = 'nexora_byok_chat_provider';
  static const String byokChatModel = 'nexora_byok_chat_model';
  static const String byokEmbeddingKey = 'nexora_byok_emb_key';
  static const String byokEmbeddingProvider = 'nexora_byok_emb_provider';
  static const String byokEmbeddingModel = 'nexora_byok_emb_model';
}
