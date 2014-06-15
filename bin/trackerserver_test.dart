import 'package:unittest/unittest.dart';
import 'dart:async' as async;
import 'package:hetima/hetima_sv.dart';
import 'package:hetima/hetima.dart';

void main() {
  print("---");
  TrackerServer tracker = new TrackerServer("127.0.0.1", 6969);
  tracker.add("dummy");
  tracker.start().then((StartResult result){
    print("--[2]-");
    TrackerClient client = new TrackerClient();
    client.trackerHost = "127.0.0.1";
    client.trackerPort = 6969;
    client.peerID ="dummyid";
    client.infoHash ="dummy";
    client.request().then((RequestResult r){
      print("fff");
    });    
  });
 
}
