// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pos_shared_preferences/helper/app_enum.dart';
import 'package:pos_shared_preferences/models/account_journal/data/account_journal.dart';
import 'package:pos_shared_preferences/models/authentication_data/user.dart';
import 'package:pos_shared_preferences/models/customer_model.dart';
import 'package:pos_shared_preferences/models/sale_order_line.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:shared_widgets/utils/responsive_helpers/size_helper_extenstions.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/domain/invoice_printing_viewmodel.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/roll_print_helper2.dart';
import 'package:barcode_widget/barcode_widget.dart';

Widget rollAndroidPrint(
    {isdownloadRoll = false,
    List<SaleOrderLine>? items,
    required BuildContext context}) {
  PrintingInvoiceController printingController =
      Get.put(PrintingInvoiceController());
  Customer? company = SharedPr.currentCompanyObject;
  User? user = SharedPr.chosenUserObj;
  final intl.NumberFormat formatter = intl.NumberFormat('#,##0.00', 'en_US');
  late var companyImage;
  if (company?.image != null && company?.image != '') {
    companyImage = Image.memory(base64Decode(company!.image!));
  }
  bool isFind =
      printingController.saleOrderInvoice!.orderDate.toString().contains('T');
  String myString =
      "تاريخ الترحيل:${isFind ? printingController.saleOrderInvoice!.orderDate.toString().substring(0, 11).toString() : printingController.saleOrderInvoice!.orderDate.toString()
      // snapshot.data[0]['date_order'].toString().substring(0, 11).toString()
      }\n وقت الترحيل:  ${isFind ? printingController.saleOrderInvoice!.orderDate.toString().substring(11, 19).toString() : intl.DateFormat("HH:mm:ss").format(DateTime.now())
      // snapshot.data[0]['date_order'].toString().substring(11, 19).toString()
      }\n إجمالي الفاتورة:  ${printingController.saleOrderInvoice!.totalPrice
      // snapshot.data[0]["total_invoice"].toString()
      } \n اسم الشركة: ${company?.name} \n الرقم الضريبي: ${company?.vat.toString()}  ";
  List<int> bytes = utf8.encode(myString);
  List listHeder = ["item".tr, "quantity".tr, "price".tr, "total".tr];
  List<String> headerLines = SharedPr.currentPosObject!.invoiceHeaderLines == ''
      ? []
      : SharedPr.currentPosObject!.invoiceHeaderLines!.trim().split('\n');
  List<String> footerLines = SharedPr.currentPosObject!.invoiceFooterLines == ''
      ? []
      : SharedPr.currentPosObject!.invoiceFooterLines!.trim().split('\n');
  if (isdownloadRoll) {
    List<Widget> children = [];
    for (var item in printingController.saleOrderLinesList!) {
      children.add(
        productAndriodItem(
            context: context,
            item: item,
            formatter: formatter,
            font: AppInvoiceStyle.fontMedium),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.setHeight(10),
      children: [
        SizedBox(
            // width: context.setWidth(150),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.setHeight(5),
          children: [
            if (company?.image != null && company?.image != '') ...[
              SizedBox(
                height: context.setMinSize(130),
                width: context.setMinSize(130),
                child: companyImage,
              ),
            ],
            infoText(
                context: context,
                value: printingController.saleOrderInvoice!.refundNote !=
                            null &&
                        printingController.saleOrderInvoice!.refundNote != ''
                    ? "${"invoice".tr} ${'credit_note'.tr}"
                    : printingController.title.tr),
            if (company != null) ...[
              infoText(context: context, value: company.name ?? ""),
              if (company.phone != null && company.phone != '') ...[
                infoText(
                    context: context,
                    value: "${'tell'.tr}: ${company.phone ?? ""}"),
              ],
              infoText(context: context, value: company.email ?? ""),
            ],
            ...headerLines.map(
              (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: infoText(context: context, value: line)),
            ),
            const SizedBox(
              width: double.infinity,
              child: Divider(
                color: Colors.black, // لون الخط
                thickness: 1, // سماكة الخط // المسافة من اليمين
              ),
            ),
            if ((user != null &&
                (SharedPr.invoiceSetting?.showCreatorUsername != null &&
                    SharedPr.invoiceSetting!.showCreatorUsername == true))) ...[
              infoText(
                  context: context, value: "${'served_by'.tr} ${user.name!}"),
            ],
            if (SharedPr.invoiceSetting?.showOrderNumber != null &&
                SharedPr.invoiceSetting!.showOrderNumber == true) ...[
              infoText(
                  context: context,
                  isbold: true,
                  isblack: true,
                  value:
                      '${'invoice_nmuber'.tr} : ${printingController.saleOrderInvoice!.invoiceName ?? printingController.saleOrderInvoice!.id}')
            ],
            if (SharedPr.invoiceSetting?.showOrderType != null &&
                SharedPr.invoiceSetting!.showOrderType == true &&
                printingController.saleOrderInvoice!.moveType ==
                    MoveType.out_invoice.name &&
                printingController.saleOrderInvoice!.isTakeAwayOrder!) ...[
              SizedBox(height: context.setHeight(10)),
              infoText(
                  context: context,
                  value:
                      '${'order_type'.tr} : (${printingController.saleOrderInvoice!.isTakeAwayOrder! ? "take_away".tr : "dine_in".tr})'),
            ],
          ],
        )),
        BarcodeWidget(
          data: containsArabic(
                  printingController.saleOrderInvoice!.invoiceName.toString())
              ? '${printingController.saleOrderInvoice!.id}'
              : '${printingController.saleOrderInvoice!.invoiceName ?? printingController.saleOrderInvoice!.id}',
          barcode: Barcode.code128(),
          width: context.setWidth(200),
          height: context.setHeight(20),
          drawText: false,
        ),
        SizedBox(height: context.setHeight(15)),
        ...children,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: context.setWidth(50),
              child: const Divider(
                color: Colors.black, // لون الخط
                thickness: 1, // سماكة الخط // المسافة من اليمين
              ),
            ),
          ],
        ),
        ...printingController.saleOrderInvoice!.invoiceChosenPayment
            .map((item) {
          AccountJournal accountJournal = printingController.accountJournalList
              .firstWhere((e) => e.id == item.id);
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                infoText(
                  context: context,
                  value:
                      '${SharedPr.lang == 'en' ? accountJournal.name!.enUS : accountJournal.name!.ar001 ?? accountJournal.name!.enUS}',
                  isbold: true,
                ),
                infoText(
                  context: context,
                  value: '${formatter.format(item.amount)} ${"S.R".tr}',
                  isbold: true,
                )
              ]);
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: context.setWidth(50),
              child: const Divider(
                color: Colors.black, // لون الخط
                thickness: 1, // سماكة الخط // المسافة من اليمين
              ),
            ),
          ],
        ),
        rowFotter(
            context: context,
            title: "change".tr,
            value:
                formatter.format(printingController.saleOrderInvoice!.change)),
        rowFotter(
            context: context,
            title: "remaining".tr,
            value: formatter
                .format(printingController.saleOrderInvoice!.remaining)),
        if (SharedPr.invoiceSetting!.showSubtotal!) ...[
          rowFotter(
              context: context,
              title: 'invoice_footer_total_before_tax'.tr,
              value: formatter.format(printingController
                  .saleOrderInvoice!.totalPriceWitoutTaxAndDiscount)),
        ],
        rowFotter(
            context: context,
            title: 'invoice_footer_total_discount'.tr,
            value: formatter
                .format(printingController.saleOrderInvoice!.totalDiscount)),
        rowFotter(
            context: context,
            title: 'invoice_footer_total_exclude_tax'.tr,
            value: formatter.format(
                printingController.saleOrderInvoice!.totalPriceSubtotal)),
        rowFotter(
            context: context,
            title: 'invoice_footer_total_tax'.tr,
            value: formatter
                .format(printingController.saleOrderInvoice!.totalTaxes)),
        rowFotter(
            context: context,
            title: "${'total'.tr} ${'with_tax'.tr}",
            value: formatter
                .format(printingController.saleOrderInvoice!.totalPrice)),
        if (SharedPr.invoiceSetting != null &&
            SharedPr.invoiceSetting!.showNote == true) ...[
          if (printingController.saleOrderInvoice!.note != null &&
              printingController.saleOrderInvoice!.note != '') ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                productAndriodText(
                    context: context,
                    value:
                        "${'note'.tr} :  ${printingController.saleOrderInvoice!.note}",
                    isblack: true,
                    fontsize: context.setSp(20)),
              ],
            ),
          ],
        ],
        Container(
            padding: EdgeInsets.all(context.setMinSize(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              BarcodeWidget(
                  data: printingController.saleOrderInvoice!.zatcaQr ?? "",
                  barcode: Barcode.qrCode(),
                  width: context.setMinSize(100),
                  height: context.setMinSize(100)),
            ])),
        ...footerLines.map(
          (line) => Padding(
              padding: EdgeInsets.only(bottom: context.setMinSize(5)),
              child: infoText(context: context, value: line)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? printingController.saleOrderInvoice!.orderDate.toString() : printingController.saleOrderInvoice!.orderDate.toString().substring(0, printingController.saleOrderInvoice!.orderDate!.indexOf('T'))}",
              style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontSize: context.setSp(20),
                  color: AppColor.black,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? intl.DateFormat("HH:mm:ss").format(DateTime.now()) : printingController.saleOrderInvoice!.orderDate.toString().substring(printingController.saleOrderInvoice!.orderDate!.indexOf('T') + 1)}",
              style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontSize: context.setSp(20),
                  color: AppColor.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // SizedBox(height: 20.h),
      ],
    );
  }
  if (!isdownloadRoll &&
      items != null &&
      printingController.saleOrderInvoice!.moveType ==
          MoveType.out_invoice.name) {
    return Column(
      spacing: context.setHeight(10),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: context.setWidth(150),
            child: Column(
              spacing: context.setHeight(5),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoText(
                    context: context,
                    value:
                        '${'order_number'.tr} : (${printingController.saleOrderInvoice!.invoiceId})'),
                if (SharedPr.invoiceSetting?.showOrderType != null &&
                    SharedPr.invoiceSetting!.showOrderType == true) ...[
                  infoText(
                      context: context,
                      value:
                          '${'order_type'.tr} : (${printingController.saleOrderInvoice!.isTakeAwayOrder! ? "take_away".tr : "dine_in".tr})'),
                ],
                if (user != null) ...[
                  infoText(
                      context: context,
                      value: "${'served_by'.tr} : ${user.name!}"),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    infoText(
                      context: context,
                      value:
                          " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? printingController.saleOrderInvoice!.orderDate.toString() : printingController.saleOrderInvoice!.orderDate.toString().substring(0, printingController.saleOrderInvoice!.orderDate!.indexOf('T'))}",
                    ),
                    infoText(
                      context: context,
                      value:
                          " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? intl.DateFormat("HH:mm:ss").format(DateTime.now()) : printingController.saleOrderInvoice!.orderDate.toString().substring(printingController.saleOrderInvoice!.orderDate!.indexOf('T') + 1)}",
                    ),
                  ],
                ),
              ],
            )),
        SizedBox(height: context.setHeight(10)),
        Row(
            spacing: context.setWidth(5),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  width: context.setWidth(50),
                  child: const Divider(
                    color: Colors.black, // لون الخط
                    thickness: 1, // سماكة الخط // المسافة من اليمين
                  ),
                ),
              ),
              infoText(
                  context: context,
                  value: '${items[0].productId!.soPosCategName}',
                  fontsize: context.setSp(20)),
              Expanded(
                child: SizedBox(
                  width: context.setWidth(50),
                  child: const Divider(
                    color: Colors.black, // لون الخط
                    thickness: 1, // سماكة الخط // المسافة من اليمين
                  ),
                ),
              ),
            ]),
        Row(children: [
          SizedBox(
              // width: 15.w,
              child: productAndriodText(
                  context: context, value: "#", isblack: true, isname: true)),
          SizedBox(width: context.setWidth(10)),
          SizedBox(
              child: productAndriodText(
                  context: context,
                  value: 'item'.tr,
                  isblack: true,
                  isname: true)),
          const Spacer(),
          SizedBox(
              child: productAndriodText(
                  context: context,
                  value: 'qy'.tr,
                  isblack: true,
                  isname: true,
                  isAlignmentCenter: true)),
        ]),
        ...catogProductAndriodItem(
            context: context,
            saleOrderLinesList: items,
            formatter: formatter,
            font: AppInvoiceStyle.fontMedium,
            isShowNote: true),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: context.setWidth(50),
              child: const Divider(
                color: Colors.black, // لون الخط
                thickness: 1, // سماكة الخط // المسافة من اليمين
              ),
            ),
          ],
        ),
        Row(
          spacing: context.setWidth(20),
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            infoText(
                context: context,
                value: "${'count_items'.tr} : ${items.length}"),
            infoText(
                context: context,
                value:
                    "${'quantity'.tr} : ${items.fold(0.0, (previousValue, element) => previousValue + element.productUomQty!)}"),
          ],
        ),
        if (printingController.saleOrderInvoice!.note != null &&
            printingController.saleOrderInvoice!.note != '') ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              productAndriodText(
                  context: context,
                  value:
                      "${'note'.tr} :  ${printingController.saleOrderInvoice!.note}",
                  isblack: true,
                  fontsize: context.setSp(20)),
            ],
          ),
        ]
      ],
    );
  }

  return Container();
}

