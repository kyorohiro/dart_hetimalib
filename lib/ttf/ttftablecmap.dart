part of hetima;

class TTFFormat0 {
  /// USHORT Format number is set to 0.
  int format = 0;
  /// USHORT This is the length in bytes of the subtable.
  int length = 0;
  /// USHORT Version number (starts at 0).
  int version = 0;
  /// BYTE [256] An array that maps character codes to glyph index values.
  List<int> glyphIdArray = new List();

  TTFFormat0(int aformat) {
    format = aformat;
  }

  static async.Future<TTFFormat0> loadFormat0(EasyParser _parser, int format) {
    async.Completer<TTFFormat0> c = new async.Completer();
    TTFFormat0 f = new TTFFormat0(format);
    _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int length) {
      f.length = length;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int version) {
      f.version = version;
      return _parser.nextBuffer(256);
    }).then((List<int> a) {
      f.glyphIdArray = a;
      c.complete(f);
    }).catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }
}



class TTFFormat4 {
  /// USHORT Format number is set to 4.
  int format = 0;

  /// USHORT Length in bytes.
  int length = 0;

  /// USHORT Version number (starts at 0).
  int version = 0;

  /// USHORT 2 x segCount.
  int segCountX2 = 0;

  /// USHORT 2 x (2**floor(log2(segCount)))
  int searchRange = 0;

  /// USHORT log2(searchRange/2)
  int entrySelector = 0;

  /// USHORT 2 x segCount - searchRange
  int rangeShift = 0;

  /// USHORT[segCount] End characterCode for each segment, last =0xFFFF.
  List<int> endCount = new List();

  /// USHORT Set to 0.
  int reservedPad = 0;

  /// USHORT[segCount] Start character code for each segment.
  List<int> startCount = new List();

  /// USHORT [segCount] Delta for all character codes in segment.
  List<int> idDelta = new List();

  /// USHORT [segCount] Offsets into glyphIdArray or 0
  List<int> idRangeOffset = new List();

  /// USHORT [] Glyph index array (arbitrary length)
  List<int> glyphIdArray = new List();

  TTFFormat4(int aformat) {
    format = aformat;
  }

  static async.Future<List<int>> _loadFormat4IdArray(EasyParser _parser, TTFFormat4 f) {
    async.Completer<List<int>> ccc = new async.Completer();
    int i = 0;
    int currentPosition = _parser.getInedx();
    List<int> glyphOffsetList = new List();
    List<int> glyphIdArray = new List();
    for (int i = 0; i < f.segCountX2 ~/ 2; i++) {
      print("AAA: ${i} < ${f.segCountX2} ${f.segCountX2 ~/ 2}\n");
      List<int> act = new List();
      int start = f.startCount[i];
      int end = f.endCount[i];
      int delta = f.idDelta[i];
      int rangeOffset = f.idRangeOffset[i];
      if (start != 65535 && end != 65535) {
        for (int j = start; j <= end; j++) {
          if (rangeOffset != 0) {
            int glyphOffset = currentPosition + ((rangeOffset ~/ 2) + (j - start) + (i - f.segCountX2 ~/ 2)) * 2;
            glyphOffsetList.add(glyphOffset);
          }
        }
      }
    }
    
    _parser.push();
    int k=0;
    int len = glyphOffsetList.length;
    a(){
      print("k=${k}\n");
      if(k >= len) {
        ccc.complete(glyphIdArray);
        return null;
      }
      int offset = glyphOffsetList[k];
      k++;
      _parser.resetIndex(offset);
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int v) {
        glyphIdArray.add(v);
        return a();
      });
    };
    a().whenComplete((){
      print("e=${k}\n");
      _parser.back();
      _parser.pop();
    });
    return ccc.future;
  }

  static async.Future<TTFFormat4> loadFormat4(EasyParser _parser, int format) {
    async.Completer<TTFFormat4> c = new async.Completer();
    TTFFormat4 f = new TTFFormat4(format);
    _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int length) {
      f.length = length;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int version) {
      f.version = version;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int segCountX2) {
      f.segCountX2 = segCountX2;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int searchRange) {
      f.searchRange = searchRange;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int entrySelector) {
      f.entrySelector = entrySelector;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int rangeShift) {
      f.rangeShift = rangeShift;
      return _parser.readShortArray(ByteOrder.BYTEORDER_BIG_ENDIAN, f.segCountX2 ~/ 2);
    }).then((List<int> endCount) {
      f.endCount = endCount;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int reservedPad) {
      f.reservedPad = reservedPad;
      return _parser.readShortArray(ByteOrder.BYTEORDER_BIG_ENDIAN, f.segCountX2 ~/ 2);
    }).then((List<int> startCount) {
      f.startCount = startCount;
      return _parser.readShortArray(ByteOrder.BYTEORDER_BIG_ENDIAN, f.segCountX2 ~/ 2);
    }).then((List<int> idDelta) {
      f.idDelta = idDelta;
      return _parser.readShortArray(ByteOrder.BYTEORDER_BIG_ENDIAN, f.segCountX2 ~/ 2);
    }).then((List<int> idRangeOffset) {
      f.idRangeOffset = idRangeOffset;
      return _parser.readShortArray(ByteOrder.BYTEORDER_BIG_ENDIAN, f.segCountX2 ~/ 2);
    }).then((List<int> idRangeOffset) {
      f.idRangeOffset = idRangeOffset;
      return _loadFormat4IdArray(_parser, f);
    }).then((List<int> glyphIdArray) {
      f.glyphIdArray = glyphIdArray;
      c.complete(f);
    }).catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }
}

