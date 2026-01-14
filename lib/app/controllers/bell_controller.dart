// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bellsmkncampalagian/app/data/jadwal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

final listBulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember'
];

final listHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Ahad'];
final listHari2 = [
  'senin',
  'selasa',
  'rabu',
  'kamis',
  'jumat',
  'sabtu',
  'ahad'
];

extension DateTimeParsing on DateTime {
  /// Dapatkan jam dan menit dari timestamp
  String getJamMenit() {
    String ret = '';
    final d = this;
    ret =
        '${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}';

    return ret;
  }

  DateTime forZero() {
    final d = this;
    DateTime ret = DateTime(
      d.year,
      d.month,
      d.day,
    );

    return ret;
  }

  /// Konversi DateTime ke string dalam bahasa Indonesia
  String getTanggal({bool split = false}) {
    String ret = '';

    final d = this;
    final thn = d.year;
    final bln = listBulan[d.month - 1];
    final tgl = d.day.toString().padLeft(2, '0');
    final hari = listHari[d.weekday - 1];
    ret = split ? '$hari, \r\n$tgl $bln $thn' : '$hari, $tgl $bln $thn';

    return ret;
  }

  String getHari() {
    final d = this;
    final hari = listHari[d.weekday - 1];
    return hari;
  }
}

extension on TimeOfDay {
  String toJam() {
    String ret = '';
    ret =
        '${this.hour.toString().padLeft(2, "0")}:${this.minute.toString().padLeft(2, "0")}';
    return ret;
  }
}

class BellController extends GetxController {
  final _listJadwal = <Jadwal>[].obs;
  final _listJadwalToday = <Jadwal>[].obs;
  final _isLoading = false.obs;
  final Rx<TimeOfDay> _currentTime = Rx<TimeOfDay>(TimeOfDay.now());
  final Rx<DateTime> _currentDate = Rx<DateTime>(DateTime.now());
  final AudioPlayer audioPlayer = AudioPlayer();
  final _box = GetStorage();
  final _currentPlaying = ''.obs;
  final _currentTimePlaying = ''.obs;
  final _isBelumMasuk = true.obs;
  final _isLaguNasionalLoop = false.obs;
  final _isSudahPulang = false.obs;

  final _listCustomAssets = <String>[].obs;
  // final _loopAsset = 'sholawat_jibril'.obs; // Deprecated
  final _loopAssets = <String>['sholawat_jibril'].obs;
  final _currentLoopIndex = 0.obs;

  //final _swapMarsPancasila = false.obs; // mars smk pancasila

  Future<void> play(String selectedTipe) async {
    String path = '';
    // jika lagu acak
    // jika lagu acak
    if (selectedTipe ==
        BellController
            .instance.tipeBell[BellController.instance.tipeBell.length - 1]) {
      final r = Random().nextInt(_listLaguNasional.length);
      final laguNasional = _listLaguNasional[r];
      path = 'sound/lagu_nasional/$laguNasional.mp3';
      await audioPlayer.setSourceAsset(path);
    } else {
      // Cek apakah custom asset (ada path separator atau extension yang kita tahu disimpan di dokumen)
      // Logikanya: jika ada di listCustomAssets, maka itu local file
      if (_listCustomAssets.contains(selectedTipe)) {
        final dir = await getApplicationDocumentsDirectory();
        File file = File('${dir.path}/custom_sounds/$selectedTipe');
        if (await file.exists()) {
          await audioPlayer.setSourceDeviceFile(file.path);
        }
      } else {
        path = 'sound/$selectedTipe.wav';
        await audioPlayer.setSourceAsset(path);
      }
    }

    await audioPlayer.setVolume(1.0);
    if (audioPlayer.state == PlayerState.playing) {
      await audioPlayer.stop();
    }
    await audioPlayer.resume();
  }

  static BellController get instance => Get.find<BellController>();

  List<String> get loopAssets => _loopAssets;
  String get loopAsset =>
      _loopAssets.isNotEmpty ? _loopAssets.first : ''; // Fallback for safety
  bool get isSudahPulang => _isSudahPulang.value;
  int get currentLoopIndex => _currentLoopIndex.value;

