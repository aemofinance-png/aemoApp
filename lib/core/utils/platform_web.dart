import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
export 'package:web/web.dart';

String createBlobUrl(List<int> bytes) {
  final uint8List = Uint8List.fromList(bytes);
  final jsArray = [uint8List.toJS].toJS;
  final blob = web.Blob(jsArray);
  return web.URL.createObjectURL(blob);
}

void revokeBlobUrl(String url) {
  web.URL.revokeObjectURL(url);
}
