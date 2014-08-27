import 'package:unittest/unittest.dart' as unit;
import 'dart:async' as async;
import 'package:hetima/hetima_sv.dart' as hetima_sv;
import 'package:hetima/hetima.dart' as hetima;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
void main() {

  print("---");
  hetima.HetiTest test = new hetima.HetiTest("t");

  {
    hetima.HetiTestTicket ticket = test.test("n", 3000);
    List<int> infoHash = hetima.PeerIdCreator.createPeerid("heti");
    List<int> peerId = hetima.PeerIdCreator.createPeerid("heti");
    hetima_sv.TrackerServer tracker = new hetima_sv.TrackerServer();
    tracker.address = "127.0.0.1";
    tracker.port = 6969;
    tracker.add(hetima.PercentEncode.encode(infoHash));
    hetima.TrackerPeerManager manager = tracker.find(infoHash);
    new async.Future.sync(() {
      return tracker.start().then((hetima_sv.StartResult result) {
        print("--[2]-");
        hetima_sv.TrackerClientSv client = new hetima_sv.TrackerClientSv();
        client.trackerHost = "127.0.0.1";
        client.trackerPort = 6969;
        client.peerID = hetima.PercentEncode.encode(peerId);
        client.infoHash = hetima.PercentEncode.encode(infoHash);
        return client.request();
      });
    }).then((hetima_sv.RequestResultSv r) {
      unit.test("", () {
        ticket.assertTrue("1:", r.code == hetima_sv.RequestResultSv.OK);
        ticket.assertTrue("2:", r.response.interval == manager.interval);
        ticket.assertTrue("3:", r.response.peers[0].port ==  6969);
      });
    }).whenComplete(() {
      ticket.fin();
    });
  }

  {
    hetima.HetiTestTicket ticket = test.test("m", 3000);
    List<int> peerId = hetima.PeerIdCreator.createPeerid("-d-");

    hetima.PeerAddress adressA = new hetima.PeerAddress(peerId, "s", [127, 0, 0, 1], 6060);

    hetima.PeerAddress adressB = new hetima.PeerAddress(peerId, "s", [127, 0, 0, 1], 6061);

    ticket.assertTrue("", adressA == adressB);
    ticket.fin();
  }

  {
    hetima.HetiTestTicket ticket = test.test("s", 3000);
    List<int> peerIdA = hetima.PeerIdCreator.createPeerid("-d-");
    List<int> peerIdB = hetima.PeerIdCreator.createPeerid("-e-");

    hetima.PeerAddress adressA = new hetima.PeerAddress(peerIdA, "s", [127, 0, 0, 1], 6060);

    hetima.PeerAddress adressB = new hetima.PeerAddress(peerIdB, "s", [127, 0, 0, 1], 6061);

    ticket.assertTrue("", adressA != adressB);
    ticket.fin();
  }
  /*
  {
    hetima_sv.TrackerServer server = new hetima_sv.TrackerServer();
    server.add("dummy");
    server.updateResponse("", [127, 0, 0, 2]);
    
  }*/
}
