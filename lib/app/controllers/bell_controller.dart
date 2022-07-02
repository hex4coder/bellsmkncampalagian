import 'package:bellsmkncampalagian/app/data/jadwal_model.dart';
import 'package:get/get.dart';

class BellController extends GetxController {
  final _listJadwal = <Jadwal>[].obs;
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;
  List<Jadwal> get listJadwal => _listJadwal;
}
