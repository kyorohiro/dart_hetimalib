part of hetima;

class HetiBencode {
  static HetiBdecoder _decoder = new HetiBdecoder();

  static async.Future<Object> decode(EasyParser parser) {
    return _decoder.decode(parser);
  }

}

class HetiBdecoder {
  async.Future<Object> decode(EasyParser parser) {
    return decodeBenObject(parser);
  }

  async.Future<Object> decodeBenObject(EasyParser parser) {
    async.Completer completer = new async.Completer();
    parser.getPeek(1).then((List<int> v) {
      if (0x69 == v[0]) {
        // i
        return decodeNumber(parser).then((int n) {
          completer.complete(n);
        });
      }
      /*
      if (0x30 <= buffer[index] && buffer[index] <= 0x39) {//0-9
        return decodeBytes(buffer);
      } else if (0x69 == buffer[index]) {// i
        return decodeNumber(buffer);
      } else if (0x6c == buffer[index]) {// l
        return decodeList(buffer);
      } else if (0x64 == buffer[index]) {// d
        return decodeDiction(buffer);
      }
      */
      throw new HetiBencodeParseError("benobject");
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  Map decodeDiction(data.Uint8List buffer) {
    Map ret = new Map();
    if (buffer[index++] != 0x64) {
      throw new BencodeParseError("bendiction", buffer, index);
    }

    ret = decodeDictionElements(buffer);

    if (buffer[index++] != 0x65) {
      throw new BencodeParseError("bendiction", buffer, index);
    }
    return ret;
  }

  Map decodeDictionElements(data.Uint8List buffer) {
    Map ret = new Map();
    while (index < buffer.length && buffer[index] != 0x65) {
      data.Uint8List keyAsList = decodeBenObject(buffer);
      String key = convert.UTF8.decode(keyAsList.toList());
      ret[key] = decodeBenObject(buffer);
    }
    return ret;
  }

  List decodeList(data.Uint8List buffer) {
    List ret = new List();
    if (buffer[index++] != 0x6c) {
      throw new BencodeParseError("benlist", buffer, index);
    }
    ret = decodeListElemets(buffer);
    if (buffer[index++] != 0x65) {
      throw new BencodeParseError("benlist", buffer, index);
    }
    return ret;
  }

  List decodeListElemets(data.Uint8List buffer) {
    List ret = new List();
    while (index < buffer.length && buffer[index] != 0x65) {
      ret.add(decodeBenObject(buffer));
    }
    return ret;
  }

  async.Future<int> decodeNumber(EasyParser parser) {
    async.Completer<int> completer = new async.Completer();
    int num = 0;
    parser.nextString("i").then((String v) {
      return parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.DIGIT));
    }).then((List<int> numList) {
      num = intList2int(numList);
      return parser.nextString("e");
    }).then((String v) {
      completer.complete(num);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<String> decodeString(EasyParser parser) {
    async.Completer<String> completer = new async.Completer();
    decodeBytes(parser).then((List<int> v) {
      try {
        completer.complete(convert.UTF8.decode(v));
      } catch(e) {
        completer.completeError(e);
      }
    }).catchError((e){
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<List<int>> decodeBytes(EasyParser parser) {
    async.Completer<List<int>> completer = new async.Completer();
    int length = 0;
    parser.nextBytePatternByUnmatch(new EasyParserIncludeMatcher(RfcTable.DIGIT))
    .then((List<int> lengthList) {
      if (lengthList.length == 0) {
        completer.completeError(new HetiBencodeParseError("byte:length=0"));;
        return null;
      }
      length = intList2int(lengthList);
      return parser.nextString(":");
    }).then((v){
      return parser.nextBuffer(length);
    }).then((List<int> value){
      if(value.length == length) {
        completer.complete(value);       
      } else {
        completer.completeError(new HetiBencodeParseError("byte:length:"+value.length.toString()+"=="+length.toString()));        
      }
    });
    return completer.future;
  }

  static int intList2int(List<int> numList) {
    int num = 0;
    for (int n in numList) {
      num *= 10;
      num += (n - 48);
    }
    return num;
  }
}

class HetiBencodeParseError implements Exception {

  String log = "";
  HetiBencodeParseError(String s) {
    log = s + "#" + super.toString();
  }

  String toString() {
    return log;
  }
}
