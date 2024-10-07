import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({
    required this.selectImage,
    super.key,
  });

  final Function(File? image) selectImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _takePhoto() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }

    widget.selectImage(_selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: ElevatedButton.icon(
        onPressed: _takePhoto,
        icon: const Icon(Icons.camera),
        label: const Text('Take photo'),
      ),
    );

    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takePhoto,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.fitHeight,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary.withOpacity(.2),
        ),
      ),
      child: content,
    );
  }
}
