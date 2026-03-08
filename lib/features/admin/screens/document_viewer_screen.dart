import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:html' as html;
import 'package:web/web.dart' as web;

class DocumentViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  // final bool isPdf;

  const DocumentViewerScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    // this.isPdf = false
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  // bool get _isPdf =>
  //     widget.imageUrl.toLowerCase().contains('.pdf') ||
  //     widget.imageUrl.toLowerCase().contains('application/pdf');

  // PDF state
  PdfController? _pdfController;
  String? _localPdfPath;
  bool _isLoadingPdf = true;
  String? _pdfError;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isPdf = false;
  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      final contentType = response.headers['content-type'] ?? '';
      final isPdf = contentType.contains('application/pdf');

      if (!isPdf) {
        setState(() {
          _isPdf = false;
          _isLoadingPdf = false;
        });
        return;
      }

      // Open PDF in a new browser tab using dart:html
      web.window.open(widget.imageUrl, '_blank', '');

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _pdfError = 'Error: $e';
        _isLoadingPdf = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_isPdf: $_isPdf');
    debugPrint('_isLoadingPdf: $_isLoadingPdf');
    debugPrint('_localPdfPath: $_localPdfPath');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_isPdf && _totalPages > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '${_currentPage + 1} / $_totalPages',
                style: const TextStyle(fontSize: 14),
              ),
            ),
        ],
      ),
      body: _isLoadingPdf
          ? _buildLoading()
          : _isPdf
              ? _buildPdfViewer()
              : _buildImageViewer(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading document...'),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return PhotoView(
      imageProvider: NetworkImage(widget.imageUrl),
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.broken_image, size: 60),
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (_isLoadingPdf) return _buildLoading();
    if (_pdfError != null || _pdfController == null) {
      return Center(child: Text(_pdfError ?? 'Failed to load PDF'));
    }

    return PdfView(
      controller: _pdfController!,
    );
  }
}
