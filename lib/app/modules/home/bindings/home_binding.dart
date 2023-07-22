import 'package:bellsmkncampalagian/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:bellsmkncampalagian/app/modules/setjadwal/controllers/setjadwal_controller.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
    );
    Get.lazyPut<SetjadwalController>(
      () => SetjadwalController(),
    );
  }
}
