import 'package:pdf/widgets.dart' as pw;
import 'package:pos_desktop/features/invoice_printing/presentation/widgets/a4_item_company.dart';

import '../../../../core/config/app_invoice_colors.dart';
import '../../../../core/config/app_invoice_styles.dart';
import '../../../../core/utils/translations/ar.dart';
import '../../../../core/utils/translations/en.dart';
import '../../../basic_data_management/customer/data/customer.dart';

pw.Padding companyDetailItem(Customer company, String tital) {
  final companyInfo = [
    {'key': 'street', 'value': company.street},
    {'key': 'building_no', 'value': company.buildingNo},
    {'key': 'district', 'value': company.district},
    {'key': 'city', 'value': company.city},
    {'key': 'country', 'value': company.country},
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
