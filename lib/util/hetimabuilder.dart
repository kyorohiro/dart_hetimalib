part of hetima;

abstract class HetimaBuilder {

  async.Future<List<int>> getByteFuture(int index, int length);

  int size();


  async.Completer completerFin = new async.Completer(); 
  async.Future<bool> onFin() {
    if(_immutable == true) {
      completerFin.complete(true);
    }
    return completerFin.future;
  }


  bool _immutable = false;
  bool get immutable => _immutable;
  void set immutable(bool v) {
    bool prev = _immutable;
    _immutable = v;
    if(prev == false && v== true) {
      completerFin.complete(v);
    }
  }

  static final int BYTEORDER_BIG_ENDIAN = 1;
  static final int BYTEORDER_LITTLE_ENDIAN = 0;

  static List<int> parseLongByte(int value, int byteorder) {
    List<int> ret = new List(8);
    if (byteorder == BYTEORDER_BIG_ENDIAN) {
      ret[0] = (value >> 56 & 0xff);
      ret[1] = (value >> 48 & 0xff);
      ret[2] = (value >> 40 & 0xff);
      ret[3] = (value >> 32 & 0xff);
      ret[4] = (value >> 24 & 0xff);
      ret[5] = (value >> 16 & 0xff);
      ret[6] = (value >> 8 & 0xff);
      ret[7] = (value >> 0 & 0xff);
    } else {
      ret[0] = (value >> 0 & 0xff);
      ret[1] = (value >> 8 & 0xff);
      ret[2] = (value >> 16 & 0xff);
      ret[3] = (value >> 24 & 0xff);
      ret[4] = (value >> 32 & 0xff);
      ret[5] = (value >> 40 & 0xff);
      ret[6] = (value >> 48 & 0xff);
      ret[7] = (value >> 56 & 0xff);
    }
    return ret;
  }

  static List<int> parseIntByte(int value, int byteorder) {
    List<int> ret = new List(4);
    if (byteorder == BYTEORDER_BIG_ENDIAN) {
      ret[0] = (value >> 24 & 0xff);
      ret[1] = (value >> 16 & 0xff);
      ret[2] = (value >> 8 & 0xff);
      ret[3] = (value >> 0 & 0xff);
    } else {
      ret[0] = (value >> 0 & 0xff);
      ret[1] = (value >> 8 & 0xff);
      ret[2] = (value >> 16 & 0xff);
      ret[3] = (value >> 24 & 0xff);
    }
    return ret;
  }

  static List<int> parseShortByte(int value, int byteorder) {
    List<int> ret = new List(4);
    if (byteorder == BYTEORDER_BIG_ENDIAN) {
      ret[0] = (value >> 8 & 0xff);
      ret[1] = (value >> 0 & 0xff);
    } else {
      ret[0] = (value >> 0 & 0xff);
      ret[1] = (value >> 8 & 0xff);
    }
    return ret;
  }

  static int parseShort(List<int> value, int start, int byteorder) {
    int ret = 0;
    if (byteorder == BYTEORDER_BIG_ENDIAN) {
      ret = ret | ((value[0 + start] & 0xff) << 8);
      ret = ret | ((value[1 + start] & 0xff) << 0);
    } else {
      ret = ret | ((value[1 + start] & 0xff) << 8);
      ret = ret | ((value[0 + start] & 0xff) << 0);
    }
    return ret;
  }
  static int parseInt(List<int> value, int start, int byteorder) {
    int ret = 0;
    if (byteorder == BYTEORDER_BIG_ENDIAN) {
      ret = ret | ((value[0 + start] & 0xff) << 24);
      ret = ret | ((value[1 + start] & 0xff) << 16);
      ret = ret | ((value[2 + start] & 0xff) << 8);
      ret = ret | ((value[3 + start] & 0xff) << 0);
    } else {
      ret = ret | ((value[3 + start] & 0xff) << 24);
      ret = ret | ((value[2 + start] & 0xff) << 16);
      ret = ret | ((value[1 + start] & 0xff) << 8);
      ret = ret | ((value[0 + start] & 0xff) << 0);
    }
    return ret;
  }
  static int parseLong(List<int> value, int start, int byteorder) {
    int ret = 0;
    if (byteorder == BYTEORDER_BIG_ENDIAN) {
      ret = ret | ((value[0 + start] & 0xff) << 56);
      ret = ret | ((value[1 + start] & 0xff) << 48);
      ret = ret | ((value[2 + start] & 0xff) << 40);
      ret = ret | ((value[3 + start] & 0xff) << 32);
      ret = ret | ((value[4 + start] & 0xff) << 24);
      ret = ret | ((value[5 + start] & 0xff) << 16);
      ret = ret | ((value[6 + start] & 0xff) << 8);
      ret = ret | ((value[7 + start] & 0xff) << 0);
    } else {
      ret = ret | ((value[7 + start] & 0xff) << 56);
      ret = ret | ((value[6 + start] & 0xff) << 48);
      ret = ret | ((value[5 + start] & 0xff) << 40);
      ret = ret | ((value[4 + start] & 0xff) << 32);
      ret = ret | ((value[3 + start] & 0xff) << 24);
      ret = ret | ((value[2 + start] & 0xff) << 16);
      ret = ret | ((value[1 + start] & 0xff) << 8);
      ret = ret | ((value[0 + start] & 0xff) << 0);
    }
    return ret;
  }

}

class HetimaBuilderAdapter extends HetimaBuilder {
  HetimaBuilder _base = null;
  int _startIndex = 0;

  HetimaBuilderAdapter(HetimaBuilder builder, int startIndex) {
    _base = builder;
    _startIndex = startIndex;
  }

  int size() {
    return _base.size() - _startIndex;
  }

  async.Future<bool> onFin() {
   return _base.onFin();
  }

  async.Future<List<int>> getByteFuture(int index, int length) {
    async.Completer<List<int>> completer = new async.Completer();

    _base.getByteFuture(index + _startIndex, length).then((List<int> d) {
      completer.complete(d);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }
}
