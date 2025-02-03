import 'package:pdf/widgets.dart' as pw;
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:shared_widgets/utils/translations/ar.dart';
import 'package:shared_widgets/utils/translations/en.dart';

pw.Expanded headerTableItem({
  required text,
  int? expanded,
}) {
  List textlist = [ar[text]!, en[text]!];

  return pw.Expanded(
      flex: expanded ?? 1, // Span across two columns
      child: pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Column(
                  // alignment: pw.Alignment.center,
                  children: [
                    ...textlist.map((e) => pw.Text(e,
                        style: AppInvoiceStyle.headerCompanyStyle(fontSize: 8)))
                  ]))));
}
