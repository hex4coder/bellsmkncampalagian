import 'package:bellsmkncampalagian/app/modules/dashboard/views/dashboard_view.dart';
import 'package:bellsmkncampalagian/app/modules/setjadwal/views/setjadwal_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller.tabController,
        children: const [
          DashboardView(),
          SetjadwalView(),
        ],
      ),
      bottomNavigationBar: TabBar(
          controller: controller.tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey.shade400,
          tabs: const [
            Tab(icon: Icon(CupertinoIcons.home), text: 'Dashboard'),
            Tab(icon: Icon(CupertinoIcons.settings), text: 'Pengaturan Jadwal'),
          ]),
    );
  }
}
