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
  final RxString _selectedTipe = RxString(
      BellController.instance.tipeBell.isNotEmpty
          ? BellController.instance.tipeBell[0]
          : '');
  final Rx<Jadwal?> _editingJadwal = Rx<Jadwal?>(null); // State for editing
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
  bool get isEditing => _editingJadwal.value != null;
  Jadwal? get editingJadwal => _editingJadwal.value;

  @override
  void onInit() {
    audioPlayer.onPlayerStateChanged.listen((event) {
      _isPlaying.value = event == PlayerState.playing;
    });

    // Listen to BellController assets changes
    // Not strictly needed if TipeBell is Obx in UI and selectedTipe logic is safe.

    // Better: listen to tipeBell changes implicitly or explicitly?
    // tipeBell is a getter derived from _bundledAssets and _listCustomAssets.
    // We can just rely on Obx in UI, but for specific logic:
    if (_selectedTipe.value.isEmpty &&
        BellController.instance.tipeBell.isNotEmpty) {
      _selectedTipe.value = BellController.instance.tipeBell[0];
    }

    // We should listen to the underlying list in BellController to auto-select first item when loaded
    // But BellController doesn't expose the RxList directly via getter (it exposes List<String>).
    // Let's just fix the initial crash first. The UI dropdown will handle the rest via Obx.

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

    // Guard against empty tipeBell
    if (BellController.instance.tipeBell.isEmpty) {
      Get.snackbar('Error', 'Tidak ada asset audio tersedia.');
      return;
    }

    // jika lagu acak
    if (selectedTipe == 'lagu_nasional_acak' ||
        (BellController.instance.tipeBell.isNotEmpty &&
            selectedTipe ==
                BellController.instance
                    .tipeBell[BellController.instance.tipeBell.length - 1])) {
      // Fallback logic if 'lagu_nasional_acak' string is used or if it's the last item (legacy)
      // Ideally we rely on the string check now.

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

  void startEditing(Jadwal jadwal) {
    _editingJadwal.value = jadwal;

    // Populate form fields
    if (fbKey.currentState != null) {
      fbKey.currentState!.patchValue({
        'hari': jadwal.hari,
        'tipe': jadwal.tipe,
      });
    }

    // Set time
    if (jadwal.waktu != null) {
      final parts = jadwal.waktu!.split(':');
      if (parts.length == 2) {
        _currentTimeSelected.value = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0);
      }
    }

    // Set selected tipe for dropdown sync
    if (jadwal.tipe != null) {
      setSelectedTipe(jadwal.tipe!);
    }

    // Scroll to form (handled by UI state change usually, assuming form is visible)
  }

  void cancelEditing() {
    _editingJadwal.value = null;
    fbKey.currentState?.reset();
    _currentTimeSelected.value = TimeOfDay.now();
    // Reset selected tipe to default
    if (BellController.instance.tipeBell.isNotEmpty) {
      setSelectedTipe(BellController.instance.tipeBell[0]);
    }
  }

  void submitForm() async {
    if (fbKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> map = Map.from(fbKey.currentState!.value);
      map.putIfAbsent('waktu', () => jam);

      Jadwal newJadwalData = Jadwal.fromJson(map);

      if (isEditing) {
        await BellController.instance
            .updateJadwal(_editingJadwal.value!, newJadwalData);
        cancelEditing(); // Reset after update
      } else {
        await BellController.instance.saveNewJadwal(newJadwalData);
      }
    }
  }
}