Align infoText(
    {required String value,
    bool isbold = true,
    bool isblack = true,
    required BuildContext context,
    double? fontsize}) {
  return Align(
      alignment: Alignment.center,
      child: Text(
        textDirection: TextDirection.rtl,
        value, // Arabic text
        style: TextStyle(
            fontSize: fontsize ?? context.setSp(20),
            color: AppColor.black,
            fontWeight: isbold ? FontWeight.bold : FontWeight.normal),
      ));
}

Row rowFotter(
    {required String title,
    required String value,
    required BuildContext context}) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    infoText(value: title, isbold: true, context: context),
    infoText(value: "$value ${"S.R".tr}", isbold: true, context: context)
  ]);
}

Column productAndriodItem(
    {required SaleOrderLine item,
    required formatter,
    bool isShowNote = false,
    required BuildContext context,
    required font}) {
  return Column(
      spacing: context.setHeight(5),
      mainAxisSize: MainAxisSize.min,
      children: [
        productAndriodText(
            context: context,
            value: "${item.name}",
            isblack: true,
            isname: true),
        if (item.categoryNotes != null && item.categoryNotes!.isNotEmpty) ...[
          if (SharedPr.invoiceSetting != null && SharedPr.invoiceSetting!.showNote == true) ...[
            Row(children: [
                ...List.generate(item.categoryNotes!.length, (index) {
                  return productAndriodText(
                      context: context,
                      value: " ${item.categoryNotes![index].note} ",
                      isblack: false,
                      isname: true,
                      fontsize: context.setSp(20),
                      color: AppColor.gray);
                })
              
            ])
          ]
        ],
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 8),
            child: Row(children: [
              productAndriodText(
                  context: context,
                  value: "${item.productUomQty}",
                  isblack: true),
              productAndriodText(
                context: context,
                value: " x ",
              ),
              if (!isShowNote) ...[
                productAndriodText(
                  context: context,
                  value: "${formatter.format(item.priceUnit)} ${"S.R".tr}",
                ),
              ],
            ]),
          ),
          if (!isShowNote) ...[
            productAndriodText(
                context: context,
                value: "${formatter.format(item.totalPrice)} ${"S.R".tr}",
                isblack: true),
          ]
        ]),
        SizedBox(height: context.setHeight(10)),
      ]);
}

