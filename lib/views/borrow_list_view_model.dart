import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:library_management/models/barrow_model.dart';
import 'package:library_management/models/book_model.dart';
import 'package:library_management/services/database.dart';

class BorrowListViewModel with ChangeNotifier {
  Database _database = Database();
  String collectionPath = 'books';

  Future<void> updateBorrowStatus(
      {required List<BorrowInfo> borrowList, required Book book}) async {
    Book newBook = Book(
      id: book.id,
      bookName: book.bookName,
      authorName: book.authorName,
      publishDate: book.publishDate,
      borrows: borrowList,
    );

    await _database.setBookData(
      collectionPath: collectionPath,
      bookAsMap: newBook.toMap(),
    );
  }

  Future<void> deletePhoto(String photoUrl) async {
    Reference photoRef = FirebaseStorage.instance.refFromURL(photoUrl);
    await photoRef.delete();
  }
}
