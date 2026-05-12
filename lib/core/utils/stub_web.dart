// stub_web.dart
class Window {
  void open(String url, String name, [String? features]) {}
}

final window = Window();

class HTMLAnchorElement {
  String href = '';
  String download = '';
  void click() {}
  void remove() {}
}

class Document {
  final body = Body();
  HTMLAnchorElement createElement(String name) => HTMLAnchorElement();
}

class Body {
  void append(dynamic element) {}
}

final document = Document();

class URL {
  static String createObjectURL(dynamic blob) => '';
  static void revokeObjectURL(String url) {}
}

class Blob {
  Blob(dynamic parts, [dynamic options]);
}

class BlobPropertyBag {
  BlobPropertyBag({String? type});
}
