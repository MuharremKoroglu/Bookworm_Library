import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowInfo {
  final String name;
  final String surName;
  final String photourl;
  final Timestamp borrowdate;
  final Timestamp returndate;

  BorrowInfo(
      {required this.name,
      required this.surName,
      required this.photourl,
      required this.borrowdate,
      required this.returndate});

  Map<String, dynamic> toMap() => {
        'name': name,
        'surName': surName,
        'photourl': photourl,
        'borrowdate': borrowdate,
        'returndate': returndate,
      };

  factory BorrowInfo.fromMAap(Map map) => BorrowInfo(
        name: map['name'],
        surName: map['surName'],
        photourl: map['photourl'],
        borrowdate: map['borrowdate'],
        returndate: map['returndate'],
      );
}
