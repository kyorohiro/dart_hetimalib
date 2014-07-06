import 'package:unittest/unittest.dart';
import 'dart:async' as async;
import 'package:hetima/hetima_sv.dart';
import 'package:hetima/hetima.dart';

void main() {
  print("---");
  List<int> infoHash = PeerIdCreator.createPeerid("heti");
  List<int> peerId = PeerIdCreator.createPeerid("heti");
  TrackerServer tracker = new TrackerServer("127.0.0.1", 6969);
  tracker.add(PercentEncode.encode(infoHash));
  new async.Future.sync(() {
    return tracker.start().then((StartResult result){
      print("--[2]-");
      TrackerClient client = new TrackerClient();
      client.trackerHost = "127.0.0.1";
      client.trackerPort = 6969;
      client.peerID =PercentEncode.encode(peerId);
      client.infoHash = PercentEncode.encode(infoHash);
      return client.request();
    });    
  }).then((RequestResult r){
    r.code;
    print("fff"+r.code);
  });  
 
}
