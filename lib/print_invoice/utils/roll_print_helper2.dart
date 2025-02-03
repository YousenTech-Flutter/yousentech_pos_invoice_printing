// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_shared_preferences/models/account_journal/data/account_journal.dart';
import 'package:pos_shared_preferences/models/authentication_data/user.dart';
import 'package:pos_shared_preferences/models/customer_model.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import '../domain/invoice_printing_viewmodel.dart';
import '../presentation/widgets/roll_table_row_data.dart';

Future<pw.Document> rollPrint2({PdfPageFormat? format}) async {
  PrintingInvoiceController printingController =
      Get.put(PrintingInvoiceController());
  Customer? company = SharedPr.currentCompanyObject;
  User? user = SharedPr.chosenUserObj;
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
  final pdf = pw.Document(
    version: PdfVersion.pdf_1_5,
    compress: true,
  );
  // final ttf =
  //     await rootBundle.load('assets/fonts/Hacen_Tunisia_Bold_Regular.ttf');
  // print("before");
  // await AppInvoiceStyle.loadFonts();
  // final ttf = await rootBundle.load('assets/fonts/Tajawal-Medium.ttf');
  // print("ttf");
  // final ttf = await rootBundle.load('assets/fonts/Droid_Arabic_Kufi_Bold.ttf');
  // final font = pw.Font.ttf(ttf.buffer.asByteData());
  // final ByteData imageData = await rootBundle.load('assets/images/background.png');
  // final Uint8List bytes = imageData.buffer.asUint8List();
  List listHeder = ["item".tr, "quantity".tr, "price".tr, "total".tr];
  // await AppInvoiceStyle.loadFonts();
  pdf.addPage(pw.Page(
      pageFormat: const PdfPageFormat(
        72 * PdfPageFormat.mm, // 80mm width
        double.infinity, // Example: fixed 200mm height
      ),
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
      margin: const pw.EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      build: (context) => pw.Column(
            children: [
              pw.Container(
                  width: 150,
                  child: pw.Column(
                    children: [
                      infoText(value: printingController.title.tr),
                      pw.SizedBox(height: 5),
                      if (company != null) ...[
                        infoText(value: company.name ?? ""),
                        pw.SizedBox(height: 5),
                        infoText(value: "${'tell'.tr}: ${company.phone ?? ""}"),
                        pw.SizedBox(height: 5),
                        infoText(value: company.email ?? ""),
                      ],
                      pw.Align(
                          alignment: pw.Alignment.center,
                          child:
                              pw.Divider(borderStyle: pw.BorderStyle.dashed)),
                      if (user != null) ...[
                        infoText(value: "${'served_by'.tr} ${user.name!}"),
                        pw.SizedBox(height: 5),
                      ],
                      infoText(
                          isbold: true,
                          isblack: true,
                          value:
                              '${'invoice_nmuber'.tr} : ${printingController.saleOrderInvoice!.invoiceName ?? printingController.saleOrderInvoice!.id}'),
                    ],
                  )),
              pw.SizedBox(height: 10),
              ...productItem(
                  saleOrderLinesList: printingController.saleOrderLinesList!,
                  formatter: formatter,
                  font: AppInvoiceStyle.fontMedium),
              pw.SizedBox(height: 10),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Container(
                    width: 50,
                    alignment: pw.Alignment.center,
                    child: pw.Divider(borderStyle: pw.BorderStyle.dashed)),
              ]),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    infoText(
                      value: "total".tr,
                      isbold: true,
                    ),
                    infoText(
                      value:
                          "${formatter.format(printingController.saleOrderInvoice!.totalPrice)} ${"S.R".tr}",
                      isbold: true,
                    )
                  ]),
              pw.SizedBox(height: 10),
              ...printingController.saleOrderInvoice!.invoiceChosenPayment
                  .map((item) {
                AccountJournal accountJournal = printingController
                    .accountJournalList
                    .firstWhere((e) => e.id == item.id);

                return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      infoText(
                        value:
                            '${SharedPr.lang == 'en' ? accountJournal.name!.enUS : accountJournal.name!.ar001 ?? accountJournal.name!.enUS}',
                        isbold: true,
                      ),
                      infoText(
                        value: '${formatter.format(item.amount)} ${"S.R".tr}',
                        isbold: true,
                      )
                    ]);
              }),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Container(
                    width: 50,
                    alignment: pw.Alignment.center,
                    child: pw.Divider(borderStyle: pw.BorderStyle.dashed)),
              ]),
              pw.SizedBox(height: 10),
              rowFotter(
                  title: "change".tr,
                  value: formatter
                      .format(printingController.saleOrderInvoice!.change)),
              pw.SizedBox(height: 10),
              rowFotter(
                  title: "remaining".tr,
                  value: formatter
                      .format(printingController.saleOrderInvoice!.remaining)),
              if (SharedPr.invoiceSetting!.showSubtotal!) ...[
                pw.SizedBox(height: 10),
                rowFotter(
                    title: 'invoice_footer_total_before_tax'.tr,
                    value: formatter.format(printingController
                        .saleOrderInvoice!.totalPriceWitoutTaxAndDiscount)),
              ],
              pw.SizedBox(height: 10),
              rowFotter(
                  title: 'invoice_footer_total_discount'.tr,
                  value: formatter.format(
                      printingController.saleOrderInvoice!.totalDiscount)),
              pw.SizedBox(height: 10),
              rowFotter(
                  title: 'invoice_footer_total_exclude_tax'.tr,
                  value: formatter.format(
                      printingController.saleOrderInvoice!.totalPriceSubtotal)),
              pw.SizedBox(height: 10),
              rowFotter(
                  title: 'invoice_footer_total_tax'.tr,
                  value: formatter
                      .format(printingController.saleOrderInvoice!.totalTaxes)),
              pw.SizedBox(height: 10),
              pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.BarcodeWidget(
                            data:
                                printingController.saleOrderInvoice!.zatcaQr ??
                                    "",
                            barcode: pw.Barcode.qrCode(),
                            width: 100,
                            height: 100),
                      ])),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    // "$titleDate :${orderDate.toString().substring(0, 10)}",
                    " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? printingController.saleOrderInvoice!.orderDate.toString() : printingController.saleOrderInvoice!.orderDate.toString().substring(0, printingController.saleOrderInvoice!.orderDate!.indexOf('T'))}",
                    style: AppInvoiceStyle.headerStyle(
                        isbold: true, isblack: true, fontsize: 8),
                  ),
                  pw.Text(
                    // "$titleTime :${orderDate.toString().substring(11, 19)}",
                    " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? DateFormat("HH:mm:ss").format(DateTime.now()) : printingController.saleOrderInvoice!.orderDate.toString().substring(printingController.saleOrderInvoice!.orderDate!.indexOf('T') + 1)}",
                    style: AppInvoiceStyle.headerStyle(
                        isbold: true, isblack: true, fontsize: 8),
                  ),
                ],
              ),
            ],
          )));

  return pdf;
}

pw.Align infoText(
    {required String value,
    bool isbold = true,
    bool isblack = true,
    double? fontsize}) {
  return pw.Align(
      alignment: pw.Alignment.center,
      child: pw.Text(
        textDirection: pw.TextDirection.rtl,
        value, // Arabic text
        style: AppInvoiceStyle.headerStyle(
            isblack: isblack, isbold: isbold, fontsize: fontsize ?? 7),
      ));
}

pw.Row rowFotter({
  required String title,
  required String value,
}) {
  return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        infoText(
          value: title,
          isbold: true,
        ),
        infoText(
          value: "$value ${"S.R".tr}",
          isbold: true,
        )
      ]);
}
