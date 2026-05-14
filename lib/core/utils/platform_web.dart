import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
export 'package:web/web.dart';

String createBlobUrl(List<int> bytes, {String type = 'application/octet-stream'}) {
  final uint8List = Uint8List.fromList(bytes);
  final jsArray = [uint8List.toJS].toJS;
  final blob = web.Blob(jsArray, web.BlobPropertyBag(type: type));
  return web.URL.createObjectURL(blob);
}

void revokeBlobUrl(String url) {
  web.URL.revokeObjectURL(url);
}
