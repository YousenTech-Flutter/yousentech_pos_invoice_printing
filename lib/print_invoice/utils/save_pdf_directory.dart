import 'dart:io';

import 'package:path_provider/path_provider.dart';

savePdfDirectory({required pdf, required String title}) async {
  final output = await getApplicationDocumentsDirectory();
  final file = File('${output.path}/$title.pdf');
  await file.writeAsBytes(await pdf);
  Directory? downloadsDirectory = await getApplicationDocumentsDirectory();

  // Generate a unique file name
  String uniqueFileName =
      '$title _${DateTime.now().millisecondsSinceEpoch}.pdf';
  // Move the file to the downloads directory with the unique file name
  String newPath = '${downloadsDirectory.path}/$uniqueFileName';
  await file.copy(newPath);
  // Get.defaultDialog(title: "رسالة اتمام", middleText: "لقد تمت العملية بنجاح");
  // return pdf.save();
}
