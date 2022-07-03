// ignore_for_file: unnecessary_this

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bellsmkncampalagian/app/data/jadwal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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

  Future<void> play(String selectedTipe) async {
    final path = 'sound/$selectedTipe.wav';
    await audioPlayer.setSourceAsset(path);
    await audioPlayer.setVolume(1.0);
    if (audioPlayer.state == PlayerState.playing) {
      await audioPlayer.stop();
    }
    await audioPlayer.play(AssetSource(path));
  }

  static BellController get instance => Get.find<BellController>();
  bool get isLoading => _isLoading.value;
  List<Jadwal> get listJadwal => _listJadwal;
  List<Jadwal> get listJadwalToday => _listJadwalToday;
  TimeOfDay get currentTime => _currentTime.value;
  String get jamSekarang => currentTime.toJam();
  String get currentPlaying => _currentPlaying.value;
  String get tanggalSekarang => _currentDate.value.getTanggal();
  String get hari => _currentDate.value.getHari().toLowerCase();
  List<String> get tipeBell => [
        'pelajar_pancasila',
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
        'akhir_pekan_1',
        'akhir_pekan_2',
        'akhir_pelajaran_1',
        'akhir_pelajaran_2',
      ];

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
      _currentTime.value = TimeOfDay.now();
      _currentDate.value = DateTime.now();

      if (listJadwalToday.isNotEmpty) {
        for (var j in listJadwalToday) {
          if (jamSekarang == j.waktu!) {
            if (currentPlaying != j.tipe!) {
              _currentPlaying.value = j.tipe!;
              await play(j.tipe!);
            }
          }
        }
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    loadAllJadwal().then((value) => _listJadwal.assignAll(value));
    loadAllJadwalByHari(hari)
        .then((value) => _listJadwalToday.assignAll(value));
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

    list.sort((a, b) => a.waktu!.compareTo(b.waktu!));
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
