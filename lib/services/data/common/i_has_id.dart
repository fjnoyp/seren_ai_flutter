abstract class IHasId<T> {
  String get id;

  Map<String, dynamic> toJson();
}
