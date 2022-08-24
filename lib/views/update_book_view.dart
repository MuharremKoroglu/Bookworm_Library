import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:library_management/services/converter.dart';
import 'package:library_management/views/update_book_view_model.dart';
import 'package:provider/provider.dart';

import '../models/book_model.dart';

class UpdateBookView extends StatefulWidget {
  final Book book;
  UpdateBookView({required this.book});

  @override
  State<UpdateBookView> createState() => _UpdateBookViewState();
}

class _UpdateBookViewState extends State<UpdateBookView> {
  TextEditingController bookController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController publishedController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  var _selectedDate;

  @override
  void dispose() {
    bookController.dispose();
    authorController.dispose();
    publishedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bookController.text = widget.book.bookName;
    authorController.text = widget.book.authorName;
    publishedController.text = Converter.dateTimeToString(
        Converter.dateTimeFromTimeStamp(widget.book.publishDate));

    return ChangeNotifierProvider<UpdateBookViewModel>(
      create: (_) => UpdateBookViewModel(),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text('Update Your Book'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: bookController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xFF403F35),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF403F35),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Color(0xFF403F35),
                        ),
                      ),
                      hintText: "Book Name",
                      prefixIcon: Icon(
                        Icons.book,
                        color: Color(0xFF403F35),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Book name cannot be empty';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: authorController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xFF403F35),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF403F35),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Color(0xFF403F35),
                        ),
                      ),
                      hintText: "Author Name",
                      prefixIcon: Icon(
                        Icons.edit,
                        color: Color(0xFF403F35),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Author name cannot be empty';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    onTap: () async {
                      _selectedDate = await showDatePicker(
                          context: context,
                          builder: (context, child) => Theme(
                              data: ThemeData().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFF403F35),
                                ),
                                dialogBackgroundColor: Color(0xFFBFA678),
                              ),
                              child: child!),
                          initialDate: DateTime.now(),
                          firstDate: DateTime(-1000),
                          lastDate: DateTime.now());

                      publishedController.text =
                          Converter.dateTimeToString(_selectedDate);
                    },
                    controller: publishedController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xFF403F35),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF403F35),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Color(0xFF403F35),
                        ),
                      ),
                      hintText: "Published Date",
                      prefixIcon: Icon(
                        Icons.calendar_month,
                        color: Color(0xFF403F35),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Published date cannot be empty';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await context.read<UpdateBookViewModel>().updateBook(
                              bookName: bookController.text,
                              authorName: authorController.text,
                              publishedDate: _selectedDate ??
                                  Converter.dateTimeFromTimeStamp(
                                      widget.book.publishDate),
                              book: widget.book,
                            );
                        await _Alert(DialogType.SUCCES, Colors.green, 'Succes',
                            'The new book successfully updated');
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Update',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _Alert(DialogType dialogType, Color buttonColor, String title,
      String desc) async {
    return await AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.BOTTOMSLIDE,
      title: title,
      desc: desc,
      btnCancelColor: buttonColor,
      btnCancelOnPress: () {},
    ).show();
  }
}
