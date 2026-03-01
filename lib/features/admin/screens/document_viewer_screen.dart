import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String title;

  const DocumentViewerScreen({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, size: 60),
        ),
      ),
    );
  }
}
