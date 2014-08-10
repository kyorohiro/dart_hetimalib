part of hetima;

abstract class HetimaBuilder {
  async.Future<List<int>> getByteFuture(int index, int length);
  async.Completer completerFin = new async.Completer(); 
  int size();
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
}

class ArrayBuilderAdapter extends HetimaBuilder {
  HetimaBuilder _base = null;
  int _startIndex = 0;

  ArrayBuilderAdapter(HetimaBuilder builder, int startIndex) {
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
