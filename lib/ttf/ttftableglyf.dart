part of hetima;

class TTFGlyf {
  int offset = 0;
/// SHORT
///   If the number of contours is greater than or equal to zero, this is a single glyph;
///   if negative, this is a composite glyph.
  int numberOfContours = 0;

/// FWORD Minimum x for coordinate data.
  int xMin = 0;

/// FWORD Minimum y for coordinate data.
  int yMin = 0;

/// FWORD Maximum x for coordinate data.
  int xMax = 0;

/// FWORD Maximum y for coordinate data.
  int yMax = 0;

/// USHORT Array of last points of each contour; n  is the number of contours.
  List<int> endPtsOfContours = new List();

/// USHORT Total number of bytes for instructions.
  int instructionLength = 0;

/// BYTE Array of instructions for each glyph; n  is the number of instructions.
  List<int> instructions = new List();

/// BYTE Array of flags for each coordinate in outline; n  is the number of flags.
  List<int> flags = new List();

/// BYTE or SHORT First coordinates relative to (0,0); others are relative to previous point.
  List<int> xCoordinates = new List();

/// BYTE or SHORT First coordinates relative to (0,0); others are relative to previous point.
  List<int> yCoordinates = new List();

  static async.Future<List<int>> loadFlags(EasyParser _parser, int count) {
    async.Completer<List<int>> completer = new async.Completer();
    List<int> ret = new List();
    int index = -1;
    a() {
      index++;
      if (index < count) {
        _parser.readByte(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int v) {
          ret.add(v);
          if ((0x08 & v) != 0) {
            return _parser
                .readByte(ByteOrder.BYTEORDER_BIG_ENDIAN)
                .then((int w) {
              int repeats = w;
              for (int j = 0; j < repeats; j++) {
                ret.add(v);
                index++;
              }
              a();
            });
          } else {
            a();
          }
        });
      } else {
        completer.complete(ret);        
      }
    }
    a();
    return completer.future;
  }

  static async.Future<List<int>> loadCoordX(
      EasyParser _parser, int count, List<int> flags) {
    return loadCoord(_parser, count, flags, 0x10, 0x02);
  }

  static async.Future<List<int>> loadCoordY(
      EasyParser _parser, int count, List<int> flags) {
    return loadCoord(_parser, count, flags, 0x20, 0x04);
  }

  static async.Future<List<int>> loadCoord(
      EasyParser _parser, int count, List<int> flags,
      [int dual = 0x10, int shortVector = 0x02]) {
    async.Completer<List<int>> completer = new async.Completer();
    List<int> ret = new List();
    int index = -1;
    int x = 0;
    a() {
     //print("ii=${count} ${index}\n");
      index++;
      if (count <= index) {
        completer.complete(ret);
        return null;
      }
      if ((flags[index] & dual) != 0) {
        if ((flags[index] & shortVector) != 0) {
          _parser.readByte(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int v) {
            x += v.toSigned(2 * 8);
            ret.add(x);
            a();
          }).catchError((e){
            print("error\n");
            completer.completeError(e);
          });
        } else {
          ret.add(x);
           a();
        }
      } else {
        if ((flags[index] & shortVector) != 0) {
          _parser.readByte(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int v) {
            x += -1 * v;
            ret.add(x);
            a();
          }).catchError((e){
            print("error\n");
            completer.completeError(e);
          });
        } else {
          _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int v) {
            x += v.toSigned(2 * 8);
            ret.add(x);
            a();
          }).catchError((e){
            print("error\n");
            completer.completeError(e);
          });
        }
      }
    }
    a();
    return completer.future;
  }

  static async.Future<TTFGlyf> loadGlyf(
      EasyParser _parser, TTFTableDirectory _directory, TTFTableLoca loca) {
    async.Completer<TTFGlyf> c = new async.Completer();
    TTFGlyf fd = new TTFGlyf();
    _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int v) {
      fd.numberOfContours = v.toSigned(16);
      return _parser.readShortArray(ByteOrder.BYTEORDER_BIG_ENDIAN, 4);
    }).then((List<int> v) {
      fd.xMin = v[0].toSigned(8 * 2);
      fd.yMin = v[1].toSigned(8 * 2);
      fd.xMax = v[2].toSigned(8 * 2);
      fd.yMax = v[3].toSigned(8 * 2);
      return _parser.readShortArray(
          ByteOrder.BYTEORDER_BIG_ENDIAN, fd.numberOfContours);
    }).then((List<int> v) {
      fd.endPtsOfContours = v;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int v) {
      fd.instructionLength = v;
      return _parser.nextBuffer(fd.instructionLength);
    }).then((List<int> v) {
      fd.instructions = v;
      //
      // read Glypf
      //

      //
      // The last end point index reveals the total number of points
      int totalOfCoordinates =
          fd.endPtsOfContours[fd.endPtsOfContours.length - 1] + 1;
      if(fd.numberOfContours >= 0) {
        // simple
        //print("simple ${fd.numberOfContours} ${totalOfCoordinates}\n");
        return loadFlags(_parser, totalOfCoordinates);
      } else {
        // composit
        print("composit\n");
        c.complete(fd);
      }
    }).then((List<int> v) {
      //print("f: ");
      fd.flags = v;
      int totalOfCoordinates =
          fd.endPtsOfContours[fd.endPtsOfContours.length - 1] + 1;
      return loadCoordX(_parser, totalOfCoordinates, fd.flags);
    }).then((List<int> v) {
      //print("xC: ");
      fd.xCoordinates = v;
      int totalOfCoordinates =
          fd.endPtsOfContours[fd.endPtsOfContours.length - 1] + 1;
      return loadCoordY(_parser, totalOfCoordinates, fd.flags);
    }).then((List<int> v) {
      //print("yC: \n");
      fd.yCoordinates = v;
      c.complete(fd);
    });

    return c.future;
  }
}

class TTFTableGlyf {
  /// long
  ///   The actual local offset is stored. The value of n  is numGlyphs + 1.
  ///   The value for numGlyphs is found in the ‘maxp’ table.
  /// short
  ///   The actual local offset divided by 2 is stored. The value of n  is numGlyphs + 1.
  ///   The value for numGlyphs is found in the ‘maxp’ table.
  ///
  ///
  int length = 0;
  List<TTFGlyf> glyfs = new List();

  static async.Future<TTFTableGlyf> loadTableGlyf(
      EasyParser _parser, TTFTableDirectory _directory, TTFTableLoca loca) {
    async.Completer<TTFTableGlyf> c = new async.Completer();
    TTFTable glyf = _directory.tableMap["glyf"];
    if (glyf == null) {
      c.completeError(new Error());
      return c.future;
    }

    TTFTableGlyf td = new TTFTableGlyf();
    td.length = loca.offsets.length;
    _parser.resetIndex(glyf.offset);
    int i = 0;
    print("td.length=${td.length}\n");
    foreachOffset() {
      print("i ${i} < td.length ${td.length}\n");
      if (i < td.length) {        
        int offset = glyf.offset + loca.offsets[i];
        i++;
        _parser.resetIndex(offset);
        TTFGlyf.loadGlyf(_parser, _directory, loca).then((TTFGlyf g) {
          td.glyfs.add(g);
          foreachOffset();
        }).catchError((e){
          c.completeError(e);
        });
      } else {
        c.complete(td);
      }
    }
    foreachOffset();
    return c.future;
  }
}
