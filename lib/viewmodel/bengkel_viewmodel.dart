import '../config/endpoint.dart';
import '../config/model/resp.dart';
import '../config/network.dart';

class BengkelViewmodel {
  Future<Resp> listBengkel({
    String? keyword,
    int? specialistId,
    int? merkMobilId,
  }) async {
    String url = Endpoint.listBengkelUrl;
    List<String> params = [];

    if (keyword != null && keyword.isNotEmpty) {
      params.add("keyword=$keyword");
    }

    if (specialistId != null) {
      params.add("specialist_id=$specialistId");
    }

    if (merkMobilId != null) {
      params.add("merk_mobil_id=$merkMobilId");
    }

    if (params.isNotEmpty) {
      url += "?${params.join("&")}";
    }

    var resp = await Network.getApi(url);
    Resp data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> getMerkMobil() async {
    var resp = await Network.getApi(Endpoint.merkMobilUrl);
    Resp data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> detailBengkel({bengkelId}) async {
    var resp = await Network.getApi("${Endpoint.bengkelUrl}/$bengkelId");
    Resp data = Resp.fromJson(resp);
    return data;
  }

  Future<Resp> bengkelNearby({lat, long, radius}) async {
    var resp = await Network.getApi(
      "${Endpoint.bengkelNearbyUrl}?latitude=$lat&longitude=$long&radius=$radius",
    );
    Resp data = Resp.fromJson(resp);
    return data;
  }
}
