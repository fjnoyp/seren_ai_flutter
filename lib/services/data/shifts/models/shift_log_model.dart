import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'shift_log_model.g.dart';

@JsonSerializable()
class ShiftLogModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'shift_id')
  final String shiftId;

  @JsonKey(name: 'clock_in_datetime')
  final DateTime clockInDatetime;

  @JsonKey(name: 'clock_out_datetime')
  final DateTime? clockOutDatetime;

  @JsonKey(name: 'is_break', fromJson: _boolFromInt)
  final bool isBreak;

  /// Reason for modification/deletion.
  ///
  /// For edited logs, this should be on the **new copy** of the log instead of the "deleted" one,
  /// to make it easier to retrieve and show the reason in the UI.
  @JsonKey(name: 'modification_reason')
  final String? modificationReason;

  /// Whether the log has been deleted.
  ///
  /// This must be set to `true` for deleted logs and for overwritten (edited) logs.
  @JsonKey(name: 'is_deleted', fromJson: _boolFromInt)
  final bool isDeleted;

  /// ID of the log that was edited to create this log.
  ///
  /// Only set for new copies of logs created by editing other logs.
  @JsonKey(name: 'shift_log_parent_id')
  final String? shiftLogParentId;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  static bool _boolFromInt(dynamic value) => value == 1;

  ShiftLogModel({
    String? id,
    required this.userId,
    required this.shiftId,
    required this.clockInDatetime,
    this.clockOutDatetime,
    required this.isBreak,
    this.modificationReason,
    this.isDeleted = false,
    this.shiftLogParentId,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? uuid.v4();

  ShiftLogModel copyWith({
    String? id,
    String? userId,
    String? shiftId,
    DateTime? clockInDatetime,
    DateTime? clockOutDatetime,
    bool? isBreak,
    String? modificationReason,
    bool? isDeleted,
    String? shiftLogParentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShiftLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shiftId: shiftId ?? this.shiftId,
      clockInDatetime: clockInDatetime ?? this.clockInDatetime,
      clockOutDatetime: clockOutDatetime ?? this.clockOutDatetime,
      isBreak: isBreak ?? this.isBreak,
      modificationReason: modificationReason ?? this.modificationReason,
      isDeleted: isDeleted ?? this.isDeleted,
      shiftLogParentId: shiftLogParentId ?? this.shiftLogParentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ShiftLogModel.fromJson(Map<String, dynamic> json) =>
      _$ShiftLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$ShiftLogModelToJson(this);

  static final _listDateFormat = DateFormat.jm();
  String toHumanReadable(BuildContext context) =>
      '${_listDateFormat.format(clockInDatetime.toLocal())} - ${clockOutDatetime != null ? _listDateFormat.format(clockOutDatetime!.toLocal()) : AppLocalizations.of(context)!.ongoing}';
}
