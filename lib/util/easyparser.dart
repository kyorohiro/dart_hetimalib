part of hetima;

class EasyParser {
  int index = 0;
  List<int> stack = new List();
  ArrayBuilder buffer = null;
  EasyParser(ArrayBuilder builder) {
    buffer = builder;
  }

  void push() {
    stack.add(index);
  }

  void back() {
    index = stack.last;
  }

  int pop() {
    int ret = stack.last;
    stack.remove(ret);
    return ret;
  }

  int last() {
    return stack.last;
  }

  async.Future<String> nextString(String value) {
    async.Completer completer = new async.Completer();
    List<int> encoded = convert.UTF8.encode(value);
    buffer.getByteFuture(index, encoded.length).then((List<int> v) {
      if (v.length != encoded.length) {
        throw new EasyParseError();
      }
      for (int e in v) {
        if (e != buffer.get(index)) {
          throw new EasyParseError();
        }
        index++;
      }
      completer.complete(value);
    });
    return completer.future;
  }

  async.Future<int> nextBytePattern(EasyParserMatcher matcher) {
    async.Completer completer = new async.Completer();
    buffer.getByteFuture(index, 1).then((List<int> v) {
      if (matcher.match(v[0])) {
        completer.complete(v);
      } else {
        throw new EasyParseError();
      }
    });
    return completer.future;
  }

  async.Future<List<int>> nextBytePatternWithLength(EasyParserMatcher matcher, int length) {
    async.Completer completer = new async.Completer();
    buffer.getByteFuture(index, length).then((List<int> va) {
      for (int v in va) {
        bool find = false;
        find = matcher.match(v);
        if (find == false) {
          throw new EasyParseError();
        }
      }
      completer.complete(va);
      throw new EasyParseError();
    });
    return completer.future;
  }

  List<int> current() {
    List<int> ret = new List();
    int i = proxy;
    for ( ; i < index; i++) {
      ret.add(buffer.get(i));
    }
    return ret;
  }
}

abstract class EasyParserMatcher {
  bool match(int target);
}

class EasyParserIncludeMatcher extends EasyParserMatcher {
  List<int> include = null;
  EasyParserIncludeMatcher(List<int> i) {
    include = i;
  }

  bool match(int target) {
    return include.contains(target);
  }
}
class EasyParseError extends Error {
  EasyParseError();
}
