import 'package:flutter/material.dart';
import 'package:library_management/models/book_model.dart';
import 'package:library_management/services/converter.dart';
import 'package:library_management/services/database.dart';

class UpdateBookViewModel extends ChangeNotifier {
  final Database _database = Database();
  String collectionPath = 'books';

  Future<void> updateBook({
    required String bookName,
    required String authorName,
    required DateTime publishedDate,
    required Book book,
  }) async {
    Book newBook = Book(
      id: book.id,
      bookName: bookName,
      authorName: authorName,
      publishDate: Converter.dateTimeToTimestamp(publishedDate),
      borrows: book.borrows,
    );

    await _database.setBookData(
        collectionPath: collectionPath, bookAsMap: newBook.toMap());
  }
}
