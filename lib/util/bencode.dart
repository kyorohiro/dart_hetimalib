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
    if( 0x30 <= buffer[index] && buffer[index]<=0x39) {
      return decodeBytes(buffer);
    }
    return null;
  }
  data.Uint8List decodeBytes(data.Uint8List buffer) {
    core.int length = 0;
    while(index<buffer.length && buffer[index] != 0x3a) {
      length += length*10+(buffer[index]-0x30);
      index++;
    }
    index++;
    return new data.Uint8List.fromList(buffer.sublist(index, index+length));
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

  void _innerEenode(core.Object obj) {
    
    if(obj is core.num) {
      
    } else if(core.identical(obj, true)) {
      
    } else if(core.identical(obj, false)) {
      
    } else if(obj == null) {
      
    } else if(obj is core.String) {
      encodeString(obj);    
    } else if(obj is core.List) {
      
    } else if(obj is core.Map) {
      
    }
  }
}
