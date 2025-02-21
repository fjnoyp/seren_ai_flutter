
class LgRunStreamResponseModel {
  final String event;
  final String data;

  LgRunStreamResponseModel({
    required this.event,
    required this.data,
  });

  // New factory constructor to parse SSE format
  factory LgRunStreamResponseModel.fromSSE(String sseData) {
    final lines = sseData.trim().split('\n');
    String? event;
    String? data;

    for (var line in lines) {
      if (line.startsWith('event:')) {
        event = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        data = line.substring(5).trim();
      }
    }

    if (event == null || data == null) {
      throw FormatException('Invalid SSE format: $sseData');
    }

    return LgRunStreamResponseModel(event: event, data: data);
  }
}