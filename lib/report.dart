import 'package:hive/hive.dart';

part 'report.g.dart';

@HiveType(typeId: 1)
class Report {
  @HiveField(0)
  String companyName;
  @HiveField(1)
  String equipmentName;
  @HiveField(2)
  String modal;
  @HiveField(3)
  String serialNumber;
  @HiveField(4)
  String id;
  @HiveField(5)
  String year;
  @HiveField(6)
  String lastTUV;
  @HiveField(7)
  String capcity;
  @HiveField(8)
  String typeInspection;
  @HiveField(9)
  DateTime? dateOfSubmit;
  @HiveField(10)
  String timeSheet;
  @HiveField(11)
  String? result;
  @HiveField(12)
  String location;
  @HiveField(13)
  String comments;
  @HiveField(14)
  String? validation;
  @HiveField(15)
  String? stickerNumber;

  Report({
    required this.companyName,
    required this.equipmentName,
    required this.modal,
    required this.serialNumber,
    required this.id,
    required this.year,
    required this.lastTUV,
    required this.capcity,
    required this.typeInspection,
    required this.dateOfSubmit,
    required this.timeSheet,
    required this.result,
    required this.location,
    required this.comments,
    required this.validation,
    required this.stickerNumber,
  });
}
