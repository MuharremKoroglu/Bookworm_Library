import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:library_management/models/book_model.dart';
import 'package:library_management/views/add_book_view.dart';
import 'package:library_management/views/books_view_model.dart';
import 'package:library_management/views/borrow_list_view.dart';
import 'package:library_management/views/update_book_view.dart';
import 'package:provider/provider.dart';

class BooksView extends StatefulWidget {
  const BooksView({Key? key}) : super(key: key);

  @override
  State<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends State<BooksView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BooksViewModel>(
      create: (_) => BooksViewModel(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'bookworm library'.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<List<Book>>(
                stream: Provider.of<BooksViewModel>(context, listen: false)
                    .getBookList(),
                builder: (BuildContext context, asyncSnapshot) {
                  if (asyncSnapshot.hasError) {
                    return Center(
                      child: Text('ERROR!'),
                    );
                  } else {
                    if (!asyncSnapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF403F35),
                        ),
                      );
                    } else {
                      List<Book>? _kitapRef = asyncSnapshot.data;
                      return BuildListView(kitapRef: _kitapRef);
                    }
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddBookView()));
                },
                child: Text(
                  'Add New Book',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuildListView extends StatefulWidget {
  const BuildListView({
    Key? key,
    required this.kitapRef,
  });

  final List<Book>? kitapRef;

  @override
  State<BuildListView> createState() => _BuildListViewState();
}

class _BuildListViewState extends State<BuildListView> {
  bool isFiltering = false;
  var filteredList;
  @override
  Widget build(BuildContext context) {
    var completedList = widget.kitapRef;
    return Flexible(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFFF2E6D0),
                ),
                hintText: 'Search Book',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: Color(0xFF403F35),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: Color(0xFF403F35),
                  ),
                ),
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  isFiltering = true;
                  setState(() {
                    filteredList = completedList
                        ?.where((book) => book.bookName
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();
                  });
                } else {
                  WidgetsBinding.instance.focusManager.primaryFocus!.unfocus();
                  setState(() {
                    isFiltering = false;
                  });
                }
              },
            ),
          ),
          Flexible(
            child: ListView.builder(
                itemCount:
                    isFiltering ? filteredList.length : completedList?.length,
                itemBuilder: (context, index) {
                  var list = isFiltering ? filteredList : completedList;
                  return Slidable(
                    startActionPane: ActionPane(
                      extentRatio: 0.2,
                      motion: DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BorrowListView(book: list[index]),
                              ),
                            );
                          },
                          backgroundColor: Color(0xFF4caf50),
                          foregroundColor: Colors.white,
                          icon: Icons.supervisor_account,
                          label: 'Borrow',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      extentRatio: 0.4,
                      motion: DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) async {
                            await Provider.of<BooksViewModel>(context,
                                    listen: false)
                                .deleteBook(list[index]);
                          },
                          backgroundColor: Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          onPressed: (_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UpdateBookView(book: list[index]),
                              ),
                            );
                          },
                          backgroundColor: Color(0xFF21B7CA),
                          foregroundColor: Colors.white,
                          icon: Icons.border_color,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    key: UniqueKey(),
                    child: Card(
                      child: ListTile(
                        title: Text(
                          list![index].bookName,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          list[index].authorName,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
