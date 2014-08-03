part of hetima;
class HetiHttpGet {
  HetiSocketBuilder _builder;
  HetiSocket socket = null;

  HetiHttpGet(HetiSocketBuilder builder) {
    _builder = builder;
  }

  async.Future<int> connect(String host, int port) {
    async.Completer<int> completer = new async.Completer();
    socket = _builder.createClient();
    socket.connect(host, port).then((HetiSocket socket) {
      if (socket == null) {
        completer.complete(-999);
      } else {
        completer.complete(1);
      }
    });
    return completer.future;
  }

  async.Future<HetiHttpResponse> get(String host, int port, String path) {
    ArrayBuilder builder = new ArrayBuilder();
    builder.appendString("GET" + " " + path + " " + "HTTP/1.1" + "\r\n");
    builder.appendString("Host:" + " " + host + "\r\n");
    socket.onReceive().listen((HetiReceiveInfo info) {
    });
    socket.send(builder.toList()).then((HetiSendInfo info) {
    });
    return null;
  }

  void close() {
    if (socket != null) {
      socket.close();
    }
  }
}

//rfc2616 7230
class HetiHttpResponse {
  static List<int> PATH = convert.UTF8.encode(RfcTable.RFC3986_PCHAR_AS_STRING + "/");
  static List<int> QUERY = convert.UTF8.encode(RfcTable.RFC3986_RESERVED_AS_STRING + RfcTable.RFC3986_UNRESERVED_AS_STRING);

  static async.Future<HetiHttpResponse> decode(ArrayBuilder builder) {
    EasyParser parser = new EasyParser(builder);
    try {
      parser.nextString("HTTP" + "/").then((String v) {
      }).then((e) {
        return parser.nextBytePattern(new EasyParserIncludeMatcher(RfcTable.DIGIT));
      }).then((e) {
        parser.nextString(".");
      }).then((e) {
        return parser.nextBytePattern(new EasyParserIncludeMatcher(RfcTable.DIGIT));
      });
    } catch (e) {
    }
    return null;
  }

  //
  // Http-version
  static async.Future<String> decodeHttpVersion(EasyParser parser) {
    async.Completer completer = new async.Completer();
    int major = 0;
    int minor = 0;
    try {
      parser.nextString("HTTP" + "/").then((String v) {
      }).then((e) {
        return parser.nextBytePattern(new EasyParserIncludeMatcher(RfcTable.DIGIT));
      }).then((int v) {
        major = v - 48;
        return parser.nextString(".");
      }).then((e) {
        return parser.nextBytePattern(new EasyParserIncludeMatcher(RfcTable.DIGIT));
      }).then((int v) {
        minor = v - 48;
        return completer.complete("HTTP/" + major.toString() + "." + minor.toString());
      });
    } catch (e) {
      throw new EasyParseError();
    }
    return completer.future;
  }


  //
  // Status Code 
  // DIGIT DIGIT DIGIT
  static async.Future<String> decodeStatusCode(EasyParser parser) {
    async.Completer<String> completer = new async.Completer();
    int ret = 0;
    try {
      parser.nextBytePatternWithLength(new EasyParserIncludeMatcher(RfcTable.DIGIT), 3).then((List<int> v){
        ret = (v[0]-48) + (v[1]-48) + (v[2]-48);
        completer.complete(ret.toString());
      });
    } catch(e) {
      throw new EasyParseError();
    }
    return completer.future;
  }


  //Status-Line = HTTP-Version SP Status-Code SP Reason-Phrase CRLF
  async.Future<Object> statusline() {
    return null;
  }
}
