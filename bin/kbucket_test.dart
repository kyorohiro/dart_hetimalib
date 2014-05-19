import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;

void test_kbucket() {
  unit.test("kbucket: nodeid", () {
    hetima.NodeId nodeid = new hetima.NodeId.random();
    print(""+nodeid.toString());
  });

}
