import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetima_cl;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'dart:html' as html;

void test_bencode() {

  //
  unit.test("fs check", () {
    html.window.requestFileSystem(1024).then((html.FileSystem e){
      print("fs:fullpath:"+e.root.fullPath);
      print("fs:fullpath:"+e.name);
      html.DirectoryReader reader = e.root.createReader();
      reader.readEntries().then((List<html.Entry> el){
        for(html.Entry e in el) {
          print("fs:fullpath:"+e.name);          
        }
      });
    });
  });
  //
  unit.test("httprequest", (){
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", "1k.txt.torrent");
    request.onLoad.listen((html.ProgressEvent e) {
      print("loaded");
      print("dd"+request.response.toString());
      print("dd"+request.responseType);
      print("dd"+request.response.runtimeType.toString());
      hetima_cl.HetimaFileCl cl = new hetima_cl.HetimaFileCl(request.response);
      html.FileReader reader = new html.FileReader();
      reader.readAsArrayBuffer(request.response);
      reader.onLoadEnd.listen//(onData)
      //reader.onLoad.listen
      ((html.ProgressEvent e){
        print("ddsssssss");
        print("dds="+reader.result.toString());
        print("dds="+reader.result.runtimeType.toString());
      });
    });
    request.send();
  });

  unit.test("", (){
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", "1k.txt.torrent");
    request.onLoad.listen((html.ProgressEvent e) {
      hetima_cl.HetimaFileCl cl = new hetima_cl.HetimaFileCl(request.response);
      html.FileReader reader = new html.FileReader();
      reader.readAsArrayBuffer(request.response);
      reader.onLoad.listen((html.ProgressEvent e){
        try {
          print("dgfd="+reader.result.runtimeType.toString());
        hetima.TorrentFile f = new hetima.TorrentFile.load(reader.result);
        print("dgfds=");
        print("d="+f.announce);
        }catch(e) {
          print("error:dadsfasf="+e.toString());
        }
      });
    });
    request.send();
  });
}
