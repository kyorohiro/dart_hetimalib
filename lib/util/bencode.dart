part of hetima;

class Bencode 
{
  static Bencoder _encoder = new Bencoder();
  static Bdecoder _decoder = new Bdecoder();

  static data.Uint8List encode(Object obj) 
  {
     return _encoder.enode(obj);
  }

  static Object decode(data.Uint8List buffer) 
  {
    return _decoder.decode(buffer);
  }
}

class Bdecoder {
  int index = 0;
  Object decode(data.Uint8List buffer) 
  {
    index = 0;
    return innerDecode(buffer);
  }
  Object innerDecode(data.Uint8List buffer) 
  { 
    if( 0x30 <= buffer[index] && buffer[index]<=0x39) {//0-9
      return decodeBytes(buffer);
    }
    else if(0x69 == buffer[index]) {// i 
      return decodeNumber(buffer);
    }
    else if(0x6c == buffer[index]) {// l
      return decodeList(buffer);
    }
    else if(0x64 == buffer[index]) {// d
      return decodeMap(buffer);
    }
    return null;
  }

  Map decodeMap(data.Uint8List buffer) {
    index++;
    Map ret = new Map();
    while(index<buffer.length && buffer[index] != 0x65) {
      data.Uint8List keyAsList = innerDecode(buffer);
      String key = convert.UTF8.decode(keyAsList.toList());
      ret[key] = innerDecode(buffer);
    }
    index++;
    return ret;
  }

  List decodeList(data.Uint8List buffer) {
    index++;
    List ret = new List();
    while(index<buffer.length && buffer[index] != 0x65) {
      ret.add(innerDecode(buffer));
    }
    index++;
    return ret;
  }

  num decodeNumber(data.Uint8List buffer) {
    index++;
    int v = 0;
    int len=0;
    int start = index;
    while(index<buffer.length && buffer[index] != 0x65) {
      len++;
      index++;
    }
    index++;
    String numAsStr =convert.ASCII.decode(buffer.sublist(start,start+len));
    if(numAsStr.length == 0) {
      return 0;
    }
    return num.parse(numAsStr);
  }

  data.Uint8List decodeBytes(data.Uint8List buffer) {
    int length = 0;
    while(index<buffer.length && buffer[index] != 0x3a) {
      length = length*10+(buffer[index]-0x30);
      index++;
    }
    index++;
//    print("index="+index.toString()+",len="+length.toString()+",b="+buffer.length.toString());
    data.Uint8List ret = new data.Uint8List.fromList(buffer.sublist(index, index+length));
//    print("ret="+convert.UTF8.decode(ret));
    index += length;
    return ret;
  }
}

class Bencoder {
  ArrayBuilder builder = new ArrayBuilder();
 

  data.Uint8List enode(Object obj) {
    builder.clear();
    _innerEenode(obj);
    return builder.toUint8List();
  }

  void encodeString(String obj) {
    List<int> buffer = convert.UTF8.encode(obj);
    builder.appendString(""+buffer.length.toString()+":"+obj);
  }

  void encodeNumber(num num) {
    builder.appendString("i"+num.toString()+"e");
  }

  void encodeDictionary(Map obj) {
    Iterable<String> keys = obj.keys;
    builder.appendString("d");
    for(var key in keys) {
      encodeString(key);
      _innerEenode(obj[key]);
    }
    builder.appendString("e");
  }

  void encodeList(List list) {
    builder.appendString("l");
    for(int i=0;i<list.length;i++) {
      _innerEenode(list[i]);
    }
    builder.appendString("e");
  }

  void _innerEenode(Object obj) {
    if(obj is num) {
      encodeNumber(obj);
    } else if(identical(obj, true)) {
      encodeString("true");
    } else if(identical(obj, false)) {
      encodeString("false");
    } else if(obj == null) {
      encodeString("null");
    } else if(obj is String) {
      encodeString(obj);    
    } else if(obj is List) {
      encodeList(obj);
    } else if(obj is Map) {
      encodeDictionary(obj);
    }
  }
}
