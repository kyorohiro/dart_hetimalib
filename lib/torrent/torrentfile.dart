part of hetima;

class TorrentFile {
  static final String KEY_ANNOUNCE = "announce";
  static final String KEY_NAME = "name";
  static final String KEY_INFO = "info";
  static final String KEY_FILES = "files";

  Map mMap = {};
  data.ByteBuffer piece = null;
  int piece_length = 0;

  TorrentFile.load(data.Uint8List buffer) {
    mMap = Bencode.decode(buffer);
  }

  String get announce {
    if (mMap.containsKey(KEY_ANNOUNCE)) {
      return mMap[KEY_ANNOUNCE];
    } else {
      return "";
    }
  }

  void set announce(String v) {
    mMap[KEY_ANNOUNCE] = v;
  }

  TorrentFileInfo get info {
    return new TorrentFileInfo(mMap);
  }
}

class TorrentFileInfo {
  Map mMap = {};
  String get name {
    if (mMap.containsKey(TorrentFile.KEY_ANNOUNCE)) {
      return mMap[TorrentFile.KEY_NAME];
    } else {
      return "";
    }
  }

  void set name(String v) {
    mMap[TorrentFile.KEY_NAME] = v;
  }

  TorrentFileFiles get files {
    return new TorrentFileFiles(mMap);
  }

  TorrentFileInfo(Map metadata) {
    mMap = metadata;
  }
}

class TorrentFileFiles {
  Map mMap = {};
  TorrentFileFiles(Map metadata) {
    mMap = metadata;
  }
  int get size {
    mMap.containsKey("");
    return 0;
  }
  List<String>path; 
}

class TorrentFileCreator 
{
  int piececSize = 16*1024;
  async.Completer<TorrentFileCreatorResult> load(HetimaFile target) {
    async.Completer<TorrentFileCreatorResult> ret = new async.Completer();
    return ret;
  }
}

class TorrentFileCreatorResult 
{
  
}

