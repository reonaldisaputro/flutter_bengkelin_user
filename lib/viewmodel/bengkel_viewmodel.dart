
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

  Future<Resp> detailBengkel({bengkelId}) async {
    var resp = await Network.getApi("${Endpoint.bengkelUrl}/$bengkelId");
    Resp data = Resp.fromJson(resp);
    return data;
  }
  
  Future<Resp> bengkelNearby({lat,long,radius}) async {
    var resp = await Network.getApi("${Endpoint.bengkelNearbyUrl}?latitude=$lat&longitude=$long&radius=$radius");
    Resp data = Resp.fromJson(resp);
    return data;
  }
}