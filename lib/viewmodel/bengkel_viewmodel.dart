
import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';

class BengkelViewmodel {

  Future<Resp> listBengkel() async {
    var resp = await Network.getApi(
        Endpoint.listBengkelUrl);
    Resp data = Resp.fromJson(resp);
    return data;
  }
}