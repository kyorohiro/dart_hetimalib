part of hetima;

class TTFTableLoca {
  /// long
  ///   The actual local offset is stored. The value of n  is numGlyphs + 1.
  ///   The value for numGlyphs is found in the ‘maxp’ table.
  /// short
  ///   The actual local offset divided by 2 is stored. The value of n  is numGlyphs + 1.
  ///   The value for numGlyphs is found in the ‘maxp’ table.
  ///
  List<int> offsets = new List();
  /// 0 for short offsets, 1 for long.
  int indexToLocFormat = 0;
  int numGlyphs = 0;
  static async.Future<TTFTableLoca> loadTableLoca(EasyParser _parser, TTFTableDirectory _directory, TTFTableHead head, TTFTableMaxp maxp) {
    async.Completer<TTFTableLoca> c = new async.Completer();
    TTFTableLoca td = new TTFTableLoca();
    TTFTable loca = _directory.tableMap["loca"];
    if (loca == null) {
      c.completeError(new Error());
      return c.future;
    }

    td.indexToLocFormat = head.indexToLocFormat;
    td.numGlyphs = maxp.numGlyphs;
    _parser.resetIndex(loca.offset);
    int i = 0;
    foreach() {
      if (i < td.numGlyphs) {
        i++;
        if (td.indexToLocFormat == 0) {
          return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int v) {
            td.offsets.add(v);
            return foreach();
          });
        } else {
          return _parser.readInt(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int v) {
            td.offsets.add(v);
            return foreach();
          });
        }
      } else {
        c.complete(td);
      }
    }

    foreach().catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }
}


