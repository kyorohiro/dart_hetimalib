part of hetima;


class TTF {
  EasyParser _parser;
  TTFTableDirectory _tableDirectory;

  TTF.fromHetimaFile(HetimaFile builder) {
    _parser = new EasyParser(new HetimaFileToBuilder(builder));
    _tableDirectory = new TTFTableDirectory();
  }

  TTF.fromHetimaBuilder(HetimaBuilder builder) {
    _parser = new EasyParser(builder);
    _tableDirectory = new TTFTableDirectory();
  }

  async.Future<TTFTableDirectory> loadTableDirectory() {
    return _tableDirectory.loadTableDirectory(_parser);
  }

  async.Future<TTFTableHead> loadTableHead(TTFTableDirectory _directory) {
    return TTFTableHead.loadTableHead(_parser, _directory);
  }

  async.Future<TTFTableMaxp> loadTableMaxp(TTFTableDirectory _directory) {
    return TTFTableMaxp.loadTableMaxp(_parser, _directory);
  }
  
  async.Future<TTFTableLoca> loadTableLoca(TTFTableDirectory _directory, TTFTableHead head, TTFTableMaxp maxp) {
    return TTFTableLoca.loadTableLoca(_parser, _directory, head, maxp);
  }

  async.Future<TTFTableCmap> loadTableCmap(TTFTableDirectory _directory) {
    return TTFTableCmap.loadTableCmap(_parser, _directory);
  }

  async.Future<TTFTableGlyf> loadTableGlyf(TTFTableDirectory _directory, TTFTableLoca loca) {
    return TTFTableGlyf.loadTableGlyf(_parser, _directory, loca);
  }
}

