part of hetima;

class TTFTableDirectory {
  int sfntVersion = 0;// 0x00010000 for version 1.0.
  int numTables = 0;//Number of tables.
  int searchRange = 0;//(Maximum power of 2 ≤ numTables) x 16.
  int entrySelector = 0;//Log2(maximum power of 2 ≤ numTables).
  int rangeShift = 0;//NumTables x 16-searchRange.
  Map<String, TTFTable> tableMap = new Map();

  async.Future<TTFTableDirectory> loadTableDirectory(EasyParser _parser) {
    async.Completer<TTFTableDirectory> c = new async.Completer();
    TTFTableDirectory td = new TTFTableDirectory();
    _parser.readInt(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int version) {
      td.sfntVersion = version;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int numTables) {
      td.numTables = numTables;
      print("numTables ${td.numTables}\n");
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int searchRange) {
      td.searchRange = searchRange;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int entrySelector) {
      td.entrySelector = entrySelector;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int rangeShift) {
      td.rangeShift = rangeShift;
      return TTFTable.loadTables(_parser, td.numTables);
    }).then((List<TTFTable> l) {
      for (TTFTable t in l) {
        print("${t.tag}\n");
        td.tableMap[t.tag] = t;
      }
      c.complete(td);
    }).catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }
}

