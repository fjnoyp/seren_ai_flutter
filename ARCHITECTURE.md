# Seren AI Architecture

## System Overview

Seren AI is built using a service-oriented architecture where features are grouped by functionality rather than technical layers. This enables faster development cycles and better code organization for this AI-integrated application.

### Multi-Repository Structure

The full system consists of three main components:

1. **Client Application (This Repo)** - Flutter UI and state management
2. **[LangGraph Agentic AI](https://github.com/fjnoyp/seren-ai-langgraph)** - Reasoning engine for voice commands
3. **[Supabase Backend](https://github.com/fjnoyp/seren_ai_supabase)** - Postgres DB and Edge Functions

## Client Architecture

### Service Grouping Pattern

We adopt a service grouping architecture, whereby services group the full stack functionality for a given feature. Each feature module contains:

- Data models
- Repository classes
- Service providers
- UI components

This organization allows each module to be a cohesive unit with minimal cross-module dependencies.

```
lib/
├── services/
│   ├── ai/                  # AI integration
│   │   ├── ai_request/      # AI operation request system
│   │   ├── langgraph/       # LangGraph API integration
│   │   └── ai_chats/        # Chat history and UI
│   ├── data/                # Data services
│   │   ├── common/          # Common data utilities
│   │   ├── tasks/           # Task management
│   │   ├── notes/           # Notes management
│   │   ├── shifts/          # Shift management
│   │   └── users/           # User management
│   ├── auth/                # Authentication
│   └── speech_to_text/      # Voice input processing
└── widgets/                 # Shared UI components
```

### Directory Structure Principles

Each service module follows a consistent structure:

```
services/data/tasks/
├── models/                  # Data models
│   └── task_model.dart
├── repositories/
│   ├── task_repository.dart # Database interactions
│   └── task_queries.dart    # SQL queries
├── providers/
│   ├── task_service_provider.dart     # Primary service
│   └── tasks_provider.dart            # State providers
├── ai_tool_methods/         # AI operation implementations
│   └── task_tool_methods.dart
└── widgets/                 # Task-specific UI
    └── task_list_item.dart
```

## State Management Architecture

### Riverpod Provider Hierarchy

Seren AI uses Riverpod for state management with a structured provider hierarchy:

1. **Repository Providers** - Low-level database access
2. **Service Providers** - Business logic and operations
3. **State Providers** - UI state derived from repositories
4. **UI Providers** - Screen-specific state combinations

### Example Provider Pattern

```dart
// Repository Provider - Database access
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(databaseProvider));
});

// Service Provider - Business logic
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.watch(taskRepositoryProvider));
});

// State Provider - Reactive data
final tasksProvider = StreamProvider.family<List<Task>, String>((ref, projectId) {
  return ref.watch(taskRepositoryProvider).watchTasksForProject(projectId);
});
```

## AI Integration Architecture

The AI system is integrated at the core of the application architecture using a unique state control mechanism.

### AI Request Execution Flow

1. User voice command is processed by `speech_to_text` service
2. `ai_chat_service_provider` forwards request to LangGraph service
3. LangGraph returns structured `ai_request` objects
4. `ai_request_executor` routes requests to appropriate tool methods
5. Tool methods execute operations against app state via Riverpod providers
6. UI updates automatically through provider state changes

### Code Example: AI Request Handling

```dart
// AI Request Model
class AiRequest {
  final String operation;
  final Map<String, dynamic> parameters;
  
  // Execute this request against the system
  Future<AiResponse> execute(AiToolContext context) async {
    final executor = AiRequestExecutor();
    return executor.executeRequest(this, context);
  }
}

// Task Tool Method Example
class TaskToolMethods {
  static Future<AiResponse> createTask(
    AiToolContext context, 
    Map<String, dynamic> params
  ) async {
    // Extract parameters
    final title = params['title'] as String;
    final projectId = params['projectId'] as String;
    
    // Create task via repository
    final repository = context.ref.read(taskRepositoryProvider);
    final taskId = await repository.createTask(title, projectId);
    
    return AiResponse.success({
      'taskId': taskId,
      'message': 'Task created successfully'
    });
  }
}
```

## Offline-First Data Architecture

Seren AI uses PowerSync to enable a fully functional offline experience:

1. **Local Database** - SQLite database for local data storage
2. **Change Tracking** - Records all changes made while offline
3. **Conflict Resolution** - Merges changes when connectivity is restored
4. **Data Sync** - Bi-directional sync with Supabase Postgres

### Query Pattern

PowerSync allows direct SQL queries against the local database:

```dart
// Repository base class with PowerSync integration
abstract class BaseRepository<T> {
  final PowerSyncDatabase db;
  
  // Watch a query for changes
  Stream<List<T>> watchQuery(String query, List<Object?> params) {
    return db.watch(query, params).map((rows) => 
      rows.map((row) => fromRow(row)).toList()
    );
  }
  
  // Execute a write operation
  Future<void> execute(String query, List<Object?> params) {
    return db.execute(query, params);
  }
  
  // Convert from database row to model
  T fromRow(Map<String, dynamic> row);
}
```

## Widget Organization

Widgets are organized based on their scope and reusability:

- **Feature-specific widgets** reside within their feature folder
- **Cross-feature widgets** live in the top-level `widgets` folder
- **Complex, multi-data widgets** are placed in the top-level `widgets` folder

This organization allows for maximum reusability while maintaining the cohesion of feature-specific components.

## Performance Considerations

- **Selective Provider Watching** - Careful use of `watch` vs. `read`
- **Paginated Data Loading** - Query only visible data
- **Debounced AI Interactions** - Prevent excessive API calls
- **Optimistic UI Updates** - Update UI before backend confirms changes
- **Background Processing** - Heavy operations run in isolates