class TTFEncodingTable {
  // --
  // ttf spec proc
  // --

  ///
  int cmapoffset = 0;
  /// USHORT Platform ID.
  int platformID = 0;
  /// USHORT Platform-specific encoding ID.
  int platformSpecificEncodingID = 0;
  /// ULONG Byte offset from beginning of table to the subtable for this encoding.
  int byteOffset = 0;
  /// USHORT
  int format = 0;

  // --
  // library proc
  // --
  int a = 0;
  Map<int, int> glayohIdToCharacterCode = new Map();

  TTFFormat0 format0 = null;
  static async.Future<TTFEncodingTable> loadEncodingTable(EasyParser _parser, int cmapoffset) {
    async.Completer<TTFEncodingTable> c = new async.Completer();
    TTFEncodingTable td = new TTFEncodingTable();
    td.cmapoffset = cmapoffset;
    _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int platformId) {
      td.platformID = platformId;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int id) {
      td.platformSpecificEncodingID = id;
      return _parser.readInt(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int offset) {
      td.byteOffset = offset;
      _parser.push();
      _parser.resetIndex(td.cmapoffset + td.byteOffset);
      _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int format) {
        print("format = ${format}\n");
        td.format = format;
        if (format == 0) {
          return TTFFormat0.loadFormat0(_parser, format).then((TTFFormat0 f) {
            print("### ${f.glyphIdArray.length}\n");
            for (int i = 0; i < f.glyphIdArray.length; i++) {
              td.glayohIdToCharacterCode[i] = f.glyphIdArray[i];
            }
          });
        } else if (format == 4) {
          return TTFFormat4.loadFormat4(_parser, format).then((TTFFormat4 f) {
            int seGCount = f.segCountX2 ~/ 2;
            int index = 0;
            
            for (int i = 0; i < seGCount; i++) {
              int start = f.startCount[i];
              int end = f.endCount[i];
              int delta = f.idDelta[i];
              int rangeOffset = f.idRangeOffset[i];
              
              if (start != 65535 && end != 65535) {
                for (int j = start; j <= end; j++) {
                  if (rangeOffset == 0) {
                    td.glayohIdToCharacterCode[j+delta] = j;
                  } else {
                    int glyphOffset = 
                        cmapoffset + 
                        ((rangeOffset~/2) + (j-start) + (i-seGCount))*2;
                    _parser.resetIndex(glyphOffset);
                    int glyphIndex = f.glyphIdArray[index];index++;
                    if(glyphIndex != 0) {
                      glyphIndex += delta;
                      td.glayohIdToCharacterCode[glyphIndex] = j;
                    }
                    // else {
                  }
                }
              }
              //if(start != 65535 & ..
            }
            // for (int i
          });
        }
      }).catchError((e) {
      }).whenComplete(() {
        _parser.back();
        _parser.pop();
        c.complete(td);
      });
//      _parser.resetIndex();

    }).catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }

  static async.Future<List<TTFEncodingTable>> loadEncodingTables(EasyParser _parser, int cmapoffset, int numberOfEncodingTables) {
    async.Completer<List<TTFEncodingTable>> c = new async.Completer();
    List<TTFEncodingTable> td = new List();
    int i = 0;
    a() {
      if (i < numberOfEncodingTables) {
        i++;
        return loadEncodingTable(_parser, cmapoffset).then((TTFEncodingTable table) {
          td.add(table);
          a();
        }).catchError((e) {
          c.completeError(e);
        });
      } else {
        c.complete(td);
      }
    }
    a();
    return c.future;
  }
}

class TTFTableCmap {

  /// USHORT Table version number (0).
  int tableVersionNumber = 0;
  /// USAHOR Number of encoding tables, n.
  int numberOfEncodingTables = 0;

  ///
  List<TTFEncodingTable> encodingTables = new List();

  static async.Future<TTFTableCmap> loadTableCmap(EasyParser _parser, TTFTableDirectory _directory) {//, TTFTableHead head, TTFTableMaxp maxp) {
    async.Completer<TTFTableCmap> c = new async.Completer();
    TTFTableCmap td = new TTFTableCmap();
    TTFTable cmap = _directory.tableMap["cmap"];
    if (cmap == null) {
      c.completeError(new Error());
      return c.future;
    }
    _parser.resetIndex(cmap.offset);
    _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int version) {
      td.tableVersionNumber = version;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int number) {
      td.numberOfEncodingTables = number;
      return TTFEncodingTable.loadEncodingTables(_parser, cmap.offset, td.numberOfEncodingTables);
    }).then((List<TTFEncodingTable> tables) {
      td.encodingTables = tables;
      c.complete(td);
    });
    return c.future;
  }
}
