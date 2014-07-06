part of hetima_sv;

class HttpServer {
  String _rootpath = "../..";
  io.WebSocket _websocket;
  int _port = 8081;
  String _host = "localhost";


  void handleError(io.HttpRequest req, io.HttpResponse res) {
    res.statusCode = 404;
    res.close();
  }

  void handleDir(io.HttpRequest req, io.HttpResponse res, String path) {
    io.Directory dir = new io.Directory(path);
    res.statusCode = 200;
    res.headers.set("Content-Type", "text/html");

    dir.list().listen((io.FileSystemEntity e) {
      res.write(("<a href=http://" + req.headers.host + ":" + _port.toString() + "" + e.path.substring(_rootpath.length) + ">" + e.path + "</a><br>"));
    }).onDone(() {
      res.close();
    });
  }

  void handleFile(io.HttpRequest req, io.HttpResponse res, io.File fpath) {
    fpath.readAsBytes().then((List<int> buffer) {
      res.statusCode = 200;
      if (fpath.path.endsWith(".txt")) {
        res.headers.set("Content-Type", "text/plain");
      } else if (fpath.path.endsWith(".htm") || fpath.path.endsWith(".html")) {
        res.headers.set("Content-Type", "text/html");
      } else {
        res.headers.set("Content-Type", "text/plain");
      }
      res.add(buffer);
      res.close();
    });
  }

  void onListen(io.HttpRequest request) {
    print("onListen...:" + request.uri.path + "," + request.headers.host);
    String path = _rootpath + request.uri.path;
    io.FileSystemEntity.isDirectory(path).then((isDir) {
      if (isDir == true) {
        handleDir(request, request.response, path);
        return;
      } else {
        io.File fpath = new io.File(path);
        fpath.exists().then((bool isThere) {
          if (isThere) {
            handleFile(request, request.response, fpath);
          } else {
            handleError(request, request.response);
            return;
          }
        });
      }
    });
  }

  void start() {
    io.HttpServer.bind(_host, _port).then((io.HttpServer server) {
      server.listen(onListen);
    });
  }
}
