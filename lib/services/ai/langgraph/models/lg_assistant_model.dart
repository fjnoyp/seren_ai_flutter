class LgAssistantModel {
  final String assistantId;
  final String graphId;
  final LgAssistantConfig config;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final int version;
  final String name;

  LgAssistantModel({
    required this.assistantId,
    required this.graphId,
    required this.config,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
    required this.version,
    required this.name,
  });

  factory LgAssistantModel.fromJson(Map<String, dynamic> json) {
    return LgAssistantModel(
      assistantId: json['assistant_id'],
      graphId: json['graph_id'],
      config: LgAssistantConfig.fromJson(json['config']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      metadata: json['metadata'] ?? {},
      version: json['version'],
      name: json['name'],
    );
  }
}

class LgAssistantConfig {
  final List<String> tags;
  final int recursionLimit;
  final Map<String, dynamic> configurable;

  LgAssistantConfig({
    required this.tags,
    required this.recursionLimit,
    required this.configurable,
  });

  factory LgAssistantConfig.fromJson(Map<String, dynamic> json) {
    return LgAssistantConfig(
      tags: List<String>.from(json['tags'] ?? []),
      recursionLimit: json['recursion_limit'] ?? 0,
      configurable: json['configurable'] ?? {},
    );
  }
}