import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:library_management/models/book_model.dart';
import 'package:library_management/services/database.dart';

class BooksViewModel extends ChangeNotifier {
  final String _collectionPath = 'books';
  final Database _database = Database();

  dynamic getBookList() {
    Stream<List<DocumentSnapshot>> streamListDocument = _database
        .getBookListFromApi(_collectionPath)
        .map((querySnapshot) => querySnapshot.docs);
    var streamListBook = streamListDocument.map((listOfDocSnap) => listOfDocSnap
        .map((docSnap) => Book.fromMAap(docSnap.data() as Map<String, dynamic>))
        .toList());

    return streamListBook;
  }

  Future<void> deleteBook(Book book) async {
    await _database.deleteDocument(_collectionPath, book.id);
  }
}
