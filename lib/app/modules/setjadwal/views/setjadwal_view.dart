import 'package:bellsmkncampalagian/app/controllers/bell_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/setjadwal_controller.dart';

class SetjadwalView extends GetView<SetjadwalController> {
  const SetjadwalView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal / Waktu Bell'),
        centerTitle: true,
      ),
      body: SizedBox.fromSize(
        size: MediaQuery.of(context).size,
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  child: FormBuilder(
                    key: controller.fbKey,
                    child: SizedBox(
                      height: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Form Penginputan Jadwal',
                                style: GoogleFonts.pacifico(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24,
                                )),
                            const Divider(),
                            const SizedBox(
                              height: 8,
                            ),
                            Obx(
                              () => FormBuilderDropdown(
                                decoration:
                                    const InputDecoration(labelText: 'Hari'),
                                items: listHari
                                    .map((e) => DropdownMenuItem(
                                          value: e.toLowerCase(),
                                          child: Text(e),
                                        ))
                                    .toList(),
                                name: 'hari',
                                initialValue: BellController.instance.hari,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            FormBuilderDropdown(
                              decoration:
                                  const InputDecoration(labelText: 'Tipe Bell'),
                              items: BellController.instance.tipeBell
                                  .map((e) => DropdownMenuItem(
                                        value: e.toLowerCase(),
                                        child: Text(e),
                                      ))
                                  .toList(),
                              onChanged: (String? selected) {
                                if (selected != null) {
                                  controller.setSelectedTipe(selected);
                                }
                              },
                              name: 'tipe',
                              initialValue: controller.selectedTipe,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Obx(
                              () => TextButton.icon(
                                label: Text(
                                    controller.isPlaying ? 'Stop' : 'Test'),
                                onPressed: () async {
                                  controller.isPlaying
                                      ? await controller.stop()
                                      : await controller.play();
                                },
                                icon: Icon(controller.isPlaying
                                    ? CupertinoIcons.stop
                                    : CupertinoIcons.play),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Text('Waktu : '),
                                Obx(() => Text(controller.jam)),
                                const Spacer(),
                                TextButton.icon(
                                  label: const Text('Set Waktu'),
                                  onPressed: () async {
                                    final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now());

                                    if (time != null) {
                                      controller.setSelectedTime(time);
                                    }
                                  },
                                  icon: const Icon(CupertinoIcons.clock),
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 32,
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                              ),
                              onPressed: controller.submitForm,
                              icon: const Icon(CupertinoIcons.calendar_today),
                              label: const Text('Simpan Jadwal'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  height: double.infinity,
                  color: const Color(0xfffdfdfd),
                  child: Obx(
                    () => DataTable(
                        showBottomBorder: true,
                        columns: const [
                          DataColumn(label: Text('Hari')),
                          DataColumn(label: Text('Waktu')),
                          DataColumn(
                            label: Text('Tipe Bell'),
                          ),
                          DataColumn(
                            label: Text('Opsi'),
                          ),
                        ],
                        rows: BellController.instance.listJadwal
                            .map((e) => DataRow(cells: [
                                  DataCell(Text(e.hari ?? '')),
                                  DataCell(Text(e.waktu ?? '')),
                                  DataCell(Text(e.tipe ?? '')),
                                  DataCell(TextButton.icon(
                                      onPressed: () => BellController.instance
                                          .deleteJadwal(e),
                                      icon: const Icon(
                                        CupertinoIcons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ))),
                                ]))
                            .toList()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
