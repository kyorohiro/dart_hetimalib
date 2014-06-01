import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetima_cl;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'dart:html' as html;
import 'dart:async' as async;

void main() {
  print("start test");
  test_bencode();
}
void test_bencode() {
  print("start");
  {    
    hetima_cl.HetimaFileFS file = new hetima_cl.HetimaFileFS("test.txt");
    file.write("test", 0).then((hetima.WriteResult r){
      file.getLength().then((int length) {
        unit.test("A001", (){
          unit.expect(4, length);
          file.read(0, 4).then((hetima.ReadResult r){
            unit.test("A002", (){
              unit.expect("test", convert.UTF8.decode(r.buffer.toList()));
            });
          });
        });
      });
    });
  }
  print("end");
}
