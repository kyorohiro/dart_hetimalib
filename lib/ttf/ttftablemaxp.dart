part of hetima;
class TTFTableMaxp {
  /// Fixed 0x00010000 for version 1.0.
  int tableVersionNumber;
  /// USHORT The number of glyphs in the font.
  int numGlyphs;
  /// USHORT Maximum points in a non-composite glyph.
  int maxPoints;
  /// USHORT Maximum contours in a non-composite glyph.
  int maxContours;
  /// USHORT Maximum points in a composite glyph.
  int maxCompositePoints;
  /// USHORT Maximum contours in a composite glyph.
  int maxCompositeContours;
  /// USHORT 1 if instructions do not use the twilight zone (Z0), or 2 if instructions do use Z0; should be set to 2 in most cases.
  int maxZones;
  /// USHORT Maximum points used in Z0.
  int maxTwilightPoints;
  /// USHORT Number of Storage Area locations.
  int maxStorage;
  /// USHORT Number of FDEFs.
  int maxFunctionDefs;
  /// USHORT Number of IDEFs.
  int maxInstructionDefs;
  /// USHORT Maximum stack depth.
  int maxStackElements;
  /// USHORT Maximum byte count for glyph instructions.
  int maxSizeOfInstructions;
  /// USHORT Maximum number of components referenced at “top level” for any composite glyph.
  int maxComponentElements;
  /// USHORT Maximum levels of recursion; 1 for simple components.
  int maxComponentDepth;

  static async.Future<TTFTableMaxp> loadTableMaxp(EasyParser _parser, TTFTableDirectory _directory) {
    async.Completer<TTFTableMaxp> c = new async.Completer();
    TTFTableMaxp td = new TTFTableMaxp();
    TTFTable maxp = _directory.tableMap["maxp"];
    if (maxp == null) {
      c.completeError(new Error());
      return c.future;
    }
    _parser.resetIndex(maxp.offset);
    _parser.readInt(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int version) {
      td.tableVersionNumber = version;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int numGlyphs) {
      td.numGlyphs = numGlyphs;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxPoints) {
      td.maxPoints = maxPoints;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxContours) {
      td.maxContours = maxContours;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxCompositePoints) {
      td.maxCompositePoints = maxCompositePoints;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxCompositeContours) {
      td.maxCompositeContours = maxCompositeContours;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxZones) {
      td.maxZones = maxZones;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxTwilightPoints) {
      td.maxTwilightPoints = maxTwilightPoints;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxStorage) {
      td.maxStorage = maxStorage;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxFunctionDefs) {
      td.maxFunctionDefs = maxFunctionDefs;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxInstructionDefs) {
      td.maxInstructionDefs = maxInstructionDefs;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxStackElements) {
      td.maxStackElements = maxStackElements;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxSizeOfInstructions) {
      td.maxSizeOfInstructions = maxSizeOfInstructions;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxComponentElements) {
      td.maxComponentElements = maxComponentElements;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int maxComponentDepth) {
      td.maxComponentDepth = maxComponentDepth;
      c.complete(td);
    }).catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }
}

