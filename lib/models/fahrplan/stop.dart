import 'package:relaa/models/fahrplan/fahrplan_dashboard.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'stop.g.dart';

@HiveType(typeId: 1)
class FahrplanStopItem {
  @HiveField(0)
  String title;
  @HiveField(1)
  DateTime time;
  @HiveField(2)
  late String uuid;

  FahrplanStopItem({
    required this.title,
    required this.time,
    String? uuid,
  }) {
    this.uuid = uuid ?? Uuid().v4();
  }

  FahrplanItem toFahrplanItem() {
    return FahrplanItem(
      title: title,
      hour: time.toLocal().hour,
      minute: time.toLocal().minute,
    );
  }
}
