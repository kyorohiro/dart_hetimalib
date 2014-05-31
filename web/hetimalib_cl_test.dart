import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'torrentfile_cl_test.dart' as torrentfilecl_test;
import 'hetimafile_cl_test.dart' as hetimafilecl_test;


void main() {
  print("start test");
 // torrentfilecl_test.test_bencode();
  hetimafilecl_test.test_bencode();
}

