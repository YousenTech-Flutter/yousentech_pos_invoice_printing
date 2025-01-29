import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/config/app_colors.dart';
import '../../../core/config/app_shared_pr.dart';
import '../../basic_data_management/customer/data/customer.dart';
import '../domain/invoice_printing_viewmodel.dart';
import '../presentation/widgets/roll_data_row_cell.dart';
import '../presentation/widgets/roll_date_time.dart';
import '../presentation/widgets/roll_fottor_item.dart';
import '../presentation/widgets/roll_table_row_data.dart';

Future<pw.Document> rollPrint({required PdfPageFormat format}) async {
  PrintingInvoiceController printingController =
      Get.put(PrintingInvoiceController());
  Customer? company = SharedPr.currentCompanyObject;
  final intl.NumberFormat formatter = intl.NumberFormat('#,##0.00', 'en_US');
  bool isFind =
      printingController.saleOrderInvoice!.orderDate.toString().contains('T');
  String myString =
      "تاريخ الترحيل:${isFind ? printingController.saleOrderInvoice!.orderDate.toString().substring(0, 11).toString() : printingController.saleOrderInvoice!.orderDate.toString()
      // snapshot.data[0]['date_order'].toString().substring(0, 11).toString()
      }\n وقت الترحيل:  ${isFind ? printingController.saleOrderInvoice!.orderDate.toString().substring(11, 19).toString() : DateFormat("HH:mm:ss").format(DateTime.now())
      // snapshot.data[0]['date_order'].toString().substring(11, 19).toString()
      }\n إجمالي الفاتورة:  ${printingController.saleOrderInvoice!.totalPrice
      // snapshot.data[0]["total_invoice"].toString()
      } \n اسم الشركة: ${company?.name} \n الرقم الضريبي: ${company?.vat.toString()}  ";
  List<int> bytes = utf8.encode(myString);
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

  // final ttf = await rootBundle.load('assets/fonts/Tajawal-Medium.ttf');
  final ttf = await rootBundle.load('assets/fonts/ARIALBD.TTF');
  final font = pw.Font.ttf(ttf.buffer.asByteData());

  List listHeder = ["item".tr, "quantity".tr, "price".tr, "total".tr];
  pdf.addPage(pw.Page(
      // pageFormat: PdfPageFormat(
      //   80 * PdfPageFormat.mm, // 80mm width
      //   double.infinity, // Example: fixed 200mm height
      // ),
      textDirection:
          SharedPr.lang == 'en' ? pw.TextDirection.ltr : pw.TextDirection.rtl,
      // pageFormat: format,
      // PdfPageFormat(
      //   80 * mm,
      //   double.maxFinite,
      //   marginAll: 5 * mm,
      // ),

      // orientation: pw.PageOrientation.landscape,
      // textDirection: lang == "ar" ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      // margin: const pw.EdgeInsets.symmetric(
      //   horizontal: 10,
      //   vertical: 10,
      // ),
      build: (context) => pw.Column(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Align(
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        printingController.title.tr, // Arabic text
                        style: pw.TextStyle(font: font, fontSize: 25),
                      )),
                  pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.BarcodeWidget(
                                data: base64Encode(bytes),
                                barcode: pw.Barcode.qrCode(),
                                width: 100,
                                height: 100),
                          ])),
                  // if (SharedPr.invoiceSetting!.showOrderNumber!) ...[
                  pw.Text(
                    '${'invoice_nmuber'.tr} : ${printingController.saleOrderInvoice!.invoiceName ?? printingController.saleOrderInvoice!.id}',
                    style: pw.TextStyle(font: font, fontSize: 14),
                  ),
                  // ],
                  dateTime(
                      titleDate: 'invoice_date'.tr,
                      titleTime: 'invoice_time'.tr,
                      orderDate: printingController.saleOrderInvoice!.orderDate,
                      font: font),
                  pw.Divider(),
                  pw.SizedBox(height: 10),
                ],
              ),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                      decoration: pw.BoxDecoration(
                          color: PdfColor(
                        AppColor.backgroundTable.red / 255.0,
                        AppColor.backgroundTable.green / 255.0,
                        AppColor.backgroundTable.blue / 255.0,
                      )),
                      children: SharedPr.lang == 'en'
                          ? [
                              ...List.generate(listHeder.length, (index) {
                                return dataRowCell(
                                    font: font,
                                    text: listHeder[index],
                                    isHeader: true);
                              }),
                            ]
                          : [
                              ...List.generate(listHeder.length, (index) {
                                return dataRowCell(
                                    font: font,
                                    text: listHeder.reversed.toList()[index],
                                    isHeader: true);
                              }),
                            ]),
                  ...TableRowData(
                      saleOrderLinesList:
                          printingController.saleOrderLinesList!,
                      formatter: formatter,
                      font: font),
                  // ...tableRows,
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                  width: double.infinity,
                  color: PdfColor(
                    AppColor.backgroundTable.red / 255.0,
                    AppColor.backgroundTable.green / 255.0,
                    AppColor.backgroundTable.blue / 255.0,
                  ),
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (SharedPr.invoiceSetting!.showSubtotal!) ...[
                        fotterItem(
                            font: font,
                            text:
                                '${'invoice_footer_total_before_tax'.tr} : ${formatter.format(printingController.saleOrderInvoice!.totalPriceWitoutTaxAndDiscount)} SR'),
                      ],
                      fotterItem(
                          font: font,
                          text:
                              '${'invoice_footer_total_discount'.tr} : ${formatter.format(printingController.saleOrderInvoice!.totalDiscount)} SR'),
                      fotterItem(
                          font: font,
                          text:
                              '${'invoice_footer_total_exclude_tax'.tr} : ${formatter.format(printingController.saleOrderInvoice!.totalPriceSubtotal)} SR'),
                      fotterItem(
                          font: font,
                          text:
                              '${'invoice_footer_total_tax'.tr} : ${formatter.format(printingController.saleOrderInvoice!.totalTaxes)} SR'),
                    ],
                  )),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // ...jsonDecode(
                  // snapshot.data[0]["payments"]
                  // )
                  fotterItem(
                      padding: 8,
                      text:
                          '${'total_due'.tr} : ${formatter.format(printingController.saleOrderInvoice!.totalPrice)} SR',
                      font: font),

                  ...printingController.saleOrderInvoice!.invoiceChosenPayment
                      .map((item) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            textDirection: pw.TextDirection.rtl,
                            '${printingController.accountJournalList.firstWhere((e) => e.id == item.id).name!.enUS} : ${formatter.format(item.amount)} SR',
                            style: pw.TextStyle(font: font, fontSize: 14),
                          ))),
                  // pw.Padding(
                  //     padding: const pw.EdgeInsets.all(8.0),
                  //     child: pw.Text(
                  //       '${'paid'.tr} : ${saleOrderInvoice.totalPrice - saleOrderInvoice.remaining
                  //       // saleOrderInvoice.snapshot.data[0]["total_invoice"] + snapshot.data[0]["remaining_amount"]
                  //       }',
                  //       style: pw.TextStyle(font: font, fontSize: 14),
                  //     )),
                  pw.Divider(),
                  fotterItem(
                      padding: 8,
                      text:
                          '${'remaining'.tr} : ${formatter.format(printingController.saleOrderInvoice!.remaining)} SR',
                      font: font),
                  fotterItem(
                      padding: 8,
                      text:
                          '${'change'.tr} : ${formatter.format(printingController.saleOrderInvoice!.change)} SR',
                      font: font),
                ],
              )
            ],
          )));

  return pdf;
}
