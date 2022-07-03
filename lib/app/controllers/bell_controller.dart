// ignore_for_file: unnecessary_this

import 'dart:async';

import 'package:bellsmkncampalagian/app/data/jadwal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    final listHari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Ahad'
    ];
    final d = this;
    final thn = d.year;
    final bln = listBulan[d.month - 1];
    final tgl = d.day.toString().padLeft(2, '0');
    final hari = listHari[d.weekday - 1];
    ret = split ? '$hari, \r\n$tgl $bln $thn' : '$hari, $tgl $bln $thn';

    return ret;
  }

  String getHari() {
    final listHari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Ahad'
    ];
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
  final _isLoading = false.obs;
  final Rx<TimeOfDay> _currentTime = Rx<TimeOfDay>(TimeOfDay.now());
  final Rx<DateTime> _currentDate = Rx<DateTime>(DateTime.now());

  static BellController get instance => Get.find<BellController>();
  bool get isLoading => _isLoading.value;
  List<Jadwal> get listJadwal => _listJadwal;
  TimeOfDay get currentTime => _currentTime.value;
  String get jamSekarang => currentTime.toJam();
  String get tanggalSekarang => _currentDate.value.getTanggal();
  String get hari => _currentDate.value.getHari();

  @override
  void onInit() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentTime.value = TimeOfDay.now();
      _currentDate.value = DateTime.now();
    });
    super.onInit();
  }
}
