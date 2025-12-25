import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_shared_preferences/helper/app_enum.dart';
import 'package:pos_shared_preferences/models/account_journal/data/account_journal.dart';
import 'package:pos_shared_preferences/models/authentication_data/user.dart';
import 'package:pos_shared_preferences/models/customer_model.dart';
import 'package:pos_shared_preferences/models/sale_order_line.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import '../domain/invoice_printing_viewmodel.dart';
import '../presentation/widgets/roll_table_row_data.dart';

Future<pw.Document> rollPrint2(
    {PdfPageFormat? format,
    isdownloadRoll = false,
    List<SaleOrderLine>? items}) async {
  PrintingInvoiceController printingController =
      Get.put(PrintingInvoiceController());
  Customer? company = SharedPr.currentCompanyObject;
  User? user = SharedPr.chosenUserObj;
  final intl.NumberFormat formatter = intl.NumberFormat('#,##0.00', 'en_US');
  late var companyImage;
  if (company?.image != null && company?.image != '') {
    companyImage = pw.MemoryImage(base64Decode(company!.image!));
  }
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
  List listHeder = ["item".tr, "quantity".tr, "price".tr, "total".tr];
  List<String> headerLines = SharedPr.currentPosObject!.invoiceHeaderLines == ''
      ? []
      : SharedPr.currentPosObject!.invoiceHeaderLines!.trim().split('\n');
  List<String> footerLines = SharedPr.currentPosObject!.invoiceFooterLines == ''
      ? []
      : SharedPr.currentPosObject!.invoiceFooterLines!.trim().split('\n');
  if (isdownloadRoll) {
    pdf.addPage(pw.Page(
        pageFormat: const PdfPageFormat(
          72 * PdfPageFormat.mm, // 80mm width
          double.infinity, // Example: fixed 200mm height
        ),
        textDirection:
            SharedPr.lang == 'en' ? pw.TextDirection.ltr : pw.TextDirection.rtl,
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
                        if (company?.image != null && company?.image != '') ...[
                          pw.Container(
                            height: 30,
                            width: 30,
                            child: pw.Image(companyImage),
                          ),
                          pw.SizedBox(height: 5),
                        ],
                        infoText(
                            value: printingController
                                            .saleOrderInvoice!.refundNote !=
                                        null &&
                                    printingController
                                            .saleOrderInvoice!.refundNote !=
                                        ''
                                ? "${"invoice".tr} ${'credit_note'.tr}"
                                : printingController.title.tr),
                        if (company != null) ...[
                          pw.SizedBox(height: 5),
                          infoText(value: company.name ?? ""),
                          if (company.phone != null && company.phone != '') ...[
                            pw.SizedBox(height: 5),
                            infoText(
                                value: "${'tell'.tr}: ${company.phone ?? ""}"),
                          ],
                          pw.SizedBox(height: 5),
                          infoText(value: company.email ?? ""),
                        ],
                        ...headerLines.map(
                          (line) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 5),
                              child: infoText(value: line)),
                        ),
                        pw.Align(
                            alignment: pw.Alignment.center,
                            child:
                                pw.Divider(borderStyle: pw.BorderStyle.dashed)),
                        if (user != null &&
                            (SharedPr.invoiceSetting?.showCreatorUsername !=
                                    null &&
                                SharedPr.invoiceSetting!.showCreatorUsername ==
                                    true)) ...[
                          infoText(value: "${'served_by'.tr} ${user.name!}"),
                          pw.SizedBox(height: 5),
                        ],
                        if (SharedPr.invoiceSetting?.showOrderNumber != null &&
                            SharedPr.invoiceSetting!.showOrderNumber ==
                                true) ...[
                          infoText(
                              isbold: true,
                              isblack: true,
                              value:
                                  '${'invoice_nmuber'.tr} : ${printingController.saleOrderInvoice!.invoiceName ?? printingController.saleOrderInvoice!.id}')
                        ],
                        if (SharedPr.invoiceSetting?.showOrderType != null &&
                            SharedPr.invoiceSetting!.showOrderType == true &&
                            printingController.saleOrderInvoice!.moveType ==
                                MoveType.out_invoice.name &&
                            printingController
                                .saleOrderInvoice!.isTakeAwayOrder!) ...[
                          infoText(
                              value:
                                  '${'order_type'.tr} : (${printingController.saleOrderInvoice!.isTakeAwayOrder! ? "take_away".tr : "dine_in".tr})'),
                        ],
                      ],
                    )),
                pw.SizedBox(height: 3),
                pw.BarcodeWidget(
                  data: containsArabic(printingController
                          .saleOrderInvoice!.invoiceName
                          .toString())
                      ? '${printingController.saleOrderInvoice!.id}'
                      : '${printingController.saleOrderInvoice!.invoiceName ?? printingController.saleOrderInvoice!.id}',
                  barcode: pw.Barcode.code128(),
                  width: 100,
                  height: 20,
                  drawText: false,
                ),
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
                    value: formatter.format(
                        printingController.saleOrderInvoice!.remaining)),
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
                    value: formatter.format(printingController
                        .saleOrderInvoice!.totalPriceSubtotal)),
                pw.SizedBox(height: 10),
                rowFotter(
                    title: 'invoice_footer_total_tax'.tr,
                    value: formatter.format(
                        printingController.saleOrderInvoice!.totalTaxes)),
                if (SharedPr.invoiceSetting != null &&
                    SharedPr.invoiceSetting!.showNote == true) ...[
                  if (printingController.saleOrderInvoice!.note != null &&
                      printingController.saleOrderInvoice!.note != '') ...[
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        productText(
                            value:
                                "${'note'.tr} :  ${printingController.saleOrderInvoice!.note}",
                            isblack: true,
                            fontsize: 7),
                      ],
                    ),
                  ]
                ],
                pw.SizedBox(height: 10),
                pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.BarcodeWidget(
                              data: printingController
                                      .saleOrderInvoice!.zatcaQr ??
                                  "",
                              barcode: pw.Barcode.qrCode(),
                              width: 60,
                              height: 60),
                        ])),
                pw.SizedBox(height: 10),
                ...footerLines.map(
                  (line) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 5),
                      child: infoText(value: line)),
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? printingController.saleOrderInvoice!.orderDate.toString() : printingController.saleOrderInvoice!.orderDate.toString().substring(0, printingController.saleOrderInvoice!.orderDate!.indexOf('T'))}",
                      style: AppInvoiceStyle.headerStyle(
                          isbold: true, isblack: true, fontsize: 7),
                    ),
                    pw.Text(
                      " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? DateFormat("HH:mm:ss").format(DateTime.now()) : printingController.saleOrderInvoice!.orderDate.toString().substring(printingController.saleOrderInvoice!.orderDate!.indexOf('T') + 1)}",
                      style: AppInvoiceStyle.headerStyle(
                          isbold: true, isblack: true, fontsize: 7),
                    ),
                  ],
                ),
              ],
            )));
  }
  if (!isdownloadRoll &&
      items != null &&
      printingController.saleOrderInvoice!.moveType ==
          MoveType.out_invoice.name) {
    pdf.addPage(pw.Page(
        pageFormat: const PdfPageFormat(
          72 * PdfPageFormat.mm, // 80mm width
          double.infinity, // Example: fixed 200mm height
        ),
        textDirection:
            SharedPr.lang == 'en' ? pw.TextDirection.ltr : pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        build: (context) => pw.Column(
              children: [
                pw.Container(
                    width: 150,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        infoText(
                            value:
                                '${'order_number'.tr} : (${printingController.saleOrderInvoice!.invoiceId})'),
                        if (SharedPr.invoiceSetting?.showOrderType != null &&
                            SharedPr.invoiceSetting!.showOrderType == true) ...[
                          infoText(
                              value:
                                  '${'order_type'.tr} : (${printingController.saleOrderInvoice!.isTakeAwayOrder! ? "take_away".tr : "dine_in".tr})'),
                        ],
                        pw.SizedBox(height: 5),
                        if (user != null) ...[
                          infoText(value: "${'served_by'.tr} : ${user.name!}"),
                          pw.SizedBox(height: 5),
                        ],
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            infoText(
                              value:
                                  " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? printingController.saleOrderInvoice!.orderDate.toString() : printingController.saleOrderInvoice!.orderDate.toString().substring(0, printingController.saleOrderInvoice!.orderDate!.indexOf('T'))}",
                            ),
                            infoText(
                              value:
                                  " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? DateFormat("HH:mm:ss").format(DateTime.now()) : printingController.saleOrderInvoice!.orderDate.toString().substring(printingController.saleOrderInvoice!.orderDate!.indexOf('T') + 1)}",
                            ),
                          ],
                        ),
                      ],
                    )),
                pw.SizedBox(height: 20),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Expanded(
                          child: pw.Container(
                              alignment: pw.Alignment.center,
                              child: pw.Divider(
                                  borderStyle: pw.BorderStyle.dashed))),
                      pw.SizedBox(width: 5),
                      infoText(
                          value: '${items[0].productId!.soPosCategName}',
                          fontsize: 9),
                      pw.SizedBox(width: 5),
                      pw.Expanded(
                          child: pw.Container(
                              alignment: pw.Alignment.center,
                              child: pw.Divider(
                                  borderStyle: pw.BorderStyle.dashed))),
                    ]),
                pw.SizedBox(height: 10),
                pw.Row(children: [
                  pw.Container(
                      width: 15,
                      child:
                          productText(value: "#", isblack: true, isname: true)),
                  pw.Container(
                      width: 145,
                      child: productText(
                          value: 'item'.tr, isblack: true, isname: true)),
                  pw.Container(
                      width: 25,
                      child: productText(
                          value: 'qy'.tr,
                          isblack: true,
                          isname: true,
                          isAlignmentCenter: true)),
                ]),
                ...catogProductItem(
                    saleOrderLinesList: items,
                    formatter: formatter,
                    font: AppInvoiceStyle.fontMedium,
                    isShowNote: true),
                pw.SizedBox(height: 5),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Container(
                          width: 70,
                          alignment: pw.Alignment.center,
                          child:
                              pw.Divider(borderStyle: pw.BorderStyle.dashed)),
                    ]),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    infoText(value: "${'count_items'.tr} : ${items.length}"),
                    pw.SizedBox(width: 20),
                    infoText(
                        value:
                            "${'quantity'.tr} : ${items.fold(0, (previousValue, element) => previousValue + element.productUomQty!)}"),
                  ],
                ),
                pw.SizedBox(height: 8),
                if (printingController.saleOrderInvoice!.note != null &&
                    printingController.saleOrderInvoice!.note != '') ...[
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      productText(
                          value:
                              "${'note'.tr} :  ${printingController.saleOrderInvoice!.note}",
                          isblack: true,
                          fontsize: 7),
                    ],
                  ),
                ]
              ],
            )));
  }
  // return pdf;
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

bool containsArabic(String text) {
  final arabic = RegExp(r'[\u0600-\u06FF]');
  return arabic.hasMatch(text);
}
