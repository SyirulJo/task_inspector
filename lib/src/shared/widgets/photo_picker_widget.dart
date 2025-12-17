import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPickerWidget extends StatefulWidget {
  final Function(List<String>) onPhotosChanged;
  final int maxPhotos;

  const PhotoPickerWidget({
    super.key,
    required this.onPhotosChanged,
    this.maxPhotos = 5,
  });

  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  final List<String> _photos = []; // Base64 encoded
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (_photos.length >= widget.maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum ${widget.maxPhotos} photos allowed')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        setState(() {
          _photos.add(base64Image);
        });
        widget.onPhotosChanged(_photos);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    if (_photos.length >= widget.maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum ${widget.maxPhotos} photos allowed')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        setState(() {
          _photos.add(base64Image);
        });
        widget.onPhotosChanged(_photos);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
    widget.onPhotosChanged(_photos);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Photos (${_photos.length}/${widget.maxPhotos})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            IconButton.filled(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              tooltip: 'Take Photo',
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              tooltip: 'Choose from Gallery',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_photos.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No photos added yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _photos.asMap().entries.map((entry) {
              final index = entry.key;
              final photo = entry.value;
              final bytes = base64Decode(photo);

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      Uint8List.fromList(bytes),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }
}
