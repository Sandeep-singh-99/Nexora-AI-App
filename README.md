# Nexora Mobile ⚡

<p align="center">
  <img src="assets/icon/app_icon.png" alt="Nexora Logo" width="100" onerror="this.style.display='none'"/>
</p>

<p align="center">
  <b>High-Performance Flutter AI Multi-Agent & Generative UI Client</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%3E%3D3.3.0-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-%3E%3D3.3.0-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-blueviolet" alt="Clean Architecture">
  <img src="https://img.shields.io/badge/State%20Management-BLoC%208.x-orange" alt="BLoC">
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-success" alt="Platforms">
</p>

---

## 🌟 Overview

**Nexora Mobile** is an enterprise-grade, high-performance Flutter mobile client engineered for advanced AI interactions, multi-agent workflows, and interactive Generative UI. 

Designed following **Clean Architecture** and **BLoC (Business Logic Component)** design patterns, Nexora connects seamlessly with backend LLM orchestrators over **Server-Sent Events (SSE)** for real-time token streaming, rich artifact generation, RAG document knowledge bases, semantic memory graphs, and secure BYOK (Bring Your Own Key) multi-model management.

---

## ✨ Features

### 💬 Real-Time Streaming Chat
- **Token-by-Token SSE Streaming**: Real-time response rendering powered by an event-driven `SSEStreamReader`.
- **Deep AI Reasoning Accordion**: Collapsible thinking blocks displaying LLM internal chain-of-thought and agent steps with micro-animations.
- **Search Citations & Grounding**: Integrated source attribution displaying external research citations, URLs, and snippets.
- **Session History & Auto-titling**: Sliding conversation drawer with session switching, search, deletion, and automated AI title generation.

### 🎨 Generative UI & Rich Media Engine
- **Interactive Visual Charts**: Dynamic line, bar, and pie charts rendered natively via `fl_chart`.
- **Tabular Data Cards**: Formatted data tables with responsive column layout and scrolling.
- **LaTeX Math Rendering**: Scientific and mathematical formula support via `flutter_math_fork`.
- **Embedded YouTube Player**: In-line video playback with transcript synchronization.
- **Interactive Artifact Viewer**: Modal inspect window for code snippets with syntax highlighting and instant copying.

### 📚 Knowledge Base & Multimodal RAG
- **Document Ingestion**: Upload and index `.pdf`, `.txt`, `.docx`, and Markdown files directly from your device.
- **YouTube Video Ingestion**: Ingest YouTube links for automatic audio transcription and semantic querying.
- **Custom Guardrails**: Configure domain safety guidelines, privacy filters, and query constraints on the fly.

### 🧠 Semantic Memory & Knowledge Graph
- **Persistent Episodic Memory**: Stores facts, user preferences, and conversational history across sessions.
- **Memory Graph Visualization**: Interconnected entity and relationship mapping for contextual awareness.

### 🔑 BYOK (Bring Your Own Key) & Security
- **Encrypted Local Storage**: Sensitive auth tokens and API keys are stored via OS-level hardware keystores (`flutter_secure_storage`).
- **Custom Base URLs**: Effortlessly toggle between Localhost, Android Emulator (`10.0.2.2`), and remote production endpoints.
- **Multi-Provider Keys**: Bring your own keys for OpenAI, Anthropic, Google Gemini, Groq, or self-hosted Ollama models.

### 🌌 Aesthetic Cyberpunk/Obsidian UI
- **Obsidian Dark Palette**: Designed for OLED screens with deep slate and obsidian undertones.
- **Glassmorphic Components**: Frosted backdrop filters, subtle neon borders, and tactile shimmer loading skeletons.
- **Haptic Feedback**: Subtle vibration cues on taps, streaming completions, and errors.

---

## 🏗️ Architecture & Project Structure

The project follows the standard **Clean Architecture** structure:

```
lib/
├── app/                        # Application configuration, routing & styling
│   ├── router/                 # GoRouter configuration & route guards
│   ├── theme/                  # ColorPalette, dark theme, typography
│   └── app.dart                # MaterialApp & root BLoC providers
├── core/                       # Core utilities & cross-cutting concerns
│   ├── constants/              # API endpoints, storage keys, route paths
│   ├── di/                     # Dependency Injection via GetIt
│   ├── errors/                 # Exceptions, failures & error handling
│   ├── network/                # Dio client, Auth interceptor & SSE reader
│   ├── security/               # SecureStorageService (tokens & BYOK)
│   └── utils/                  # Date formatting, haptics, deep linking
├── data/                       # Data layer (implements Domain contracts)
│   ├── datasources/            # Remote API data sources
│   ├── models/                 # Serialization models (from/to JSON)
│   └── repositories/           # Repository implementations
├── domain/                     # Business domain layer (pure Dart)
│   ├── entities/               # Domain entities (User, Message, Document, etc.)
│   └── repositories/           # Abstract repository contracts
└── presentation/               # UI & Presentation layer
    ├── blocs/                  # BLoC state managers (Chat, Auth, Memory, Docs)
    ├── screens/                # App screens (Auth, Chat, Documents, Memory, Settings)
    └── widgets/                # Reusable UI widgets (AppButton, GlassContainer, Shimmer)
```

---

## 🛠️ Tech Stack & Dependencies

| Category | Package / Tool | Purpose |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) `3.3.0+` | Cross-platform mobile development |
| **Language** | [Dart](https://dart.dev) | Strongly-typed client programming |
| **State Management** | `flutter_bloc` & `bloc_concurrency` | Unidirectional reactive state management |
| **Routing** | `go_router` | Declarative URL-based routing with redirect guards |
| **DI** | `get_it` | Fast service locator and dependency injection |
| **Networking** | `dio` | HTTP client with automatic JWT token refresh & interceptors |
| **Streaming** | Custom `SSEStreamReader` | Real-time Server-Sent Events stream consumer |
| **Storage** | `flutter_secure_storage` | Hardware-backed keystore/keychain for tokens & BYOK |
| **Media & Math** | `fl_chart`, `flutter_math_fork`, `youtube_player_flutter` | Interactive generative UI components |
| **Animations** | `flutter_animate`, `shimmer` | Fluid loading states and micro-interactions |

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.3.0`)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode (with iOS Simulator or Android Emulator configured)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/nexora_ai_app.git
   cd nexora_ai_app
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure the Backend Endpoint:**
   By default, the application connects to:
   - **Android Emulator**: `http://10.0.2.2:8000/api/v1`
   - **iOS Simulator / Desktop**: `http://localhost:8000/api/v1`

   You can modify this dynamically inside the in-app **Settings screen** or configure `lib/core/constants/api_constants.dart`.

4. **Run the App:**
   ```bash
   # Run on connected device or emulator
   flutter run
   ```

---

## 🧪 Testing & Code Quality

Run static analysis and tests to ensure code integrity:

```bash
# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test
```

---

## 🔌 API & Backend Compatibility

Nexora is designed to communicate with standard AI Agent / RAG backends (FastAPI, Express, Flask, LangChain, LlamaIndex, etc.) implementing the following key contracts:

- **Authentication**: JWT Bearer auth with Access + Refresh token rotation (`/auth/login`, `/auth/refresh`).
- **Chat Streaming**: Server-Sent Events stream yielding incremental text chunks, reasoning thoughts, and generative UI card payloads (`/ai/chat/stream`).
- **Document Management**: Multipart upload for RAG vector indexing (`/documents/upload`, `/documents/query`).
- **Memory Store**: Semantic key-value and graph queries (`/memory`, `/memory/graph`).

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
Feel free to open an issue or submit a pull request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.
