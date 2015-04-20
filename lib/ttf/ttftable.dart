part of hetima;
class TTFTable {
  String tag;
  int checksum;
  int offset;
  int length;

  static async.Future<TTFTable> loadTable(EasyParser _parser) {
    async.Completer completer = new async.Completer();
    TTFTable tb = new TTFTable();
    _parser.readSignWithLength(4).then((String tag) {
      tb.tag = tag;
      print("tag = ${tag}\n");
      return _parser.readInt(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int checkSum) {
      tb.checksum = checkSum;
      return _parser.readInt(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int offset) {
      tb.offset = offset;
      return _parser.readInt(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int length) {
      tb.length = length;
      completer.complete(tb);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  static async.Future<List<TTFTable>> loadTables(EasyParser _parser, int num) {
    async.Completer completer = new async.Completer();
    int i = 0;
    List<TTFTable> l = new List();
    a() {
      if (i < num) {
        i++;
        loadTable(_parser).then((TTFTable t) {
          l.add(t);
          a();
        });
      } else {
        completer.complete(l);
      }
    }
    a();
    return completer.future;
  }
}