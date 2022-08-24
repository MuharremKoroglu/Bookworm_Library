import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:library_management/models/book_model.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getBookListFromApi(
      String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }

  Future<void> deleteDocument(String referencePath, String id) async {
    await _firestore.collection(referencePath).doc(id).delete();
  }

  Future<void> setBookData(
      {String? collectionPath, Map<String, dynamic>? bookAsMap}) async {
    await _firestore
        .collection(collectionPath!)
        .doc(Book.fromMAap(bookAsMap!).id)
        .set(bookAsMap);
  }
}
