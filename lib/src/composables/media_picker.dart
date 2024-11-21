import 'package:study_cards/src/logic/language/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaPicker {
  static Future<String> pickImage(BuildContext cx) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await showDialog<XFile?>(
      context: cx,
      builder: (BuildContext context) => SimpleDialog(
        title: Text('select_source'.tr(cx)),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              picker.pickImage(source: ImageSource.camera).then((value) {
                if (context.mounted) {
                  Navigator.pop(context, value);
                }
              });
            },
            child: Text('camera'.tr(cx)),
          ),
          SimpleDialogOption(
            onPressed: () {
              picker.pickImage(source: ImageSource.gallery).then((value) {
                if (!context.mounted) return;
                Navigator.pop(context, value);
              });
            },
            child: Text('gallery'.tr(cx)),
          ),
        ],
      ),
    );
    return pickedFile!.path;
  }
}
