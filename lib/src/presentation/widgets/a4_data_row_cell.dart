import 'package:pdf/widgets.dart' as pw;
import 'package:shared_widgets/config/app_invoice_styles.dart';

pw.Expanded a4dataRowCell({
  required text,
  int? expanded,
  bool isTotal = false,
}) {
  return pw.Expanded(
      flex: expanded ?? 1, // Span across two columns
      child: pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Align(
              alignment: pw.Alignment.center,
              child: pw.FittedBox(
                  child: pw.Text(text,
                      style: AppInvoiceStyle.dataRowCellStyle(
                          isTotal: isTotal, fontSize: 8))))));
}
