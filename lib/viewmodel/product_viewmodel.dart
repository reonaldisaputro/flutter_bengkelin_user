
import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';

class ProductViewmodel {

  Future<Resp> products({
    int page = 1,
    String? keyword,
    int? categoryId,
    int? minPrice,
    int? maxPrice,
  }) async {
    String url = "${Endpoint.productUrl}?page=$page";

    if (keyword != null && keyword.isNotEmpty) {
      url += "&keyword=$keyword";
    }

    if (categoryId != null) {
      url += "&category_id=$categoryId";
    }

    if (minPrice != null) {
      url += "&min_price=$minPrice";
    }

    if (maxPrice != null) {
      url += "&max_price=$maxPrice";
    }

    var resp = await Network.getApi(url);
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