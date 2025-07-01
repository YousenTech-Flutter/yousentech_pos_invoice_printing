import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_shared_preferences/models/sale_order_line.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_invoice_colors.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';

import 'roll_data_row_cell.dart';

List<pw.TableRow> rollTableRowData(
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
              rolldataRowCell(
                  text: item.name!, font: font, isDescrebtion: true),
              rolldataRowCell(
                  text: formatter.format(item.productUomQty).toString(),
                  font: font),
              rolldataRowCell(
                  text: formatter.format(item.priceUnit).toString(),
                  font: font),
              rolldataRowCell(
                  text: formatter.format(item.totalPrice), font: font),
            ]
          : [
              rolldataRowCell(
                  text: formatter.format(item.totalPrice), font: font),
              rolldataRowCell(
                  text: formatter.format(item.priceUnit).toString(),
                  font: font),
              rolldataRowCell(
                  text: formatter.format(item.productUomQty).toString(),
                  font: font),
              rolldataRowCell(text: item.name!, font: font),
            ],
    );
  });
}

List<pw.Column> productItem(
    {required List<SaleOrderLine> saleOrderLinesList,
    required formatter,
    required noteImage,
    required font}) {
  return List.generate(
      saleOrderLinesList.length
      // snapshot.data.length
      , (index) {
    SaleOrderLine item = saleOrderLinesList[index];
    return pw.Column(children: [
      productText(value: "${item.name}", isblack: true, isname: true),
      if (item.note !=null) ...[
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
          pw.Image(noteImage, width: 6, height: 6, dpi: 500),
          pw.SizedBox(width: 3),
          productText(value: "${item.note}", isblack: false, isname: true , fontsize: 6, color: AppInvoceColor.gray),
        ])
        
      ],
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
  double? fontsize,
  PdfColor? color,
}) {
  return pw.Align(
      alignment: pw.AlignmentDirectional.centerStart,
      child: pw.Text(
        textDirection: isname ? pw.TextDirection.rtl : null,
        value,
        style: AppInvoiceStyle.headerStyle(
            isblack: isblack, isbold: isbold, fontsize:fontsize?? 8 , color: color),
      ));
}
