import 'package:pdf/widgets.dart' as pw;
import 'package:pos_desktop/core/config/app_invoice_styles.dart';

import '../../../../core/utils/translations/ar.dart';
import '../../../../core/utils/translations/en.dart';

pw.Padding headerItem(
    {required titel,
    required value,
    bool isTitalBlck = true,
    bool isValueBlck = false,
    bool isValueBold = false}) {
  return pw.Padding(
      padding: const pw.EdgeInsets.all(2.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("${ar[titel]}",
              style: AppInvoiceStyle.headerStyle(
                  isblack: isTitalBlck, isbold: true, fontsize: 9)),
          pw.Text("$value",
              style: AppInvoiceStyle.headerStyle(
                  isblack: isValueBlck, isbold: isValueBold, fontsize: 9)),
          pw.Text("${en[titel]}",
              style: AppInvoiceStyle.headerStyle(
                  isblack: isTitalBlck, isbold: true, fontsize: 9)),
        ],
      ));
}
