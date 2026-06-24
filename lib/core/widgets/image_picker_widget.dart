import 'package:flutter/material.dart';
import '../services/cloudinary_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? currentImageUrl;
  final String folder;
  final Function(String url) onImageUploaded;
  final double size;
  final bool isCircle;

  const ImagePickerWidget({
    super.key,
    this.currentImageUrl,
    required this.folder,
    required this.onImageUploaded,
    this.size = 100,
    this.isCircle = false,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final _cloudinary = CloudinaryService();
  bool _isUploading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.currentImageUrl;
  }

  Future<void> _showOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFFFF6B35)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _upload(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFFFF6B35)),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _upload(fromCamera: true);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _upload({required bool fromCamera}) async {
    setState(() => _isUploading = true);
    try {
      final url = await _cloudinary.pickAndUpload(
        folder: widget.folder,
        fromCamera: fromCamera,
      );
      if (url != null) {
        setState(() => _imageUrl = url);
        widget.onImageUploaded(url);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _showOptions,
      child: widget.isCircle
          ? _buildCircle()
          : _buildRectangle(),
    );
  }

  Widget _buildCircle() {
    return Stack(
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF3F4F6),
            image: _imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(_imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _imageUrl == null
              ? Icon(
                  Icons.person,
                  size: widget.size * 0.5,
                  color: const Color(0xFF6B7280),
                )
              : null,
        ),
        if (_isUploading)
          Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black38,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRectangle() {
    return Container(
      width: double.infinity,
      height: widget.size,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          style: BorderStyle.solid,
        ),
        image: _imageUrl != null
            ? DecorationImage(
                image: NetworkImage(_imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: _isUploading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFFF6B35)),
            )
          : _imageUrl == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: Color(0xFF6B7280),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to add image',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}