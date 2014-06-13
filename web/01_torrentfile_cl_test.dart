import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetima_cl;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'dart:html' as html;
import 'dart:async' as async;

void main() {
  unit.test("fs check", () {
    html.window.requestFileSystem(1024).then((html.FileSystem e) {
      print("fs:fullpath:" + e.root.fullPath);
      print("fs:fullpath:" + e.name);
      html.DirectoryReader reader = e.root.createReader();
      reader.readEntries().then((List<html.Entry> el) {
        for (html.Entry e in el) {
          print("fs:fullpath:" + e.name);
        }
      });
    });
  });

  {
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", "testdata/1k.txt.torrent");
    request.onLoad.listen((html.ProgressEvent e) {
      html.FileReader reader = new html.FileReader();
      reader.readAsArrayBuffer(request.response);
      reader.onLoad.listen((html.ProgressEvent e) {
        unit.test("001 1k.txt.torrent", () {
          hetima.TorrentFile f = new hetima.TorrentFile.loadTorrentFileBuffer(reader.result);
          unit.expect("http://127.0.0.1:6969/announce", f.announce);
          unit.expect("1k.txt", f.info.name);
          unit.expect(1, f.info.files.path.length);
          unit.expect("1k.txt", f.info.files.path[0].pathAsString);
          unit.expect(1024, f.info.files.path[0].length);
        });
      });
    });
    request.send();
  }

  {
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", "testdata/1kb.torrent");
    request.onLoad.listen((html.ProgressEvent e) {
      html.FileReader reader = new html.FileReader();
      reader.readAsArrayBuffer(request.response);
      reader.onLoad.listen((html.ProgressEvent e) {
        unit.test("002 1kb.torrent", () {
          hetima.TorrentFile f = new hetima.TorrentFile.loadTorrentFileBuffer(reader.result);
          unit.expect("http://127.0.0.1:6969/announce", f.announce);
          unit.expect("1kb", f.info.name);
          unit.expect(2, f.info.files.path.length);
          unit.expect("1k_b.txt", f.info.files.path[0].pathAsString);
          unit.expect(1024, f.info.files.path[0].length);
          unit.expect("1k.txt", f.info.files.path[1].pathAsString);
          unit.expect(1024, f.info.files.path[1].length);
        });
      });
    });
    request.send();
  }

  {
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", "testdata/1k.txt.torrent");
    request.onLoad.listen((html.ProgressEvent e) {
      html.FileReader reader = new html.FileReader();
      hetima_cl.HetimaFileBlob file = new hetima_cl.HetimaFileBlob(request.response);
      file.getLength().then((int length) {
        file.read(0, length).then((hetima.ReadResult r) {
          unit.test("003 hetimafile blob", () {
            hetima.TorrentFile f = new hetima.TorrentFile.loadTorrentFileBuffer(r.buffer);
            unit.expect("http://127.0.0.1:6969/announce", f.announce);
            unit.expect("1k.txt", f.info.name);
            unit.expect(1, f.info.files.path.length);
            unit.expect("1k.txt", f.info.files.path[0].pathAsString);
            unit.expect(1024, f.info.files.path[0].length);
          });
        });
      });
    });
    request.send();
  }

  {
    hetima_cl.HetimaFileGet file = new hetima_cl.HetimaFileGet("testdata/1kb/1k.txt");
    hetima.TorrentPieceHashCreator h = new hetima.TorrentPieceHashCreator();
    h.createPieceHash(file, 16 * 1024).then((hetima.CreatePieceHashResult r) {
      unit.test("004 hetimafile get ss", () {
        List<int> expect = [196, 42, 125, 9, 64, 47, 78, 143, 209, 15, 188, 87, 124, 199, 203, 157, 198, 52, 62, 142];
        unit.expect(20, r.pieceBuffer.size());
        for (int i = 0; i < r.pieceBuffer.size(); i++) {
          unit.expect(expect[i], r.pieceBuffer.toList()[i]);
        }
      });
    });
  }
  {
    hetima.TorrentPieceHashCreator h = new hetima.TorrentPieceHashCreator();
    html.HttpRequest file001 = new html.HttpRequest();
    html.HttpRequest file002 = new html.HttpRequest();
    file001.responseType = "blob";
    file002.responseType = "blob";
    file001.open("GET", "testdata/1kb/1k_b.txt");
    file002.open("GET", "testdata/1kb/1k.txt");
    file002.onLoadEnd.listen((html.ProgressEvent e) {
      hetima_cl.HetimaFileBlob file = new hetima_cl.HetimaFileBlob(new html.Blob([file001.response, file002.response]));
      h.createPieceHash(file, 16 * 1024).then((hetima.CreatePieceHashResult r) {
        unit.test("005 hetimafile get double", () {
          List<int> expect = [149, 96, 47, 41, 153, 193, 171, 203, 165, 128, 108, 193, 118, 11, 175, 49, 229, 27, 231, 149];
          unit.expect(20, r.pieceBuffer.size());
          for (int i = 0; i < r.pieceBuffer.size(); i++) {
            unit.expect(expect[i], r.pieceBuffer.toList()[i]);
          }
        });
      });
    });
    file001.onLoadEnd.listen((html.ProgressEvent e) {
      file002.send();
    });
    file001.send();
  }
  {
    hetima_cl.HetimaFileGet file = new hetima_cl.HetimaFileGet("testdata/1kb/1k.txt");
    hetima.TorrentFileCreator c = new hetima.TorrentFileCreator();
    c.name = "1k.txt";
    c.announce = "http://www.example.com/tracker:6969";
    c.createFromSingleFile(file).then((hetima.TorrentFileCreatorResult e) {
      e.torrentFile;
      List<int> expect = [196, 42, 125, 9, 64, 47, 78, 143, 209, 15, 188, 87, 124, 199, 203, 157, 198, 52, 62, 142];
      unit.test("006 create torrent", () {
        unit.expect(20, e.torrentFile.info.piece.length);
        for (int i = 0; i < e.torrentFile.info.piece.length; i++) {
          unit.expect(expect[i], e.torrentFile.info.piece[i]);
        }
        unit.expect(16 * 1024, e.torrentFile.info.piece_length);
        unit.expect("http://www.example.com/tracker:6969", e.torrentFile.announce);
        unit.expect(1, e.torrentFile.info.files.size);
        unit.expect(1024, e.torrentFile.info.files.path[0].length);
        unit.expect("1k.txt", e.torrentFile.info.files.path[0].pathAsString);
      });
    });
  }
}
