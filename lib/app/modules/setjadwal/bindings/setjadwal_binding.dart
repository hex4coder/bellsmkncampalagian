import 'package:get/get.dart';

import '../controllers/setjadwal_controller.dart';

class SetjadwalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SetjadwalController>(
      () => SetjadwalController(),
    );
  }
}
