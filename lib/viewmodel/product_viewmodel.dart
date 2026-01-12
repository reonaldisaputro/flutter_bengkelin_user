
import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';

class ProductViewmodel {

  Future<Resp> products({int page = 1}) async {
    var resp = await Network.getApi(
        "${Endpoint.productUrl}?page=$page");
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