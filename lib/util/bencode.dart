part of hetima;

class Bencode 
{
  static Bencoder _encoder = new Bencoder();
  static Bdecoder _decoder = new Bdecoder();

  static data.Uint8List encode(core.Object obj) 
  {
     return _encoder.enode(obj);
  }

  static core.Object decode(data.Uint8List buffer) 
  {
    return _decoder.decode(buffer);
  }
}

class Bdecoder {
  core.int index = 0;
  core.Object decode(data.Uint8List buffer) 
  {
    index = 0;
    return innerDecode(buffer);
  }
  core.Object innerDecode(data.Uint8List buffer) 
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

  core.Map decodeMap(data.Uint8List buffer) {
    index++;
    core.Map ret = new core.Map();
    while(index<buffer.length && buffer[index] != 0x65) {
      data.Uint8List keyAsList = innerDecode(buffer);
      core.String key = convert.UTF8.decode(keyAsList.toList());
      ret[key] = innerDecode(buffer);
    }
    index++;
    return ret;
  }

  core.List decodeList(data.Uint8List buffer) {
    index++;
    core.List ret = new core.List();
    while(index<buffer.length && buffer[index] != 0x65) {
      ret.add(innerDecode(buffer));
    }
    index++;
    return ret;
  }

  core.num decodeNumber(data.Uint8List buffer) {
    index++;
    core.int v = 0;
    core.int len=0;
    core.int start = index;
    while(index<buffer.length && buffer[index] != 0x65) {
      len++;
      index++;
    }
    index++;
    core.String numAsStr =convert.ASCII.decode(buffer.sublist(start,start+len));
    if(numAsStr.length == 0) {
      return 0;
    }
    return core.num.parse(numAsStr);
  }

  data.Uint8List decodeBytes(data.Uint8List buffer) {
    core.int length = 0;
    while(index<buffer.length && buffer[index] != 0x3a) {
      length += length*10+(buffer[index]-0x30);
      index++;
    }
    index++;
    data.Uint8List ret = new data.Uint8List.fromList(buffer.sublist(index, index+length));
    index += length;
    return ret;
  }
}

class Bencoder {
  ArrayBuilder builder = new ArrayBuilder();
 

  data.Uint8List enode(core.Object obj) {
    builder.clear();
    _innerEenode(obj);
    return builder.toUint8List();
  }

  void encodeString(core.String obj) {
    builder.appendString(""+obj.length.toString()+":"+obj);
  }

  void encodeNumber(core.num num) {
    builder.appendString("i"+num.toString()+"e");
  }

  void encodeDictionary(core.Map obj) {
    core.Iterable<core.String> keys = obj.keys;
    builder.appendString("d");
    for(var key in keys) {
      encodeString(key);
      _innerEenode(obj[key]);
    }
    builder.appendString("e");
  }

  void encodeList(core.List list) {
    builder.appendString("l");
    for(core.int i=0;i<list.length;i++) {
      _innerEenode(list[i]);
    }
    builder.appendString("e");
  }

  void _innerEenode(core.Object obj) {
    if(obj is core.num) {
      encodeNumber(obj);
    } else if(core.identical(obj, true)) {
      encodeString("true");
    } else if(core.identical(obj, false)) {
      encodeString("false");
    } else if(obj == null) {
      encodeString("null");
    } else if(obj is core.String) {
      encodeString(obj);    
    } else if(obj is core.List) {
      encodeList(obj);
    } else if(obj is core.Map) {
      encodeDictionary(obj);
    }
  }
}