Align productAndriodText(
    {required String value,
    bool isbold = true,
    bool isname = false,
    bool isblack = true,
    bool isAlignmentCenter = false,
    double? fontsize,
    Color? color,
    required BuildContext context}) {
  return Align(
      alignment: !isAlignmentCenter
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.center,
      child: Text(
        textDirection: isname ? TextDirection.rtl : null,
        value,
        style: TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: fontsize ?? context.setSp(20),
            color: AppColor.black,
            fontWeight: FontWeight.bold),
      ));
}

List<Column> catogProductAndriodItem(
    {required List<SaleOrderLine> saleOrderLinesList,
    required formatter,
    bool isShowNote = false,
    required BuildContext context,
    required font}) {
  return List.generate(saleOrderLinesList.length, (index) {
    SaleOrderLine item = saleOrderLinesList[index];
    return Column(children: [
      SizedBox(height: context.setHeight(10)),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            child: productAndriodText(
                context: context,
                value: "${index + 1}.",
                isblack: true,
                isname: true)),
        SizedBox(
          child: productAndriodText(
            context: context,
            value: buildProductNameWithNotes(item),
            isblack: true,
            isname: true,
          ),
        ),
        const Spacer(),
        SizedBox(
            child: productAndriodText(
                context: context,
                value: "${item.productUomQty}",
                isblack: true,
                isAlignmentCenter: true)),
      ]),
    ]);
  });
}

String buildProductNameWithNotes(SaleOrderLine item) {
  final notes = <String>[];

  // if (item.note != null && item.note!.trim().isNotEmpty) {
  //   notes.add(item.note!.trim());
  // }

  if (item.categoryNotes != null && item.categoryNotes!.isNotEmpty) {
    notes.addAll(item.categoryNotes!
        .map((e) => e.note?.trim())
        .where((note) => note != null && note.isNotEmpty)
        .cast<String>());
  }
  if (notes.isEmpty) {
    return item.name ?? '';
  }

  return "${item.name} (${notes.join(', ')})";
}
