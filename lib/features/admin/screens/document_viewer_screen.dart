import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:simple_file_saver/simple_file_saver.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String? imageUrl;
  final Uint8List? bytes;
  final String title;

  const DocumentViewerScreen({
    super.key,
    this.imageUrl,
    this.bytes,
    required this.title,
  }) : assert(imageUrl != null || bytes != null);

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  PdfController? _pdfController;
  bool _isLoading = true;
  String? _error;
  bool _isPdf = false;
  Uint8List? _documentBytes;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _initViewer();
  }

  Future<void> _initViewer() async {
    try {
      if (widget.bytes != null) {
        _documentBytes = widget.bytes;
        _pdfController = PdfController(
          document: PdfDocument.openData(_documentBytes!),
        );
        setState(() {
          _isPdf = true;
          _isLoading = false;
        });
        return;
      }

      if (widget.imageUrl != null) {
        final response = await http.get(Uri.parse(widget.imageUrl!));
        _documentBytes = response.bodyBytes;
        final contentType = response.headers['content-type'] ?? '';
        final isPdf = contentType.contains('application/pdf') || 
                      widget.imageUrl!.toLowerCase().contains('.pdf');

        if (isPdf) {
          _pdfController = PdfController(
            document: PdfDocument.openData(_documentBytes!),
          );
          setState(() {
            _isPdf = true;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isPdf = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading document: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile() async {
    if (_documentBytes == null) return;

    if (kIsWeb) {
      if (widget.imageUrl != null) {
        await launchUrl(Uri.parse(widget.imageUrl!), mode: LaunchMode.externalApplication);
      }
      return;
    }

    setState(() => _isDownloading = true);
    try {
      final basename = widget.title.replaceAll(' ', '_');
      final extension = _isPdf ? 'pdf' : 'jpg';
      
      final result = await SimpleFileSaver.saveFile(
        fileInfo: FileSaveInfo.fromBytes(
          bytes: _documentBytes!,
          basename: basename,
          extension: extension,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: $result')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save file: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (!_isLoading && _documentBytes != null)
            _isDownloading 
              ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
              : IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadFile,
                  tooltip: 'Download Document',
                ),
          if (_isPdf && widget.imageUrl != null)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => launchUrl(Uri.parse(widget.imageUrl!), mode: LaunchMode.externalApplication),
              tooltip: 'Open in Browser',
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? Center(child: Text(_error!))
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
      imageProvider: widget.bytes != null ? MemoryImage(widget.bytes!) : NetworkImage(widget.imageUrl!) as ImageProvider,
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.broken_image, size: 60),
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (_pdfController == null) return const Center(child: Text('Failed to load PDF'));
    
    // PdfView uses a PageView internally. For a scrollable list of all pages, 
    // we can use PdfViewBuilders or just trust the PdfView's swipe behavior 
    // and ensure it's not restricted. The user mentioned it only shows the first page.
    // Actually, PdfView should allow swiping. If they want a vertical scrollable list:
    
    return PdfView(
      controller: _pdfController!,
      scrollDirection: Axis.vertical,
    );
  }
}
