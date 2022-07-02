import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/setjadwal_controller.dart';

class SetjadwalView extends GetView<SetjadwalController> {
  const SetjadwalView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SetjadwalView'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'SetjadwalView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
