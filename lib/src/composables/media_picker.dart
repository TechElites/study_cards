import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaPicker {
  static Future<String> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: const Text('Select source'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              picker
                  .pickImage(source: ImageSource.camera)
                  .then((value) => Navigator.pop(context, value));
            },
            child: const Text('Camera'),
          ),
          SimpleDialogOption(
            onPressed: () {
              picker
                  .pickImage(source: ImageSource.gallery)
                  .then((value) => Navigator.pop(context, value));
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
    return pickedFile!.path;
  }
}