  bool get isLoopActivated => _isLaguNasionalLoop.value;
  bool get isPlayingBelumMasuk => _isBelumMasuk.value;
  bool get isLoading => _isLoading.value;
  List<Jadwal> get listJadwal => _listJadwal;
  List<Jadwal> get listJadwalToday => _listJadwalToday;
  TimeOfDay get currentTime => _currentTime.value;
  String get jamSekarang => currentTime.toJam();
  String get currentPlaying => _currentPlaying.value;
  String get currentTimePlaying => _currentTimePlaying.value;
  String get tanggalSekarang => _currentDate.value.getTanggal();
  String get hari => _currentDate.value.getHari().toLowerCase();
  List<String> get tipeBell => [
        'pelajar_pancasila',
        'mars_smk',
        'ayo_senam',
        'sholawat_jibril',
        '5_menit_awal_upacara',
        '5_menit_awal_kegiatan_keagamaan',
        '5_menit_awal_jam_ke_1',
        '5_menit_akhir_istirahat',
        '5_menit_akhir_istirahat_1',
        '5_menit_akhir_istirahat_2',
        'jam_ke_1',
        'jam_ke_2',
        'jam_ke_3',
        'jam_ke_4',
        'istirahat',
        'istirahat_1',
        'istirahat_2',
        'jam_ke_5',
        'jam_ke_6',
        'jam_ke_7',
        'jam_ke_8',
        'jam_ke_9',
        'jam_ke_10',
        'jam_ke_11',
        'jam_ke_12',
        'jam_ke_13',
        'jam_ke_14',
        'akhir_pekan_1',
        'akhir_pekan_2',
        'akhir_pelajaran_1',
        'akhir_pelajaran_2',
        'lagu_nasional_acak',
        ..._listCustomAssets
      ];

  final List<String> _listLaguNasional = [
    'bagimu_negeri',
    'bangun_pemuda_pemudi',
    'berkibarlah_benderaku',
    'halo_halo_bandung',
    'maju_tak_gentar',
    'syukur_nasional'
  ];

  final String KEY_LOOP_ACTIVATED = 'loop-activated';
  final String KEY_LOOP_ASSET = 'loop-asset';

  // update status loop lagu nasional
  // update status loop lagu nasional
  void setLoopIsActive(bool loop) {
    _isLaguNasionalLoop.value = loop;
    _box.write(KEY_LOOP_ACTIVATED, loop).then((value) => _box.save());
  }

