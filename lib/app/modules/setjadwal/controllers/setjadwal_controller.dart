import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bellsmkncampalagian/app/controllers/bell_controller.dart';
import 'package:bellsmkncampalagian/app/data/jadwal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';

extension on TimeOfDay {
  String toJam() {
    String ret = '';
    ret =
        '${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}';
    return ret;
  }
}

class SetjadwalController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  final fbKey = GlobalKey<FormBuilderState>();
  final Rx<TimeOfDay> _currentTimeSelected = Rx<TimeOfDay>(TimeOfDay.now());
  final RxString _selectedTipe = RxString(BellController.instance.tipeBell[0]);
  final _isPlaying = false.obs;
  final _showForm = false.obs;
  final TextEditingController passwordController = TextEditingController();

  final List<String> _listLaguNasional = [
    'bagimu_negeri',
    'bangun_pemuda_pemudi',
    'berkibarlah_benderaku',
    'halo_halo_bandung',
    'maju_tak_gentar',
    'syukur_nasional'
  ];

  TimeOfDay get selectedTime => _currentTimeSelected.value;
  String get jam => selectedTime.toJam();
  String get selectedTipe => _selectedTipe.value;
  bool get isPlaying => _isPlaying.value;
  bool get showForm => _showForm.value;

  @override
  void onInit() {
    audioPlayer.onPlayerStateChanged.listen((event) {
      _isPlaying.value = event == PlayerState.playing;
    });
    super.onInit();
  }

  void login() {
    final password = passwordController.text;
    if (password != 'ua4ever') {
      Get.snackbar('Error', 'Password tidak valid !',
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade500);
    } else {
      Get.snackbar('Sukses', 'Autentikasi berhasil.',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade500);
      passwordController.text = '';
      setShowForm(true);
    }
  }

  void setShowForm(bool v) {
    _showForm.value = v;
  }

  void setSelectedTipe(String newTipe) {
    _selectedTipe.value = newTipe;
  }

  void setSelectedTime(TimeOfDay newTime) {
    _currentTimeSelected.value = newTime;
  }

  Future<void> play() async {
    await audioPlayer.stop();
    await audioPlayer.setVolume(1.0);

    // jika lagu acak
    if (selectedTipe ==
        BellController
            .instance.tipeBell[BellController.instance.tipeBell.length - 1]) {
      final r = Random().nextInt(_listLaguNasional.length);
      final laguNasional = _listLaguNasional[r];

      final path = 'sound/lagu_nasional/$laguNasional.mp3';
      await audioPlayer.setSourceAsset(path);
      await audioPlayer.play(AssetSource(path));
    }
    // jika bukan lagu acak nasional
    else {
      final path = 'sound/$selectedTipe.wav';
      await audioPlayer.setSourceAsset(path);
      await audioPlayer.play(AssetSource(path));
    }
  }

  Future<void> stop() async {
    await audioPlayer.stop();
  }

  @override
  void onClose() {
    audioPlayer.stop();
    audioPlayer.audioCache.clearAll().then((value) => audioPlayer.stop());
    super.onClose();
  }

  void submitForm() async {
    if (fbKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> map = Map.from(fbKey.currentState!.value);
      map.putIfAbsent('waktu', () => jam);
      await BellController.instance.saveNewJadwal(Jadwal.fromJson(map));
    }
  }
}
