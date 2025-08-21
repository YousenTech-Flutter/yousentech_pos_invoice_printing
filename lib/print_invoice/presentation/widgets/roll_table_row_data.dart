import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_shared_preferences/models/sale_order_line.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_colors.dart';
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
    bool isShowNote = false,
    required font}) {
  return List.generate(saleOrderLinesList.length, (index) {
    SaleOrderLine item = saleOrderLinesList[index];
    return pw.Column(children: [
      productText(value: "${item.name}", isblack: true, isname: true),
      if (item.note != null || item.categoryNotes != null) ...[
        if (isShowNote) ...[
          pw.SizedBox(height: 2),
          pw.Row(children: [
            // pw.Image(noteImage, width: 6, height: 6, dpi: 500),
            pw.SizedBox(width: 3),
            productText(
                value: " ${item.note} ",
                isblack: false,
                isname: true,
                fontsize: 6,
                color: AppInvoceColor.gray),
            if (item.categoryNotes != null &&
                item.categoryNotes!.isNotEmpty) ...[
              ...List.generate(item.categoryNotes!.length, (index) {
                return productText(
                    value: " ${item.categoryNotes![index].note} ",
                    isblack: false,
                    isname: true,
                    fontsize: 6,
                    color: AppInvoceColor.gray);
              })
            ]
          ])
        ]
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
              if (!isShowNote) ...[
                productText(
                  value: "${formatter.format(item.priceUnit)} ${"S.R".tr}",
                ),
              ],
            ])),
        if (!isShowNote) ...[
          productText(
              value: "${formatter.format(item.totalPrice)} ${"S.R".tr}",
              isblack: true),
        ]
      ]),
      pw.SizedBox(height: 10),
    ]);
  });
}

Container productAndriodItem({required SaleOrderLine item,
    required formatter,
    bool isShowNote = false,
    required font}) {
  return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(children: [
        productAndriodText(value: "${item.name}", isblack: true, isname: true),
        if (item.note != null || item.categoryNotes != null) ...[
          if (isShowNote) ...[
            SizedBox(height: 2.h),
            Row(children: [
              // pw.Image(noteImage, width: 6, height: 6, dpi: 500),
              SizedBox(width: 3.h),
              productAndriodText(
                  value: " ${item.note} ",
                  isblack: false,
                  isname: true,
                  fontsize: 4.sp,
                  color: AppColor.gray),
              if (item.categoryNotes != null &&
                  item.categoryNotes!.isNotEmpty) ...[
                ...List.generate(item.categoryNotes!.length, (index) {
                  return productAndriodText(
                      value: " ${item.categoryNotes![index].note} ",
                      isblack: false,
                      isname: true,
                      fontsize: 4.sp,
                      color: AppColor.gray);
                })
              ]
            ])
          ]
        ],
        SizedBox(height: 5.h),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: EdgeInsetsDirectional.only(start: 8),
            child: Row(children: [
              productAndriodText(
                  value: "${item.productUomQty}", isblack: true),
              productAndriodText(
                value: " x ",
              ),
              if (!isShowNote) ...[
                productAndriodText(
                  value: "${formatter.format(item.priceUnit)} ${"S.R".tr}",
                ),
              ],
            ]),
          ),
          if (!isShowNote) ...[
            productAndriodText(
                value: "${formatter.format(item.totalPrice)} ${"S.R".tr}",
                isblack: true),
          ]
        ]),
        // SizedBox(height: 10.h),
      ]),
    );

}

pw.Align productText({
  required String value,
  bool isbold = true,
  bool isname = false,
  bool isblack = true,
  bool isAlignmentCenter = false,
  double? fontsize,
  PdfColor? color,
}) {
  return pw.Align(
      alignment: !isAlignmentCenter
          ? pw.AlignmentDirectional.centerStart
          : pw.AlignmentDirectional.center,
      child: pw.Text(
        textDirection: isname ? pw.TextDirection.rtl : null,
        value,
        style: AppInvoiceStyle.headerStyle(
            isblack: isblack,
            isbold: isbold,
            fontsize: fontsize ?? 8,
            color: color),
      ));
}

Align productAndriodText({
  required String value,
  bool isbold = true,
  bool isname = false,
  bool isblack = true,
  bool isAlignmentCenter = false,
  double? fontsize,
  Color? color,
}) {
  return Align(
      alignment: !isAlignmentCenter
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.center,
      child: Text(
        textDirection: isname ? TextDirection.rtl : null,
        value,
        style: TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: fontsize ?? 4.sp,
            // color: (isblack ? AppColor.black : AppColor.gray),
            color: AppColor.black,
            fontWeight: FontWeight.bold),
      ));
}

List<pw.Column> catogProductItem(
    {required List<SaleOrderLine> saleOrderLinesList,
    required formatter,
    bool isShowNote = false,
    required font}) {
  return List.generate(saleOrderLinesList.length, (index) {
    SaleOrderLine item = saleOrderLinesList[index];
    return pw.Column(children: [
      pw.SizedBox(height: 10),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
            width: 15,
            child: productText(
                value: "${index + 1}.", isblack: true, isname: true)),
        pw.Container(
          width: 145,
          child: productText(
            value: buildProductNameWithNotes(item),
            isblack: true,
            isname: true,
          ),
        ),
        pw.Container(
            width: 25,
            child: productText(
                value: "${item.productUomQty}",
                isblack: true,
                isAlignmentCenter: true)),
      ]),
    ]);
  });
}

List<Column> catogProductAndriodItem(
    {required List<SaleOrderLine> saleOrderLinesList,
    required formatter,
    bool isShowNote = false,
    required font}) {
  return List.generate(saleOrderLinesList.length, (index) {
    SaleOrderLine item = saleOrderLinesList[index];
    return Column(children: [
      SizedBox(height: 10.h),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            // width: 15.w,
            child: productAndriodText(
                value: "${index + 1}.", isblack: true, isname: true)),
        SizedBox(
          // width: 145.w,
          child: productAndriodText(
            value: buildProductNameWithNotes(item),
            isblack: true,
            isname: true,
          ),
        ),
        const Spacer(),
        SizedBox(
            // width: 25.w,
            child: productAndriodText(
                value: "${item.productUomQty}",
                isblack: true,
                isAlignmentCenter: true)),
      ]),
    ]);
  });
}

String buildProductNameWithNotes(item) {
  final notes = <String>[];

  if (item.note != null && item.note!.trim().isNotEmpty) {
    notes.add(item.note!.trim());
  }

  if (item.categoryNotes != null && item.categoryNotes!.isNotEmpty) {
    notes.addAll(item.categoryNotes!
        .map((e) => e.note?.trim())
        .where((note) => note != null && note!.isNotEmpty)
        .cast<String>());
  }

  if (notes.isEmpty) {
    return item.name;
  }

  return "${item.name} (${notes.join(', ')})";
}
