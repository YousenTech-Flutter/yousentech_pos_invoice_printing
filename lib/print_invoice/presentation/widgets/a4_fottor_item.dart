import 'package:pdf/widgets.dart' as pw;
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:shared_widgets/utils/translations/ar.dart';
import 'package:shared_widgets/utils/translations/en.dart';

pw.Padding a4fotterItem({
  required titel,
  required value,
  bool isPyment = false,
  bool isAll = false,
}) {
  return pw.Padding(
      padding: const pw.EdgeInsets.all(2.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(isPyment ? titel : "${ar[titel]} / ${en[titel]}",
              style: AppInvoiceStyle.fotterTitalInvoiceStyle(
                  isAll: isAll, fontSize: 8)),
          pw.Text("$value",
              style: AppInvoiceStyle.fotterValueInvoiceStyle(fontSize: 8)),
        ],
      ));
}
