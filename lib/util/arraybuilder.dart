part of hetima;

class ArrayBuilder {
  data.Uint8List _buffer8 = new data.Uint8List(1024);
  core.int _length = 0;

  void clear() {
    _length = 0;
  }

  core.int size() {
    return _length;
  }

  void appendString(core.String text) {
    core.List<core.int> code = convert.UTF8.encode(text);
    for (core.int i = 0; i < code.length; i++) {
      _buffer8[_length] = code[i];
      _length += 1;
    }
  }

  void appendUint8List(data.Uint8List buffer, core.int index, core.int length) {
    for (core.int i = 0; i < length; i++) {
      _buffer8[_length] = buffer[index + i];
      _length += 1;
    }
  }

  core.List toList() {
    return _buffer8.sublist(0, _length);
  }

  data.Uint8List toUint8List() {
    return new data.Uint8List.fromList(toList());
  }

  core.String toText() {
    return convert.UTF8.decode(toList());
  }
}
