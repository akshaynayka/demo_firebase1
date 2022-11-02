import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';
import '../../helpers/user_helper.dart';
import '../../models/user.dart';
import '../../common_methods/common_methods.dart';
import '../../common_methods/field_validator.dart';
import '../../values/api_end_points.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/text_form_field_widget.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isInit = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User? _userData = User(
    id: null,
    email: null,
    fullName: null,
    mobile: null,
    role: null,
    authId: null,
  );

  var _isLoading = true;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      _userData = await UsersHelper().getCurrentUserDetails();
      setState(() {
        _isLoading = false;
      });
    }
    setState(() {
      _isInit = false;
    });

    super.didChangeDependencies();
  }

  File? _pickedImage;

  void _imagePicker({required ImageSource source}) async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      // source: ImageSource.camera,
      source: source,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedImage == null) {
      return;
    }
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });

    // widget.imagePickFn(pickedImageFile);
  }

  Widget _imageSourceWidget(
      {required ImageSource source,
      required String title,
      required IconData icon}) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _imagePicker(source: source);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        height: 100,
        child: Column(
          children: [
            InkWell(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Icon(icon),
              ),
            ),
            Text(title)
          ],
        ),
      ),
    );
  }

  _showImageSourceBottomSheet() {
    return showModalBottomSheet(
        context: context,
        builder: (context) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageSourceWidget(
                    title: 'Gallery',
                    icon: Icons.photo,
                    source: ImageSource.gallery),
                _imageSourceWidget(
                    title: 'Camera',
                    icon: Icons.camera_alt_outlined,
                    source: ImageSource.camera),
              ],
            ));
  }

  Future<String?> _uploadImage() async {
    final now = DateTime.now();
    final uniqueName = now.microsecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance
        .ref()
        .child('userimages')
        .child('$uniqueName.jpg');
    await ref.putFile(_pickedImage!);

    final url = await ref.getDownloadURL();
    return url;
  }

  String _getFileName(String url) {
    RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
    //This Regex won't work if you remove ?alt...token
    var matches = regExp.allMatches(url);

    var match = matches.elementAt(0);
    return Uri.decodeFull(match.group(2)!);
  }

  Future<void> _deleteImageFromFirebase({required String? imageUrl}) async {
    if (imageUrl != null) {
      final fileName = _getFileName(imageUrl);
      final ref =
          FirebaseStorage.instance.ref().child('userimages').child(fileName);
      await ref.delete();
    }
  }

  void _submitForm() async {
    var messsage = appTitleSomethingWentWrong;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    final oldImageUrl = _userData!.imageUrl;
    if (_pickedImage != null) {
      _userData!.imageUrl = await _uploadImage();
    }

    _formKey.currentState!.save();
    try {
      if (_userData!.id != null) {
        final userInstance =
            FirebaseFirestore.instance.collection(apiUsers).doc(_userData!.id);
        await userInstance.update(_userData!.toJson()).then((value) {
          messsage = 'Profile updated';
          _deleteImageFromFirebase(imageUrl: oldImageUrl);
        });
      }

      displaySnackbar(context: _scaffoldKey.currentContext!, msg: messsage);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      const errorMessage = appTitleSomethingWentWrong;
      if (mounted) {
        showErrorDialog(errorMessage, context);
      }
    }

    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: const AppBarWidget(title: 'Profile'),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const CircularLoaderWidget()
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Container(
                      //   width: double.infinity,
                      //   decoration: BoxDecoration(
                      //     borderRadius: const BorderRadius.only(
                      //       bottomLeft: Radius.circular(60),
                      //       // bottomRight: Radius.circular(50),
                      //     ),
                      //     gradient: LinearGradient(
                      //       begin: Alignment.centerLeft,
                      //       end: Alignment.centerRight,
                      //       colors: <Color>[
                      //         Theme.of(context).primaryColor,
                      //         appColorSecondGradient,
                      //       ],
                      //     ),
                      //   ),
                      //   height: 70.0,
                      //   alignment: Alignment.topCenter,
                      //   child: const Text(
                      //     'Profile',
                      //     style: TextStyle(
                      //       fontSize: 25.0,
                      //       color: Colors.white,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(
                        height: 30.0,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 40.0,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!) as ImageProvider
                            : _userData!.imageUrl != null
                                ? NetworkImage(_userData!.imageUrl!)
                                : null,
                        child:
                            _pickedImage != null || _userData!.imageUrl != null
                                ? null
                                : Icon(
                                    Icons.person,
                                    size: 60.0,
                                    color: Colors.grey[200],
                                  ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            _showImageSourceBottomSheet();
                          },
                          child: const Text('pick image')),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _userData!.fullName,
                          lableText: appTitleFullName,
                          icon: Icons.construction_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _userData!.fullName = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _userData!.mobile,
                          lableText: appTitleFullName,
                          icon: Icons.construction_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _userData!.mobile = value!;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      RoundButtonWidget(
                        width: deviceSize.width * 0.5,
                        label: _userData!.id != null ? 'Update' : 'Add',
                        onPressed: _submitForm,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
