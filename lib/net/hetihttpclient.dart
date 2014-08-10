part of hetima;

class HetiHttpClientResponse {
  HetiHttpMessageWithoutBody message;
  HetimaBuilder body;
  int getContentLength() {
    HetiHttpResponseHeaderField contentLength = message.find(RfcTable.HEADER_FIELD_CONTENT_LENGTH);
    if (contentLength == null) {
      try {
        return int.parse(contentLength.fieldValue);
      } catch (e) {
      }
    }
    return -1;
  }
}

class HetiHttpClient {
  HetiSocketBuilder _builder;
  HetiSocket socket = null;

  HetiHttpClient(HetiSocketBuilder builder) {
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

  async.Future<HetiHttpClientResponse> get(String host, int port, String path) {
    async.Completer<HetiHttpClientResponse> completer = new async.Completer();
    ArrayBuilder builder = new ArrayBuilder();
    builder.appendString("GET" + " " + path + " " + "HTTP/1.0" + "\r\n");
    builder.appendString("Host:" + " " + host + "\r\n");
    builder.appendString("Connection: close\r\n");
    builder.appendString("\r\n");
    
    socket.onReceive().listen((HetiReceiveInfo info) {
      //String r = convert.UTF8.decode(socket.buffer.toList());
      //print("\r\n######\r\n" + r + "\r\n#####\r\n");
    });
    socket.send(builder.toList()).then((HetiSendInfo info) {
      print("\r\n======" + info.resultCode.toString() + "\r\n");
    });

    EasyParser parser = new EasyParser(socket.buffer);
    HetiHttpResponse.decodeHttpMessage(parser).then((HetiHttpMessageWithoutBody message) {
    /* print("\r\n#AAAAA#\r\n");
      for (HetiHttpResponseHeaderField field in message.headerField) {
        print("" + field.fieldName + ":" + field.fieldValue);
      }
      print("\r\n#BBBBB#\r\n");
      */
      HetiHttpClientResponse result = new HetiHttpClientResponse();
      result.message = message;
      result.body = new ArrayBuilderAdapter(socket.buffer, message.index);
      completer.complete(result);
    }).catchError((e) {
      print("\r\n#CCCCC#\r\n");
      completer.completeError(e);
    });
    return completer.future;
  }

  void close() {
    if (socket != null) {
      socket.close();
    }
  }
}
