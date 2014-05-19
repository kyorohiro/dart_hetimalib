part of hetima;

class KBucket 
{
  int _rangeMin = 0;
  int _rangeMax = 1;
  int size = 5;

  /// rangeMin<= id <rangMax
  KBucket(int rangeMin,int rangMax) {
    _rangeMin = rangeMin;
    _rangeMax = rangMax;
  }

  bool isInRange(Node n) {
    return false;
  }
  void offerNode() {
    ;
  }

  void removeNode() {
    ;
  }
}

class Node<V> 
{
  NodeId _id = null;
  V _value = null;

  Node<V> setValue(V value) {
    _value = value;
    return this;
  }

  Node.randomId() {
    _id = new NodeId.random();
  }

  data.Uint8List getId() {
      return _id.getBuffer();
  }
}

class NodeId
{
  static math.Random _random = new math.Random();
  data.Uint8List _buffer;

  NodeId(data.Uint8List buffer) {
    _buffer = buffer;
  }

  NodeId.random() {
    _buffer = new data.Uint8List(20);
    for(int i=0;i<_buffer.lengthInBytes;i++) {
      _buffer[i] = _random.nextInt(0xFF);
    }
  }

  String toString() {
    StringBuffer buffer = new StringBuffer();
    for(int i=0;i<_buffer.lengthInBytes;i++) {
      buffer.write((_buffer[i]+0x100).toRadixString(16).substring(0,2));
    }
    return buffer.toString();
  }

  data.Uint8List getBuffer() {
    return _buffer;
  }
}