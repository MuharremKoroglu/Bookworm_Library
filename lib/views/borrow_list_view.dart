import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:library_management/models/barrow_model.dart';
import 'package:library_management/models/book_model.dart';
import 'package:library_management/services/converter.dart';
import 'package:library_management/views/borrow_list_view_model.dart';
import 'package:provider/provider.dart';

class BorrowListView extends StatefulWidget {
  final Book book;
  BorrowListView({required this.book});

  @override
  State<BorrowListView> createState() => _BorrowListState();
}

class _BorrowListState extends State<BorrowListView> {
  @override
  Widget build(BuildContext context) {
    List<BorrowInfo> borrowList = widget.book.borrows;
    return ChangeNotifierProvider<BorrowListViewModel>(
      create: (context) => BorrowListViewModel(),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text('${widget.book.bookName} Borrow Status'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          borrowList[index].photourl,
                        ),
                      ),
                      title: Text(
                          '${borrowList[index].name} ${borrowList[index].surName}'),
                    );
                  },
                  separatorBuilder: (context, _) => Divider(),
                  itemCount: borrowList.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    BorrowInfo newBorrowInfo = await showModalBottomSheet(
                      isDismissible: false,
                      enableDrag: false,
                      isScrollControlled: true,
                      context: context,
                      backgroundColor: Color(0xFFBFA678),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      builder: (context) {
                        return WillPopScope(
                            onWillPop: () async {
                              return false;
                            },
                            child: BorrowForm());
                      },
                    );
                    if (newBorrowInfo != null) {
                      setState(() {
                        borrowList.add(newBorrowInfo);
                      });
                      context.read<BorrowListViewModel>().updateBorrowStatus(
                          borrowList: borrowList, book: widget.book);
                    }
                  },
                  child: Text(
                    'New Borrow Registration',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BorrowForm extends StatefulWidget {
  @override
  State<BorrowForm> createState() => _BorrowFormState();
}

class _BorrowFormState extends State<BorrowForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController borrowController = TextEditingController();
  TextEditingController returnController = TextEditingController();

  var _selectedBorrowDate;
  var _selectedReturnDate;

  final _formKey = GlobalKey<FormState>();

  File? _image;
  final picker = ImagePicker();
  String? _photoUrl;

  Future getImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected');
      }
    });

    if (pickedFile != null) {
      _photoUrl = await uploadImagetoStorage(_image!);
    }
  }

  Future<String> uploadImagetoStorage(File imageFile) async {
    String path = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    TaskSnapshot uploadTask =
        await FirebaseStorage.instance.ref().child(path).putFile(_image!);

    String uploadedImageUrl = await uploadTask.ref.getDownloadURL();
    return uploadedImageUrl;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    borrowController.dispose();
    returnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BorrowListViewModel(),
      builder: (context, _) => Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: (_image == null)
                    ? NetworkImage(
                        'https://i.pinimg.com/736x/c9/e3/e8/c9e3e810a8066b885ca4e882460785fa.jpg')
                    : FileImage(_image!) as ImageProvider,
                radius: 50,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: -5,
                      right: -10,
                      child: IconButton(
                        onPressed: getImage,
                        icon: Icon(Icons.photo_camera),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: TextFormField(
                            controller: nameController,
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
                              hintText: "Name",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0xFF403F35),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name cannot be empty';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextFormField(
                            controller: surnameController,
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
                              hintText: "Surname",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0xFF403F35),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Surname cannot be empty';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: TextFormField(
                            showCursor: false,
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              _selectedBorrowDate = await showDatePicker(
                                  context: context,
                                  builder: (context, child) => Theme(
                                      data: ThemeData().copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Color(0xFF403F35),
                                        ),
                                        dialogBackgroundColor:
                                            Color(0xFFBFA678),
                                      ),
                                      child: child!),
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate:
                                      DateTime.now().add(Duration(days: 365)));

                              borrowController.text =
                                  Converter.dateTimeToString(
                                      _selectedBorrowDate);
                            },
                            controller: borrowController,
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
                              hintText: "Borrow Date",
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                color: Color(0xFF403F35),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Borrow date cannot be empty';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextFormField(
                            showCursor: false,
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              _selectedReturnDate = await showDatePicker(
                                  context: context,
                                  builder: (context, child) => Theme(
                                      data: ThemeData().copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Color(0xFF403F35),
                                        ),
                                        dialogBackgroundColor:
                                            Color(0xFFBFA678),
                                      ),
                                      child: child!),
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate:
                                      DateTime.now().add(Duration(days: 365)));

                              returnController.text =
                                  Converter.dateTimeToString(
                                      _selectedReturnDate);
                            },
                            controller: returnController,
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
                              hintText: "Return Date",
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                color: Color(0xFF403F35),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Return date cannot be empty';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          BorrowInfo newBorrowInfo = BorrowInfo(
                              name: nameController.text,
                              surName: surnameController.text,
                              photourl: _photoUrl ??
                                  'https://i.pinimg.com/736x/c9/e3/e8/c9e3e810a8066b885ca4e882460785fa.jpg',
                              borrowdate: Converter.dateTimeToTimestamp(
                                  _selectedBorrowDate!),
                              returndate: Converter.dateTimeToTimestamp(
                                  _selectedReturnDate!));
                          Navigator.pop(context, newBorrowInfo);
                        }
                      },
                      child: Text(
                        'Create a New Borrow',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_photoUrl != null) {
                          context
                              .read<BorrowListViewModel>()
                              .deletePhoto(_photoUrl!);
                        }
                        Navigator.pop(context);
                      },
                      child: Text('Close'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
