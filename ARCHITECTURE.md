# Architecture Structure

We adopt a service gropuing architecture, whereby services group the full stack functionality for a given feature. 

For example, the data/ai_chats folder contains the data models, frontend widgets, and db service providers for accessing the data of ai_chats. 

If needed, each service folder should ideally be able to become its own standalone flutter module. 

When separating modules, think in terms of discrete use cases and reduce amount of cross module imports. 

#### ai_interaction/
Classes for interacting with LLM 

#### data/
Contains all classes for interacting with postgres data tables. 

#### Organizing Widgets

Widgets that use multiple data classes should exist in the top level widgets folder. 
Ideally all likewise widgets should be grouped together in sub folders. 

Widgets that only display data of a specific table can exist in the data folder (ie. data/ai_chats/widgest/ai_chat_threads_page.dart) 

#### `repositories/` folder
- `foo_queries.dart`: Static strings for sql queries. 
- `foo_repository.dart`: Classes for interacting with the db (one per model). Must extend from [`BaseRepository`](lib/services/data/common/base_repository.dart).

#### `providers/` folder
- `foo_dependency(_provider).dart`: Helper class/provider that provides the current (usually persistent) "foo" id for other providers that depend on it.
- `foo_service_provider.dart`: Provider for Service classes. Service classes provide implementations for all user action calls related to that module. If needed, a module can have multiple Service classes.
- The other providers are for the remaining use cases. They usually watch the repository providers and are always StreamProviders.
