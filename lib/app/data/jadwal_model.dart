// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum TipeWaktu {
  PELAJAR_PANCASILA,
  JAMKE_1,
  JAMKE_2,
  JAMKE_3,
  JAMKE_4,
  JAM_ISTIRAHAT1,
  JAMKE_5,
  JAMKE_6,
  JAMKE_7,
  JAM_ISTIRAHAT2,
  JAMKE_8,
  JAMKE_9,
  JAM_PULANG
}

class Jadwal {
  String? hari;
  TipeWaktu? jamke;
  TimeOfDay? waktu;

  Jadwal({this.hari, this.jamke, this.waktu});

  Jadwal.fromJson(Map<String, dynamic> json) {
    hari = json['hari'];
    jamke = json['jamke'] ?? TipeWaktu.PELAJAR_PANCASILA;
    waktu = json['waktu'] ?? TimeOfDay.now();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['hari'] = hari;
    data['jamke'] = jamke;
    data['waktu'] = waktu;
    return data;
  }
}
