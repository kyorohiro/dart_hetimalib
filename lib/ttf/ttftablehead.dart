part of hetima;

class TTFTableHead {
  /// FIXED 0x00010000 for version 1.0.
  int tableVersionNumber;

  /// FIXED Set by font manufacturer.
  int fontRevision;

  /// ULONG To compute:  set it to 0, sum the entire font as ULONG, then store 0xB1B0AFBA - sum.
  int checkSumAdjustment;

  /// ULONG Set to 0x5F0F3CF5.
  int magicNumber;

  /// USHORT
  /// Bit 0 - baseline for font at y=0;
  /// Bit 1 - left sidebearing at x=0;
  /// Bit 2 - instructions may depend on point size;
  /// Bit 3 - force ppem to integer values for all internal scaler math; may use fractional ppem sizes if this bit is clear;
  /// Bit 4 - instructions may alter advance width (the advance widths might not scale linearly);
  /// Note: All other bits must be zero.
  int flags;

  /// USHORT Valid range is from 16 to 16384
  int unitsPerEm;

  /// longDateTime International date (8-byte field).
  int created;

  /// longDateTime International date (8-byte field).
  int modified;

  /// FWORD For all glyph bounding boxes.
  int xMin;

  /// FWORD For all glyph bounding boxes.
  int yMin;

  /// FWORD For all glyph bounding boxes.
  int xMax;

  /// FWORD For all glyph bounding boxes.
  int yMax;

  /// Bit 0 bold (if set to 1); Bit 1 italic (if set to 1)
  /// Bits 2-15 reserved (set to 0).
  int macStyle;

  /// USHORT
  /// Smallest readable size in pixels.
  int lowestRecPPEM;

  /// SHORT
  /// 0   Fully mixed directional glyphs;
  /// 1   Only strongly left to right;
  /// 2   Like 1 but also contains neutrals;
  /// -1   Only strongly right to left;
  /// -2   Like -1 but also contains neutrals.
  int fontDirectionHint;

  /// SHORT 0 for short offsets, 1 for long.
  int indexToLocFormat;

  /// SHORT 0 for current format.
  int glyphDataFormat;

  static async.Future<TTFTableHead> loadTableHead(EasyParser _parser, TTFTableDirectory _directory) {
    async.Completer<TTFTableHead> c = new async.Completer();
    TTFTableHead td = new TTFTableHead();
    TTFTable head = _directory.tableMap["head"];
    if (head == null) {
      c.completeError(new Error());
      return c.future;
    }
    _parser.resetIndex(head.offset);
    _parser.readInt(ByteOrder.BYTEORDER_BIG_ENDIAN).then((int version) {
      td.tableVersionNumber = version;
      return _parser.readInt(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int fontRevision) {
      td.fontRevision = fontRevision;
      return _parser.readInt(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int checkSumAdjustment) {
      td.checkSumAdjustment = checkSumAdjustment;
      return _parser.readInt(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int magicNumber) {
      td.magicNumber = magicNumber;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int flags) {
      td.flags = flags;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int unitsPerEm) {
      td.unitsPerEm = unitsPerEm;
      return _parser.readLong(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int created) {
      td.created = created;
      return _parser.readLong(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int modified) {
      td.modified = modified;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int xMin) {
      td.xMin = xMin.toSigned(2 * 8);
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int yMin) {
      td.yMin = yMin.toSigned(2 * 8);
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int xMax) {
      td.xMax = xMax.toSigned(2 * 8);
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int yMax) {
      td.yMax = yMax.toSigned(2 * 8);
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int macStyle) {
      td.macStyle = macStyle;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int lowestRecPPEM) {
      td.lowestRecPPEM = lowestRecPPEM;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int fontDirectionHint) {
      td.fontDirectionHint = fontDirectionHint;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int indexToLocFormat) {
      td.indexToLocFormat = indexToLocFormat;
      return _parser.readShort(ByteOrder.BYTEORDER_BIG_ENDIAN);
    }).then((int glyphDataFormat) {
      td.glyphDataFormat = glyphDataFormat;
    }).then((Object o) {
      c.complete(td);
    }).catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }
}

