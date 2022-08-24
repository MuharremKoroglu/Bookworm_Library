import 'package:flutter/material.dart';
import 'package:library_management/models/book_model.dart';
import 'package:library_management/services/converter.dart';
import 'package:library_management/services/database.dart';

class AddBookViewModel extends ChangeNotifier {
  final Database _database = Database();
  String collectionPath = 'books';

  Future<void> addNewBook(
      {required String bookName,
      required String authorName,
      required DateTime publishedDate}) async {
    Book newBook = Book(
      id: DateTime.now().toIso8601String(),
      bookName: bookName,
      authorName: authorName,
      publishDate: Converter.dateTimeToTimestamp(publishedDate),
      borrows: [],
    );

    await _database.setBookData(
        collectionPath: collectionPath, bookAsMap: newBook.toMap());
  }
}
