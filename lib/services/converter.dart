import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Converter {
  static String dateTimeToString(DateTime? dateTime) {
    String convertedDate = DateFormat('dd-MM-yyyy').format(dateTime!);
    return convertedDate;
  }

  static Timestamp dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromMillisecondsSinceEpoch(
        dateTime.millisecondsSinceEpoch);
  }

  static DateTime dateTimeFromTimeStamp(Timestamp timeStamp) {
    return DateTime.fromMillisecondsSinceEpoch(timeStamp.seconds * 1000);
  }
}
