import 'package:pdf/widgets.dart' as pw;

import 'package:shared_widgets/config/app_invoice_styles.dart';

pw.Padding itemCompany({tital, value, bool? isblack = false}) {
  List listtext = [tital, value];

  return pw.Padding(
      padding: const pw.EdgeInsets.all(2.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          ...listtext.map(
            (e) => pw.Text("$e",
                style: AppInvoiceStyle.headerItemStyle(isblack: isblack)),
          ),
        ],
      ));
}
