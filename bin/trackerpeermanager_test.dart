import 'package:unittest/unittest.dart' as unit;
import 'dart:async' as async;
import 'package:hetima/hetima_sv.dart';
import 'package:hetima/hetima.dart';

void main() {
  print("---");
  unit.test("", () {
    List<int> infoHash = PeerIdCreator.createPeerid("heti");
    List<int> peerId = PeerIdCreator.createPeerid("heti");

    TrackerPeerManager manager = new TrackerPeerManager(infoHash);
    Map<String, String> parameter = {
      TrackerUrl.KEY_PORT: "8080",
      TrackerUrl.KEY_EVENT: "",
      TrackerUrl.KEY_INFO_HASH: ""+PercentEncode.encode(infoHash),
      TrackerUrl.KEY_PEER_ID: ""+PercentEncode.encode(peerId),
      TrackerUrl.KEY_DOWNLOADED: "0",
      TrackerUrl.KEY_UPLOADED: "0",
      TrackerUrl.KEY_LEFT: "1024",
    };

    {
      TrackerResponse re = manager.createResponse();
      Map<String, Object> responseAsMap = re.createResponse(false);
      unit.expect(responseAsMap[TrackerResponse.KEY_INTERVAL], 60);
      List<Map<String, Object>> peers = responseAsMap[TrackerResponse.KEY_PEERS];
      unit.expect(peers.length, 0);
    }
    {
      TrackerRequest request = new TrackerRequest.fromMap(parameter, "1.2.3.4", [1, 2, 3, 4]);
      manager.update(request);
      TrackerResponse re = manager.createResponse();
      Map<String, Object> responseAsMap = re.createResponse(false);
      unit.expect(responseAsMap[TrackerResponse.KEY_INTERVAL], 60);
      List<Map<String, Object>> peers = responseAsMap[TrackerResponse.KEY_PEERS];
      unit.expect(peers[0][TrackerResponse.KEY_PEER_ID], PercentEncode.encode(peerId));
      unit.expect(peers[0][TrackerResponse.KEY_IP], "1.2.3.4");
      unit.expect(peers[0][TrackerResponse.KEY_PORT], 8080);
    }
  });
}
