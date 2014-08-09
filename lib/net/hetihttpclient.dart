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

//rfc2616 rfc7230
class HetiHttpResponse {
  static List<int> PATH = convert.UTF8.encode(RfcTable.RFC3986_PCHAR_AS_STRING + "/");
  static List<int> QUERY = convert.UTF8.encode(RfcTable.RFC3986_RESERVED_AS_STRING + RfcTable.RFC3986_UNRESERVED_AS_STRING);


  static async.Future<HetiHttpMessageWithoutBody> decodeHttpMessage(EasyParser parser) {
    async.Completer<HetiHttpMessageWithoutBody> completer = new async.Completer();
    HetiHttpMessageWithoutBody result = new HetiHttpMessageWithoutBody();
    decodeStatusline(parser).then((HetiHttpResponseStatusLine line) {
      result.line = line;      
      return decodeHeaderFields(parser);
    }).then((List<HetiHttpResponseHeaderField> httpfields){
      result.headerField = httpfields;
      completer.complete(result);
    }).catchError((e){
      completer.completeError(e);
    });
    return completer.future;
  }
  
  static async.Future<List<HetiHttpResponseHeaderField>> decodeHeaderFields(EasyParser parser) {
    async.Completer<List<HetiHttpResponseHeaderField>> completer = new async.Completer();
    List<HetiHttpResponseHeaderField> result = new List();
    async.Future p() {
      return decodeHeaderField(parser).then((HetiHttpResponseHeaderField v) {
        result.add(v);
        return p();
      });
    }
  
    p().catchError((e) {
      return decodeCrlf(parser);
    }).catchError((e){
      completer.completeError(e);
    }).then((e){
      completer.complete(result);      
    });

    return completer.future;
  }

  
  static async.Future<HetiHttpResponseHeaderField> decodeHeaderField(EasyParser parser) {
    HetiHttpResponseHeaderField result = new HetiHttpResponseHeaderField();
    async.Completer<HetiHttpResponseHeaderField> completer = new async.Completer();
    decodeFieldName(parser).then((String v){
      result.fieldName = v;
      return parser.nextString(":");
    }).then((String v){
      return decodeOWS(parser);
    }).then((String v){
      return decodeFieldValue(parser);
    }).then((String v){
      result.fieldValue = v;
      return decodeCrlf(parser);
    }).then((String v){
      completer.complete(result);      
    }).catchError((e){
      completer.completeError(e);
    });
    return completer.future;
  }

  static async.Future<String> decodeFieldName(EasyParser parser) {
    async.Completer<String> completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.TCHAR)).then((List<int> v) {
      completer.complete(convert.UTF8.decode(v));
    });
    return completer.future;
  }
  
  static async.Future<String> decodeFieldValue(EasyParser parser) {
    async.Completer<String> completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new FieldValueMatcher()).then((List<int> v) {
      completer.complete(convert.UTF8.decode(v));
    });
    return completer.future;
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
      parser.nextBytePatternWithLength(new EasyParserIncludeMatcher(RfcTable.DIGIT), 3).then((List<int> v) {
        ret = 100 * (v[0] - 48) + 10 * (v[1] - 48) + (v[2] - 48);
        completer.complete(ret.toString());
      });
    } catch (e) {
      throw new EasyParseError();
    }
    return completer.future;
  }


  static async.Future<String> decodeReasonPhrase(EasyParser parser) {
    async.Completer<String> completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new TextMatcher()).then((List<int> vv) {
      String v = convert.UTF8.decode(vv);
      completer.complete(v);
    });
    return completer.future;
  }

  //Status-Line = HTTP-Version SP Status-Code SP Reason-Phrase CRLF
  static async.Future<HetiHttpResponseStatusLine> decodeStatusline(EasyParser parser) {
    HetiHttpResponseStatusLine result = new HetiHttpResponseStatusLine();
    async.Completer<HetiHttpResponseStatusLine> completer = new async.Completer();
    decodeHttpVersion(parser).then((String v) {
      result.version = v;
      return decodeSP(parser);
    }).then((String v) {
      return decodeStatusCode(parser);
    }).then((String v) {
      result.statusCode = int.parse(v);
      return decodeSP(parser);
    }).then((onValue) {
      return decodeReasonPhrase(parser);
    }).then((String v) {
      result.statusPhrase = v;
      return decodeCrlf(parser);
    }).then((String v) {
      completer.complete(result);
    });
    return completer.future;
  }


  static async.Future<String> decodeOWS(EasyParser parser) {
    async.Completer completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.OWS)).then((List<int> v) {
      completer.complete(convert.UTF8.decode(v));
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  static async.Future<String> decodeSP(EasyParser parser) {
    async.Completer completer = new async.Completer();
    parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.SP)).then((List<int> v) {
      completer.complete(convert.UTF8.decode(v));
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  //
  static async.Future<String> decodeCrlf(EasyParser parser) {
    async.Completer completer = new async.Completer();
    bool lf = true;
    bool crlf = true;
    parser.push();
    parser.nextString("\r\n").catchError((e) {
      parser.back();
      parser.pop();
      parser.push();
      crlf = false;
      return parser.nextString("\n");
    }).then((e) {
      if (crlf == true) {
        completer.complete("\r\n");
      } else {
        completer.complete("\n");
      }
    }).catchError((e) {
      completer.completeError(e);
    }).whenComplete((){
      parser.pop();      
    });
    return completer.future;
  }
}

// reason-phrase  = *( HTAB / SP / VCHAR / obs-text )
class TextMatcher extends EasyParserMatcher {
  @override
  bool match(int target) {
    //  VCHAR = 0x21-0x7E
    //  obs-text = %x80-FF
    //  SP = 0x30
    //  HTAB = 0x09
    if (0x21 <= target && target <= 0x7E) {
      return true;
    }
    if (0x80 <= target && target <= 0xFF) {
      return true;
    }
    if (target == 0x20 || target == 0x09) {
      return true;
    }
    return false;
  }
}

class FieldValueMatcher extends EasyParserMatcher {
  @override
  bool match(int target) {
    if (target == 0x0D || target == 0x0A) {
      return false;
    } else {
      return true;
    }
  }
}

// reason-phrase  = *( HTAB / SP / VCHAR / obs-text )
class HetiHttpResponseStatusLine {
  String version = "";
  int statusCode = -1;
  String statusPhrase = "";
}

class HetiHttpResponseHeaderField {
  String fieldName = "";
  String fieldValue = "";
}

// HTTP-message   = start-line
// *( header-field CRLF )
// CRLF
// [ message-body ]
class HetiHttpMessageWithoutBody {
  HetiHttpResponseStatusLine line = new HetiHttpResponseStatusLine();
  List<HetiHttpResponseHeaderField> headerField = new List();
}
