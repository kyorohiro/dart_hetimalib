import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetima_cl;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'dart:html' as html;

void test_bencode() {

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

  unit.test("1k.txt.torrent", () {
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", "testdata/1k.txt.torrent");
    request.onLoad.listen((html.ProgressEvent e) {
      html.FileReader reader = new html.FileReader();
      reader.readAsArrayBuffer(request.response);
      reader.onLoad.listen((html.ProgressEvent e) {
        hetima.TorrentFile f = new hetima.TorrentFile.load(reader.result);
        unit.expect("http://127.0.0.1:6969/announce", f.announce);
        unit.expect("1k.txt", f.info.name);
        unit.expect(1, f.info.files.path.length);
        unit.expect("1k.txt", f.info.files.path[0].pathAsString);
        unit.expect(1024, f.info.files.path[0].length);
      });
    });
    request.send();
  });

  unit.test("1kb.torrent", () {
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", "testdata/1kb.torrent");
    request.onLoad.listen((html.ProgressEvent e) {
      html.FileReader reader = new html.FileReader();
      reader.readAsArrayBuffer(request.response);
      reader.onLoad.listen((html.ProgressEvent e) {
        hetima.TorrentFile f = new hetima.TorrentFile.load(reader.result);
        unit.expect("http://127.0.0.1:6969/announce", f.announce);
        unit.expect("1kb", f.info.name);
        unit.expect(2, f.info.files.path.length);
        unit.expect("1k_b.txt", f.info.files.path[0].pathAsString);
        unit.expect(1024, f.info.files.path[0].length);
        unit.expect("1k.txt", f.info.files.path[1].pathAsString);
        unit.expect(1024, f.info.files.path[1].length);
      });
    });
    request.send();
  });
  
  unit.test("1kb.txt", () {
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", "testdata/1kb/1k.txt");
    request.onLoad.listen((html.ProgressEvent e) {
      html.FileReader reader = new html.FileReader();
      reader.readAsArrayBuffer(request.response);
      reader.onLoad.listen((html.ProgressEvent e) {
        hetima.TorrentFileHelper helper = new hetima.TorrentFileHelper();
        helper.verifyPiece(new hetima_cl.HetimaFileCl(request.response), 1024*16)
        .then((hetima.VerifyPieceResult e) {
          ;
        });
        hetima.TorrentFile f = new hetima.TorrentFile.load(reader.result);
      });
    });
    request.send();
  });

  unit.test("1k.txt.torrent", () {
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", "testdata/1k.txt.torrent");
    request.onLoad.listen((html.ProgressEvent e) {
      html.FileReader reader = new html.FileReader();
      hetima_cl.HetimaFileCl file = new hetima_cl.HetimaFileCl(request.response);
      file.read(0, file.length).then((hetima.ReadResult r){
         hetima.TorrentFile f = new hetima.TorrentFile.load(r.buffer);
         unit.expect("http://127.0.0.1:6969/announce", f.announce);
         unit.expect("1k.txt", f.info.name);
         unit.expect(1, f.info.files.path.length);
         unit.expect("1k.txt", f.info.files.path[0].pathAsString);
         unit.expect(1024, f.info.files.path[0].length);
      });
    });
    request.send();
  });

  unit.test("1k.txt piece", () {
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", "testdata/1k.txt.torrent");
    request.onLoad.listen((html.ProgressEvent e) {
      html.FileReader reader = new html.FileReader();
      hetima_cl.HetimaFileCl file = new hetima_cl.HetimaFileCl(request.response);
      hetima.TorrentFileHelper h = new hetima.TorrentFileHelper();
      h.verifyPiece(file, 16*1024).then((hetima.VerifyPieceResult r) {
        List<int> expect = [149,96,47,41,153,193,171,203,165,128,108,193,118,11,175,49,229,27,231,149];
         print("xxx"+r.b.size().toString());
         unit.expect(20, r.b.size());
         for(int i=0;i<r.b.size();i++) {
           unit.expect(expect[i], r.b.toList()[i]);
         }
      });
    });
    request.send();
  });

  unit.test("1k.txt piece", () {
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", "testdata/1k.txt.torrent");
    request.onLoad.listen((html.ProgressEvent e) {
      html.FileReader reader = new html.FileReader();
      hetima_cl.HetimaFileCl file = new hetima_cl.HetimaFileCl(request.response);
      hetima.TorrentFileHelper h = new hetima.TorrentFileHelper();
      h.verifyPiece(file, 16*1024).then((hetima.VerifyPieceResult r) {
        List<int> expect = [149,96,47,41,153,193,171,203,165,128,108,193,118,11,175,49,229,27,231,149];
         print("xxx"+r.b.size().toString());
         unit.expect(20, r.b.size());
         for(int i=0;i<r.b.size();i++) {
           unit.expect(expect[i], r.b.toList()[i]);
         }
      });
    });
    request.send();
  });
}
