// ignore_for_file: constant_identifier_names

class Jadwal {
  String? hari;
  String? tipe;
  String? waktu;

  Jadwal({this.hari, this.tipe, this.waktu});

  Jadwal.fromJson(Map<String, dynamic> json) {
    hari = json['hari'];
    tipe = json['tipe'] ?? 'pelajar_pancasila';
    waktu = json['waktu'] ?? '07:30';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['hari'] = hari;
    data['tipe'] = tipe;
    data['waktu'] = waktu;
    return data;
  }
}
