import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetima_cl;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'dart:html' as html;
import 'dart:async' as async;

void main() {
  print("--##-");
  hetima_cl.HetiSocketBuilderChrome builder = new hetima_cl.HetiSocketBuilderChrome();
  hetima.HetiHttpClient client = new hetima.HetiHttpClient(builder);
  client.connect("157.7.205.138", 80).then((int v){
    client.get("157.7.205.138", 80, "/");;    
  });
}
