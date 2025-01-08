import 'package:bellsmkncampalagian/app/controllers/bell_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DashboardView'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome To',
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                  Text(
                    'Bell Smkn Campalagian v1.1',
                    style: GoogleFonts.pacifico(
                      fontWeight: FontWeight.w500,
                      fontSize: 32,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  Obx(() => Text(
                        BellController.instance.tanggalSekarang,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                      )),
                  Obx(() => Text(
                        BellController.instance.jamSekarang,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              color: Theme.of(context).primaryColor,
                            ),
                            Obx(
                              () => Text(
                                'Bell hari ini : ${BellController.instance.hari} ${BellController.instance.isLaguNasionalLoop ? "=> L" : "=> NL"}',
                                style: GoogleFonts.pacifico(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Obx(
                          () => Column(
                              children: BellController.instance.listJadwalToday
                                  .map((e) => ListTile(
                                        title: Text(e.waktu ?? ''),
                                        subtitle: Text(
                                            e.tipe?.replaceAll('_', ' ') ?? ''),
                                      ))
                                  .toList()),
                        )
                      ],
                    ),
                  )
                ]),
              ),
            ),
          )
        ],
      ),
    );
  }
}
