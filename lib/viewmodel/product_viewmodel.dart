
import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';

class ProductViewmodel {

  Future<Resp> products() async {
    var resp = await Network.getApi(
        Endpoint.productUrl);
    Resp data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> detailProduct({id}) async {
    var resp = await Network.getApi(
        "${Endpoint.productUrl}/$id");
    Resp data = Resp.fromJson(resp);
    return data;
  }
}