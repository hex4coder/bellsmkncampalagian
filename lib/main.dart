import 'package:bellsmkncampalagian/app/controllers/bell_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(BellController());
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bell SMKN Campalagian",
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blue.shade50,
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