  void userToggleLoop(bool loop) {
    setLoopIsActive(loop);
    Get.snackbar(
      "Berhasil",
      "Loop ${loop ? 'Diaktifkan' : 'Dinonaktifkan'}",
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // check loop status
  Future checkLoopStatus() async {
    bool? isLoop = _box.read(KEY_LOOP_ACTIVATED);
    setLoopIsActive(isLoop ?? false);

    dynamic savedLoopAssets = _box.read(KEY_LOOP_ASSET);
    if (savedLoopAssets != null) {
      if (savedLoopAssets is List) {
        _loopAssets.assignAll(savedLoopAssets.cast<String>());
      } else if (savedLoopAssets is String) {
        _loopAssets.assignAll([savedLoopAssets]);
      }
    }
  }

  void setLoopAssets(List<String> assets) {
    _loopAssets.assignAll(assets);
    _box.write(KEY_LOOP_ASSET, assets).then((value) => _box.save());
  }

  // Load custom assets
  void loadCustomAssets() {
    List<dynamic>? stored = _box.read('custom_assets');
    if (stored != null) {
      _listCustomAssets.assignAll(stored.cast<String>());
    }
  }

  // Add custom asset
  Future<void> addAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final customDir = Directory('${appDir.path}/custom_sounds');

      if (!await customDir.exists()) {
        await customDir.create(recursive: true);
      }

      String fileName = result.files.single.name;
      // Sanitize filename or ensure uniqueness if needed, acting simple for now

      String newPath = '${customDir.path}/$fileName';
      await file.copy(newPath);

      if (!_listCustomAssets.contains(fileName)) {
        _listCustomAssets.add(fileName);
        await _box.write('custom_assets', _listCustomAssets);
        await _box.save();
      }
      Get.snackbar(
        'Berhasil',
        'Audio berhasil ditambahkan',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteAudio(String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    File file = File('${appDir.path}/custom_sounds/$fileName');

    if (await file.exists()) {
      await file.delete();
    }

    _listCustomAssets.remove(fileName);
    await _box.write('custom_assets', _listCustomAssets);
    await _box.save();
    Get.snackbar(
      'Berhasil',
      'Audio berhasil dihapus',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Import Database from JSON
  // Import Database from JSON
  Future<void> importDatabase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      try {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> jsonMap = jsonDecode(content);

        // Handle jadwal
        if (jsonMap.containsKey('jadwal')) {
          List<dynamic> jsonList = jsonMap['jadwal'];
          List<Jadwal> newJadwal =
              jsonList.map((e) => Jadwal.fromJson(e)).toList();
          await _box.write('jadwal', newJadwal);
          _listJadwal.assignAll(newJadwal);
          _listJadwalToday.assignAll(await loadAllJadwalByHari(hari));
        }

        // Handle loop-active
        if (jsonMap.containsKey('loop-active')) {
          bool loopActive = jsonMap['loop-active'];
          setLoopIsActive(loopActive);
        }

        await _box.save();
        Get.snackbar(
          'Berhasil',
          'Database berhasil diimport',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal import database: $e',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // Export Database to JSON
  Future<void> exportDatabase() async {
    try {
      final data = <String, dynamic>{
        'jadwal': _listJadwal.map((e) => e.toJson()).toList(),
        'loop-active': isLoopActivated,
        'loop-assets': loopAssets,
      };

      String jsonString = jsonEncode(data);
      String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Simpan Database',
          fileName: 'jadwal_backup.json',
          type: FileType.custom,
          allowedExtensions: ['json']);

      if (outputFile != null) {
        File file = File(outputFile);
        await file.writeAsString(jsonString);
        Get.snackbar(
          'Berhasil',
          'Database berhasil diexport',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal export database: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // update status pulang
  void setSudahPulang(bool p) {
    _isSudahPulang.value = p;
  }

  @override
  void onClose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      _listJadwal.assignAll(await loadAllJadwal());

      _listJadwalToday.assignAll(await loadAllJadwalByHari(hari));

      // check loop lagu nasional
      await checkLoopStatus();
      loadCustomAssets();

      final ct = TimeOfDay.now();
      if (ct.hour > 7) {
        _isBelumMasuk.value = false;
      } else if (ct.hour == 7 && ct.minute >= 30) {
        _isBelumMasuk.value = false;
      } else {
        _isBelumMasuk.value = true;
      }
      _currentTime.value = TimeOfDay.now();
      _currentDate.value = DateTime.now();

      if (isSudahPulang) {
        if (isLoopActivated) {
          final Duration? dur = await audioPlayer.getCurrentPosition();
          if (dur != null) {
            if (dur.inSeconds == 0) {
              // nonaktifkan bell nasional
              // play(tipeBell[tipeBell.length - 1]); // putar lagu nasional

              // aktifkan sholawat
              _playSholawat();
            }
          }
        }
      }

      if (listJadwalToday.isNotEmpty) {
        await Future.forEach(listJadwalToday, (Jadwal j) async {
          if (jamSekarang == j.waktu!) {
            if (currentPlaying != j.tipe! && currentTimePlaying != j.waktu!) {
              _currentPlaying.value = j.tipe!;
              _currentTimePlaying.value = j.waktu!;

              if (j.tipe!.startsWith('jam_ke')) {
                // sudah lima menit persiapan
                _isBelumMasuk.value = true;
              } else if (j.tipe!.startsWith('akhir')) {
                // sudah jam pulang
                setSudahPulang(true);
              } else {
                await play(j.tipe!);
              }
            }
          }
        });
      }
    });

    ever(_currentDate, (DateTime time) async {
      // cek jam jika belum jam 7.30 dan belum masuk

      if (currentTime.hour > 7) {
        _isBelumMasuk.value = false;
      }

      if (currentTime.hour == 7 && currentTime.minute >= 30) {
        _isBelumMasuk.value = false;
      }

      if (isPlayingBelumMasuk) {
        // pelajar pancasila masih bisa diputar
        final Duration? dur = await audioPlayer.getCurrentPosition();
        if (dur != null) {
          if (dur.inSeconds == 0) {
            // ini saya nonaktifkan untuk penyesuaian kepsek baru
            // _swapMarsPancasila.value = !_swapMarsPancasila.value;
            // int indexP = _swapMarsPancasila.value ? 1 : 0;
            // play(tipeBell[indexP]); // putar pelajar pancasila atau mars smk

            // buat aturan baru untuk play sholawat
            _playSholawat();
          }
        } else {
          // print("Duration null");
        }
      }
    });

    super.onInit();
  }

  // fungsi untuk putar sholawat
  // fungsi untuk putar sholawat / loop sound
  // fungsi untuk putar sholawat / loop sound
  void _playSholawat() async {
    if (_isBelumMasuk.value || isSudahPulang) {
      if (_loopAssets.isEmpty) return;

      // Get current asset
      String assetToPlay = _loopAssets[_currentLoopIndex.value];

      await play(assetToPlay);

      // Prepare index for next play
      int nextIndex = _currentLoopIndex.value + 1;
      if (nextIndex >= _loopAssets.length) {
        nextIndex = 0;
      }
      _currentLoopIndex.value = nextIndex;
    }
  }

  @override
  void onReady() {
    loadAllJadwal().then((value) => _listJadwal.assignAll(value));
    loadAllJadwalByHari(hari).then((value) {
      _listJadwalToday.assignAll(value);
      // lakukan listening terhadap data
    });
    super.onReady();
  }

  Future<void> saveNewJadwal(Jadwal jadwal) async {
    final allJadwal = await loadAllJadwal();
    List<Jadwal> newData = [...allJadwal, jadwal];
    await _box.write('jadwal', newData);
    await _box.save();

    _listJadwal.assignAll(newData);
    List<Jadwal> list = [];

    if (newData.isNotEmpty) {
      for (Jadwal jadwal in newData) {
        if (jadwal.hari == hari) {
          list.add(jadwal);
        }
      }
    }

    _listJadwalToday.assignAll(list);
    Get.snackbar(
      "Berhasil",
      "Jadwal berhasil disimpan",
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> deleteJadwal(Jadwal jadwal) async {
    List<Jadwal> allJadwal = await loadAllJadwal();
    allJadwal.removeWhere((e) =>
        e.hari == jadwal.hari &&
        e.tipe == jadwal.tipe &&
        e.waktu == jadwal.waktu);
    await _box.write('jadwal', allJadwal);
    await _box.save();

    _listJadwal.assignAll(allJadwal);
    List<Jadwal> list = [];

    if (allJadwal.isNotEmpty) {
      for (Jadwal jadwal in allJadwal) {
        if (jadwal.hari == hari) {
          list.add(jadwal);
        }
      }
    }

    _listJadwalToday.assignAll(list);
  }

  Future<List<Jadwal>> loadAllJadwal() async {
    List<Jadwal> list = [];
    final l = _box.read<List<dynamic>>('jadwal') ?? [];
    for (var i in l) {
      Jadwal jadwal = i is Jadwal ? i : Jadwal.fromJson(i);
      list.add(jadwal);
    }
    return list;
  }

  Future<List<Jadwal>> loadAllJadwalByHari(String hari) async {
    List<Jadwal> list = [];
    final allJadwal = await loadAllJadwal();

    if (allJadwal.isNotEmpty) {
      for (Jadwal jadwal in allJadwal) {
        if (jadwal.hari == hari) {
          list.add(jadwal);
        }
      }
    }

    return list;
  }
}
