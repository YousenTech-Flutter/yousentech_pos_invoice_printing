// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pos_shared_preferences/models/account_journal/data/account_journal.dart';
import 'package:pos_shared_preferences/models/authentication_data/user.dart';
import 'package:pos_shared_preferences/models/customer_model.dart';
import 'package:pos_shared_preferences/models/sale_order_line.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import '../domain/invoice_printing_viewmodel.dart';
import '../presentation/widgets/roll_table_row_data.dart';

Widget rollAndroidPrint({isdownloadRoll = false, List<SaleOrderLine>? items}) {
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
    return Column(
      children: [
        SizedBox(
            width: 150.w,
            child: Column(
              children: [
                if (company?.image != null && company?.image != '') ...[
                  SizedBox(
                    height: 25.h,
                    width: 25.h,
                    child: companyImage,
                  ),
                  SizedBox(height: 5.h),
                ],
                infoText(
                    value: printingController.saleOrderInvoice!.refundNote !=
                                null &&
                            printingController.saleOrderInvoice!.refundNote !=
                                ''
                        ? "${"invoice".tr} ${'credit_note'.tr}"
                        : printingController.title.tr),
                if (company != null) ...[
                  SizedBox(height: 5.h),
                  infoText(value: company.name ?? ""),
                  if (company.phone != null && company.phone != '') ...[
                    SizedBox(height: 5.h),
                    infoText(value: "${'tell'.tr}: ${company.phone ?? ""}"),
                  ],
                  SizedBox(height: 5.h),
                  infoText(value: company.email ?? ""),
                ],
                ...headerLines.map(
                  (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: infoText(value: line)),
                ),
                const SizedBox(
                  width: double.infinity,
                  child: Divider(
                    color: Colors.black, // لون الخط
                    thickness: 2, // سماكة الخط // المسافة من اليمين
                  ),
                ),
                if (user != null) ...[
                  infoText(value: "${'served_by'.tr} ${user.name!}"),
                  SizedBox(height: 5.h),
                ],
                infoText(
                    isbold: true,
                    isblack: true,
                    value:
                        '${'invoice_nmuber'.tr} : ${printingController.saleOrderInvoice!.invoiceName ?? printingController.saleOrderInvoice!.id}'),
              ],
            )),
        SizedBox(height: 10.h),
        BarcodeWidget(
          data:
              '${printingController.saleOrderInvoice!.invoiceName ?? printingController.saleOrderInvoice!.id}',
          barcode: Barcode.code128(),
          width: 70.w,
          height: 20.h,
          drawText: false,
        ),
        SizedBox(height: 15.h),
        // ...productAndriodItem(
        //     saleOrderLinesList: printingController.saleOrderLinesList!,
        //     formatter: formatter,
        //     font: AppInvoiceStyle.fontMedium),
        // ...printingController.saleOrderLinesList!.map((item) {
        //   return SizedBox(
        //     width: double.infinity,
        //     child: Column(children: [
        //       productAndriodText(
        //           value: "${item.name}", isblack: true, isname: true),
        //       SizedBox(height: 5.h),
        //       SizedBox(
        //         width: double.infinity,
        //         child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               Row(children: [
        //                 productAndriodText(
        //                     value: "${item.productUomQty}", isblack: true),
        //                 productAndriodText(
        //                   value: " x ",
        //                 ),
        //                 productAndriodText(
        //                   value:
        //                       "${formatter.format(item.priceUnit)} ${"S.R".tr}",
        //                 ),
        //               ]),
        //               productAndriodText(
        //                   value:
        //                       "${formatter.format(item.totalPrice)} ${"S.R".tr}",
        //                   isblack: true),
        //             ]),
        //       ),
        //       SizedBox(height: 10.h),
        //     ]),
        //   );
        // }).toList(),
        Column(
          children: [
            ...printingController.saleOrderLinesList!.map((item) {
              return SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    productAndriodText(
                        value: "${item.name}", isblack: true, isname: true),
                    SizedBox(height: 5.h),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              productAndriodText(
                                  value: "${item.productUomQty}",
                                  isblack: true),
                              productAndriodText(value: " x "),
                              productAndriodText(
                                value:
                                    "${formatter.format(item.priceUnit)} ${"S.R".tr}",
                              ),
                            ]),
                            productAndriodText(
                                value:
                                    "${formatter.format(item.totalPrice)} ${"S.R".tr}",
                                isblack: true),
                          ]),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              );
            }).toList(),
          ],
        ),

        SizedBox(
          width: double.infinity,
          child: Column(children: [
            productAndriodText(
                value: "${printingController.saleOrderLinesList![0].name}",
                isblack: true,
                isname: true),
            SizedBox(height: 5.h),
            SizedBox(
              width: double.infinity,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      productAndriodText(
                          value:
                              "${printingController.saleOrderLinesList![0].productUomQty}",
                          isblack: true),
                      productAndriodText(
                        value: " x ",
                      ),
                      productAndriodText(
                        value:
                            "${formatter.format(printingController.saleOrderLinesList![0].priceUnit)} ${"S.R".tr}",
                      ),
                    ]),
                    productAndriodText(
                        value:
                            "${formatter.format(printingController.saleOrderLinesList![0].totalPrice)} ${"S.R".tr}",
                        isblack: true),
                  ]),
            ),
            SizedBox(height: 10.h),
          ]),
        ),
        SizedBox(
          width: double.infinity,
          child: Column(children: [
            productAndriodText(
                value: "${printingController.saleOrderLinesList![1].name}",
                isblack: true,
                isname: true),
            SizedBox(height: 5.h),
            SizedBox(
              width: double.infinity,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      productAndriodText(
                          value:
                              "${printingController.saleOrderLinesList![1].productUomQty}",
                          isblack: true),
                      productAndriodText(
                        value: " x ",
                      ),
                      productAndriodText(
                        value:
                            "${formatter.format(printingController.saleOrderLinesList![1].priceUnit)} ${"S.R".tr}",
                      ),
                    ]),
                    productAndriodText(
                        value:
                            "${formatter.format(printingController.saleOrderLinesList![1].totalPrice)} ${"S.R".tr}",
                        isblack: true),
                  ]),
            ),
            SizedBox(height: 10.h),
          ]),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 50.w,
              child: const Divider(
                color: Colors.black, // لون الخط
                thickness: 2, // سماكة الخط // المسافة من اليمين
              ),
            ),
          ],
        ),
        // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        //   infoText(
        //     value: "total".tr,
        //     isbold: true,
        //   ),
        //   infoText(
        //     value:
        //         "${formatter.format(printingController.saleOrderInvoice!.totalPrice)} ${"S.R".tr}",
        //     isbold: true,
        //   )
        // ]),
        SizedBox(height: 10.h),
        ...printingController.saleOrderInvoice!.invoiceChosenPayment
            .map((item) {
          AccountJournal accountJournal = printingController.accountJournalList
              .firstWhere((e) => e.id == item.id);
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 50.w,
              child: const Divider(
                color: Colors.black, // لون الخط
                thickness: 2, // سماكة الخط // المسافة من اليمين
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        rowFotter(
            title: "change".tr,
            value:
                formatter.format(printingController.saleOrderInvoice!.change)),
        SizedBox(height: 10.h),
        rowFotter(
            title: "remaining".tr,
            value: formatter
                .format(printingController.saleOrderInvoice!.remaining)),
        if (SharedPr.invoiceSetting!.showSubtotal!) ...[
          SizedBox(height: 10.h),
          rowFotter(
              title: 'invoice_footer_total_before_tax'.tr,
              value: formatter.format(printingController
                  .saleOrderInvoice!.totalPriceWitoutTaxAndDiscount)),
        ],
        SizedBox(height: 10.h),
        rowFotter(
            title: 'invoice_footer_total_discount'.tr,
            value: formatter
                .format(printingController.saleOrderInvoice!.totalDiscount)),
        SizedBox(height: 10.h),
        rowFotter(
            title: 'invoice_footer_total_exclude_tax'.tr,
            value: formatter.format(
                printingController.saleOrderInvoice!.totalPriceSubtotal)),
        SizedBox(height: 10.h),
        rowFotter(
            title: 'invoice_footer_total_tax'.tr,
            value: formatter
                .format(printingController.saleOrderInvoice!.totalTaxes)),
        SizedBox(height: 10.h),
        rowFotter(
            title: "${'total'.tr} ${'with_tax'.tr}",
            value: formatter
                .format(printingController.saleOrderInvoice!.totalPrice)),
        SizedBox(height: 10.h),
        Container(
            padding: EdgeInsets.all(10.r),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              BarcodeWidget(
                  data: printingController.saleOrderInvoice!.zatcaQr ?? "",
                  barcode: Barcode.qrCode(),
                  width: 100.w,
                  height: 100.h),
            ])),
        SizedBox(height: 10.h),
        ...footerLines.map(
          (line) => Padding(
              padding: EdgeInsets.only(bottom: 5.r),
              child: infoText(value: line)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? printingController.saleOrderInvoice!.orderDate.toString() : printingController.saleOrderInvoice!.orderDate.toString().substring(0, printingController.saleOrderInvoice!.orderDate!.indexOf('T'))}",
              style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontSize: 4.sp,
                  color: AppColor.black,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? intl.DateFormat("HH:mm:ss").format(DateTime.now()) : printingController.saleOrderInvoice!.orderDate.toString().substring(printingController.saleOrderInvoice!.orderDate!.indexOf('T') + 1)}",
              style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontSize: 4.sp,
                  color: AppColor.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // SizedBox(height: 20.h),
      ],
    );
  }
  if (!isdownloadRoll && items != null) {
    return Column(
      children: [
        SizedBox(
            width: 150.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoText(
                    value:
                        '${'order_number'.tr} : (${printingController.saleOrderInvoice!.invoiceId})'),
                SizedBox(height: 5.h),
                if (user != null) ...[
                  infoText(value: "${'served_by'.tr} : ${user.name!}"),
                  SizedBox(height: 5.h),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    infoText(
                      value:
                          " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? printingController.saleOrderInvoice!.orderDate.toString() : printingController.saleOrderInvoice!.orderDate.toString().substring(0, printingController.saleOrderInvoice!.orderDate!.indexOf('T'))}",
                    ),
                    infoText(
                      value:
                          " ${!printingController.saleOrderInvoice!.orderDate.toString().contains('T') ? intl.DateFormat("HH:mm:ss").format(DateTime.now()) : printingController.saleOrderInvoice!.orderDate.toString().substring(printingController.saleOrderInvoice!.orderDate!.indexOf('T') + 1)}",
                    ),
                  ],
                ),
              ],
            )),
        SizedBox(height: 20.h),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: SizedBox(
              width: 50.w,
              child: const Divider(
                color: Colors.black, // لون الخط
                thickness: 2, // سماكة الخط // المسافة من اليمين
              ),
            ),
          ),
          SizedBox(width: 5.w),
          infoText(
              value: '${items[0].productId!.soPosCategName}', fontsize: 4.sp),
          SizedBox(width: 5.w),
          Expanded(
            child: SizedBox(
              width: 50.w,
              child: const Divider(
                color: Colors.black, // لون الخط
                thickness: 2, // سماكة الخط // المسافة من اليمين
              ),
            ),
          ),
        ]),
        SizedBox(height: 10.h),
        Row(children: [
          SizedBox(
              // width: 15.w,
              child:
                  productAndriodText(value: "#", isblack: true, isname: true)),
          SizedBox(width: 10.h),
          SizedBox(
              // width: 145.w,
              child: productAndriodText(
                  value: 'item'.tr, isblack: true, isname: true)),
          const Spacer(),
          SizedBox(
              // width: 25.w,
              child: productAndriodText(
                  value: 'qy'.tr,
                  isblack: true,
                  isname: true,
                  isAlignmentCenter: true)),
        ]),
        SizedBox(height: 10.h),
        ...catogProductAndriodItem(
            saleOrderLinesList: items,
            formatter: formatter,
            font: AppInvoiceStyle.fontMedium,
            isShowNote: true),
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 50.w,
              child: const Divider(
                color: Colors.black, // لون الخط
                thickness: 2, // سماكة الخط // المسافة من اليمين
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            infoText(value: "${'count_items'.tr} : ${items.length}"),
            SizedBox(width: 20.w),
            infoText(
                value:
                    "${'quantity'.tr} : ${items.fold(0, (previousValue, element) => previousValue + element.productUomQty!)}"),
          ],
        ),
        SizedBox(height: 8.h),
        if (printingController.saleOrderInvoice!.note != null &&
            printingController.saleOrderInvoice!.note != '') ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              productAndriodText(
                  value:
                      "${'note'.tr} :  ${printingController.saleOrderInvoice!.note}",
                  isblack: true,
                  fontsize: 4.sp),
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
    double? fontsize}) {
  return Align(
      alignment: Alignment.center,
      child: Text(
        textDirection: TextDirection.rtl,
        value, // Arabic text
        style: TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: fontsize ?? 4.sp,
            // color: (isblack ? AppColor.black : AppColor.gray),
            color: AppColor.black,
            fontWeight: FontWeight.bold),
      ));
}

Row rowFotter({
  required String title,
  required String value,
}) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
