import 'package:pdf/widgets.dart' as pw;
import 'package:pos_shared_preferences/models/customer_model.dart';
import 'package:shared_widgets/config/app_invoice_colors.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:shared_widgets/utils/translations/ar.dart';
import 'package:shared_widgets/utils/translations/en.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/presentation/widgets/a4_item_company.dart';

pw.Padding companyDetailItem(Customer company, String tital) {
  final companyInfo = [
    {'key': 'street', 'value': company.street},
    {'key': 'building_no', 'value': company.buildingNo},
    {'key': 'district', 'value': company.district},
    {'key': 'city', 'value': company.city},
    {'key': 'country', 'value': company.country?.countryName},
    {'key': 'postal_code', 'value': company.postalCode},
    {'key': 'additional_no', 'value': company.additionalNo},
    {'key': 'vat_no', 'value': company.vat},
  ];
  return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 20),
      child: pw.Column(children: [
        pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
          pw.Text(tital, style: AppInvoiceStyle.headerCompanyStyle()),
        ]),
        pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
          pw.Text("${company.name}",
              style: AppInvoiceStyle.headerCompanyStyle(fontSize: 9)),
        ]),
        pw.Divider(thickness: 0.0000001),
        ...companyInfo.map(
          (e) => itemCompany(
              tital: "${ar[e['key']]}   ${en[e['key']]} :",
              value: e['value'] ?? ""),
        ),
        pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
        itemCompany(
          tital: "${ar['other_identifier']} ${en['other_identifier']} :",
          isblack: true,
          value: company.otherSelleId ?? "",
        ),
      ]));
}
