import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cine_nest/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeleton_text/skeleton_text.dart';

class ProfileImage extends StatefulWidget {
  final String? imageUrl;
  final double height;
  final bool enableImageSelect;
  final Function(File)? onImageSelected;

  const ProfileImage({
    super.key,
    this.imageUrl,
    this.height = 60,
    this.enableImageSelect = false,
    this.onImageSelected,
  });

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'user_profile_image',
      child: GestureDetector(
        onTap: widget.enableImageSelect ? () => imageSourcePicker() : null,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple.shade200),
                  borderRadius: BorderRadius.circular(100)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!,
                        width: widget.height,
                        height: widget.height,
                        fit: BoxFit.cover)
                    : widget.imageUrl == null || widget.imageUrl!.isEmpty
                        ? _emptyImagePlaceholder()
                        : CachedNetworkImage(
                            imageUrl: widget.imageUrl!,
                            width: widget.height,
                            height: widget.height,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => SkeletonAnimation(
                                gradientColor: Colors.deepPurple.shade100,
                                shimmerColor: Colors.deepPurple.shade200,
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                    width: widget.height,
                                    height: widget.height,
                                    color: Colors.deepPurple.shade100)),
                            errorWidget: (context, url, error) =>
                                _emptyImagePlaceholder()),
              ),
            ),
            if (widget.enableImageSelect)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: widget.height / 3.5,
                  width: widget.height / 3.5,
                  decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(100)),
                  child: const Icon(CupertinoIcons.pen,
                      color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyImagePlaceholder() {
    return Container(
        width: widget.height,
        height: widget.height,
        decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.deepPurple.shade200)),
        child: Icon(CupertinoIcons.person,
            size: (widget.height / 5 * 3), color: Colors.white));
  }

  void imageSourcePicker() {
    showModalBottomSheet(
        barrierColor: Colors.deepPurple.withValues(alpha: 0.7),
        isScrollControlled: true,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.93,
            minWidth: double.infinity),
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).padding.left + 20,
                  right: MediaQuery.of(context).padding.left + 20,
                  top: 20,
                  bottom: MediaQuery.of(context).padding.bottom),
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Pick Image From',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  CustomButton(
                      onPressed: () async =>
                          pickImage(context, useCamera: false),
                      title: 'Browse Gallery'),
                  CustomButton(
                      onPressed: () async =>
                          pickImage(context, useCamera: true),
                      title: 'Use Camera',
                      inverseColors: true),
                ],
              ),
            ),
          );
        });
  }

  Future<void> pickImage(BuildContext context,
      {required bool useCamera}) async {
    Navigator.of(context).pop();
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
          source: useCamera ? ImageSource.camera : ImageSource.gallery);

      if (pickedFile != null) {
        File? croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          if (widget.onImageSelected != null) {
            widget.onImageSelected!(croppedFile);
          }
          setState(() => _selectedImage = croppedFile);
        }
      }
    } catch (e) {
      _showPermissionDialog();
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission required'),
        content: const Text(
            'We need access to your gallery to select a profile image. Please enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppSettings.openAppSettings(type: AppSettingsType.date);
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
