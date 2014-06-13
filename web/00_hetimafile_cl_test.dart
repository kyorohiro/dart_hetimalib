import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetima_cl;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'dart:html' as html;
import 'dart:async' as async;

void main() {
  unit.test("filesystem write/read", () {
    bool isTested = false;
    hetima_cl.HetimaFileFS file = new hetima_cl.HetimaFileFS("test.txt");
    new async.Future.sync(() {
      return file.write("test", 0).then((hetima.WriteResult r) {
        return file.getLength().then((int length) {
          unit.expect(4, length);
          return file.read(0, 4).then((hetima.ReadResult r) {
            unit.expect("test", convert.UTF8.decode(r.buffer.toList()));
            isTested = true;
          });
        });
      });
    }).then((_) {
      unit.expect(isTested, true);
    });
  });
}
