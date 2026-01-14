// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:math';

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

  //final _swapMarsPancasila = false.obs; // mars smk pancasila

  Future<void> play(String selectedTipe) async {
    String path = '';
    // jika lagu acak
    if (selectedTipe ==
        BellController
            .instance.tipeBell[BellController.instance.tipeBell.length - 1]) {
      final r = Random().nextInt(_listLaguNasional.length);
      final laguNasional = _listLaguNasional[r];
      path = 'sound/lagu_nasional/$laguNasional.mp3';
    }
    // jika bukan lagu acak nasional
    else {
      path = 'sound/$selectedTipe.wav';
    }

    await audioPlayer.setSourceAsset(path);
    await audioPlayer.setVolume(1.0);
    if (audioPlayer.state == PlayerState.playing) {
      await audioPlayer.stop();
    }
    await audioPlayer.play(AssetSource(path));
  }

  static BellController get instance => Get.find<BellController>();
  bool get isSudahPulang => _isSudahPulang.value;
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

  // update status loop lagu nasional
  void setLoopIsActive(bool loop) {
    _isLaguNasionalLoop.value = loop;
    _box.write(KEY_LOOP_ACTIVATED, loop).then((value) => _box.save());
  }

  // check loop status
  Future checkLoopStatus() async {
    bool? isLoop = _box.read(KEY_LOOP_ACTIVATED);
    setLoopIsActive(isLoop ?? false);
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
  void _playSholawat() {
    int indexSholawat = tipeBell.indexOf("sholawat_jibril");
    if (_isBelumMasuk.value || isSudahPulang) {
      // belum masuk jadi bisa putar sholawat
      play(tipeBell[indexSholawat]);
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
