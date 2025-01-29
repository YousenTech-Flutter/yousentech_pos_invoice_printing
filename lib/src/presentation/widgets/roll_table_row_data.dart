import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/config/app_invoice_styles.dart';
import '../../../../core/config/app_shared_pr.dart';
import '../../../invoices/data/sale_order_line.dart';
import 'roll_data_row_cell.dart';

List<pw.TableRow> TableRowData(
    {required List<SaleOrderLine> saleOrderLinesList,
    required formatter,
    required font}) {
  return List.generate(
      saleOrderLinesList.length
      // snapshot.data.length
      , (index) {
    SaleOrderLine item = saleOrderLinesList[index];
    return pw.TableRow(
      children: SharedPr.lang == 'en'
          ? [
              dataRowCell(text: item.name!, font: font, isDescrebtion: true),
              dataRowCell(
                  text: formatter.format(item.productUomQty).toString(),
                  font: font),
              dataRowCell(
                  text: formatter.format(item.priceUnit).toString(),
                  font: font),
              dataRowCell(text: formatter.format(item.totalPrice), font: font),
            ]
          : [
              dataRowCell(text: formatter.format(item.totalPrice), font: font),
              dataRowCell(
                  text: formatter.format(item.priceUnit).toString(),
                  font: font),
              dataRowCell(
                  text: formatter.format(item.productUomQty).toString(),
                  font: font),
              dataRowCell(text: item.name!, font: font),
            ],
    );
  });
}

List<pw.Column> productItem(
    {required List<SaleOrderLine> saleOrderLinesList,
    required formatter,
    required font}) {
  return List.generate(
      saleOrderLinesList.length
      // snapshot.data.length
      , (index) {
    SaleOrderLine item = saleOrderLinesList[index];
    return pw.Column(children: [
      productText(value: "${item.name}", isblack: true, isname: true),
      pw.SizedBox(height: 5),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Padding(
            padding: const pw.EdgeInsetsDirectional.only(start: 20),
            child: pw.Row(children: [
              productText(value: "${item.productUomQty}", isblack: true),
              productText(
                value: " x ",
              ),
              productText(
                value: "${formatter.format(item.priceUnit)} ${"S.R".tr}",
              ),
            ])),
        productText(
            value: "${formatter.format(item.totalPrice)} ${"S.R".tr}",
            isblack: true),
      ]),
      pw.SizedBox(height: 10),
    ]);
  });
}

pw.Align productText({
  required String value,
  bool isbold = true,
  bool isname = false,
  bool isblack = true,
}) {
  return pw.Align(
      alignment: pw.AlignmentDirectional.centerStart,
      child: pw.Text(
        textDirection: isname ? pw.TextDirection.rtl : null,
        value,
        style: AppInvoiceStyle.headerStyle(
            isblack: isblack, isbold: isbold, fontsize: 8),
      ));
}
