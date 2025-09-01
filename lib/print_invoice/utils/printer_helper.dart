import 'package:printing/printing.dart';

class PrintHelper {
// to print invoice
  static Future setDefaultPrinter() async {
    List<Printer> listPrinters = await getPrinters();
    return listPrinters.isEmpty? null : listPrinters.firstWhere((element) => element.isDefault);
  }

  static Future<List<Printer>> getPrinters() async {
    return  await Printing.listPrinters();
  }
}
