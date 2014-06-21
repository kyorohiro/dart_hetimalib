part of hetima;

class HttpUrl {
  String scheme = "http";
  String host = "127.0.0.1";
  String path = "";
  int port = 80;

  static HttpUrl decode() {
    return null;
  }

}

class HttpUrlDecoder {
  int index = 0;
  List<int> url = null;
  static List<int> SCHEME_HTTP = convert.UTF8.encode("http://");
  static List<int> SCHEME_HTTPS = convert.UTF8.encode("https://");
  
  HttpUrl decodeUrl(String _url) {
    url = convert.UTF8.encode(_url);
    index =  0;
    HttpUrl ret = new HttpUrl();
    try {
      ret.scheme = scheme();
      ret.host = host();
      ret.port = port();
      ret.path = path();
    } catch(e) {
      return null;
    }
    return ret;
  }

  String scheme() {
    try {
      push();
      if(matchGroup(SCHEME_HTTP)) {
        return "http";
      }
      else if(matchGroup(SCHEME_HTTPS)) {
        back();
        return "https";
      } else {
        throw new ParseError();
      }      
    } finally {
      pop();
    }
  }

  String host() {
    try {
      push();
      while(matchChar(RfcTable.RFC3986_UNRESERVED)) {
        ;
      }
      return convert.UTF8.decode(last());
    } finally {
      pop();
    }
  }

  String path() {
    if(!(url[index] == 0x2f)) {
      return "";
    }
    while(matchChar(RfcTable.DIGIT)){
      ;
    }
    List<int> pathAsList= last();
    String pathAsString = convert.UTF8.decode(pathAsList);
    return pathAsString;
  }

  int port() {
    //:
    if(!(url[index] == 0x3a)) {
      return 80;
    }
    while(matchChar(RfcTable.DIGIT)){
      ;
    }
    List<int> portAsList= last();
    String portAsString = convert.UTF8.decode(portAsList);
    return int.parse(portAsString);
  }

  List<int> stack = new List();
  void push() {
    stack.add(index);
  }
  void pop() {
    stack.removeLast();
  }
  void back() {
    index = stack.last;
  }
  List<int> last() {
    int end = index;
    int start = stack.last;
    int len = end-start;
    List<int> ret = new List(len);
    for(int i=0;i<len;i++) {
      ret[i] = url[start+i];
    }
    return ret;
  }
  
  bool matchGroup(List<int> v) {
    for(int i=0;i<v.length;i++) {
      if(url.length <= index) {
        return false;
      }
      if(v[i] != url[index]) {
        return false;
      } else {
        index++;
      }
    }
    return true;
  }
  bool matchChar(List<int> v) {
    if(url.length <= index) {
      return false;
    }
    for(int i=0;i<v.length;i++) {
      if(v[i] == url[index]) {
        index++;
        return true;
      }
    }
    return false;
  }

}


