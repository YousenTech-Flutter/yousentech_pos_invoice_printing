import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_shared_preferences/models/customer_model.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_invoice_colors.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:shared_widgets/utils/translations/ar.dart';
import 'package:shared_widgets/utils/translations/en.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/domain/invoice_printing_viewmodel.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/presentation/widgets/a4_data_row_cell.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/presentation/widgets/a4_detail_item_company.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/presentation/widgets/a4_fottor_item.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/presentation/widgets/a4_header_item.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/presentation/widgets/a4_header_table_item.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/presentation/widgets/a4_table_row_data.dart';

Future<pw.Document> a4Print({required bool isSimple, Customer? customer, PdfPageFormat? format}) async {
  PrintingInvoiceController printingController =
      Get.put(PrintingInvoiceController());
  Customer? company = SharedPr.currentCompanyObject;
  final intl.NumberFormat formatter = intl.NumberFormat('#,##0.00', 'en_US');
  printingController.config();
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  // List listHeder = [
  //   {'title': "total_price", 'expanded': 2},
  //   {'title': "vat_amount", 'expanded': 1},
  //   {'title': "amount", 'expanded': 1},
  //   {'title': "taxes", 'expanded': 1},
  //   {'title': "unit_price", 'expanded': 1},
  //   {'title': "quantity", 'expanded': 1},
  //   {'title': "description", 'expanded': 3},
  // ];
    // basic_total  quantityMultipliedByUnitPriceForSubtotalPrice
  //discount discountAsAmount
  //tax_excl subtotalPrice
  //tax_total totalTax
  //'${'total'.tr} ${'with_tax'.tr}' totalPrice
  List listHeder = [
    {'title': "total_price", 'expanded': 2},
    // {'title': "vat_amount", 'expanded': 1},

    {'title': "taxes", 'expanded': 1},

    {'title': "amount", 'expanded': 1},
    {'title': "unit_price", 'expanded': 1},
    {'title': "quantity", 'expanded': 1},
    {'title': "description", 'expanded': 3},
  ];

  if (printingController.saleOrderInvoice!.totalDiscount != 0) {
    // listHeder.insert(
    //   2,
    //   {'title': "tax_excl", 'expanded': 1},
    // );
    listHeder.insert(
      3,
      {'title': "discount", 'expanded': 1},
    );
    listHeder.insert(
      4,
      {'title': "basic_total", 'expanded': 1},
    );
  }
  pdf.addPage(pw.MultiPage(
      textDirection: pw.TextDirection.rtl,
      pageFormat: format,
      header: (pw.Context context) => pw.Container(
            height: 70,
          ),
      margin: const pw.EdgeInsets.only(
        top: 45,
        bottom: 32,
        right: 30,
        left: 30,
      ),
      build: (context) {
        return [
          pw.Row(children: [
            pw.Expanded(
              flex: 1,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    '${en[isSimple ? printingController.title : 'tax_invoice']!} / ${ar[isSimple ? printingController.title : 'tax_invoice']!}', // Arabic text // Arabic text
                    style: AppInvoiceStyle.titlInvoiceStyle(),
                  ),
                  pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
                  headerItem(
                    titel: 'invoice_nmuber',
                    value: printingController.saleOrderInvoice!.invoiceName ??
                        printingController.saleOrderInvoice!.id,
                  ),
                  headerItem(
                    titel: 'invoice_date',
                    value:
                        "${printingController.dayOrder} ${printingController.monthOrder} ${printingController.yearOrder} ${printingController.timeOrder}",
                    isTitalBlck: false,
                  ),
                  pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
                  headerItem(
                    titel: 'supply_date',
                    value:
                        "${printingController.dayOrder} ${printingController.monthOrder} ${printingController.yearOrder}",
                  ),
                ],
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.BarcodeWidget(
                            data:
                                printingController.saleOrderInvoice!.zatcaQr ??
                                    "",
                            barcode: pw.Barcode.qrCode(),
                            width: 100,
                            height: 100),
                      ])),
            )
          ]),
          isSimple
              ? pw.Column(children: [
                  pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
                  headerItem(
                      titel: 'customer_name',
                      value: "${customer?.name ?? ar['customer_cash']}",
                      isValueBlck: true,
                      isValueBold: true),
                  pw.Divider(thickness: 0.0000001),
                ])
              : pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                        child: companyDetailItem(
                            customer!, '${ar['buyer']} / ${en['buyer']}')),
                    if (company != null)
                      pw.Expanded(
                          child: companyDetailItem(
                              company, '${ar['seller']} / ${en['seller']}')),
                  ],
                ),
          pw.Table(
            border: pw.TableBorder.all(
              color: AppInvoceColor.grayTableBorder,
            ),
            children: [
              pw.TableRow(
                  children: [
                    ...List.generate(
                      listHeder.length,
                      (index) {
                        return headerTableItem(
                          text: listHeder[index]['title'],
                          expanded: listHeder[index]['expanded'],
                        );
                      },
                    ),
                  ]),
              ...a4TableRowData(),
            ],
          ),
          pw.Table(
            border: pw.TableBorder.all(
              color: const PdfColor.fromInt(0xFFE6E6E6),
            ),
            children: [
              pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color:
                          (printingController.saleOrderLinesList!.length + 1) %
                                      2 ==
                                  0
                              ? PdfColors.white
                              : const PdfColor.fromInt(0xfff8f5f7)),
                  children: [
                    a4dataRowCell(
                        expanded: 2,
                        isTotal: true,
                        text: formatter.format(
                            printingController.saleOrderInvoice!.totalPrice)),
                    a4dataRowCell(
                        isTotal: true,
                        text: formatter.format(
                            printingController.saleOrderInvoice!.totalTaxes)),
                    a4dataRowCell(
                        isTotal: true,
                        text: formatter.format(printingController.saleOrderInvoice!.totalPriceSubtotal)),
                    if (printingController.saleOrderInvoice!.totalDiscount !=0) ...[
                      a4dataRowCell(
                          isTotal: true,
                          text: formatter.format(printingController
                              .saleOrderInvoice!.totalDiscount)),
                      a4dataRowCell(
                          isTotal: true,
                          text: formatter.format(printingController.saleOrderInvoice!.totalPriceWitoutTaxAndDiscount)),
                    ],
                    a4dataRowCell(
                        expanded: 6,
                        isTotal: true,
                        text:
                            "${ar['quantity']} ${formatter.format(printingController.saleOrderInvoice!.totalQuantity)}"),
                  ]),
            ],
          ),
          pw.Row(children: [
            pw.Expanded(flex: 3, child: pw.Container()),
            pw.Expanded(
                flex: 2,
                child: pw.Column(children: [
                  pw.Divider(
                      thickness: 1, color: const PdfColor.fromInt(0xFFDAD5D5)),
                  if (printingController.saleOrderInvoice!.totalDiscount !=
                      0) ...[
                    a4fotterItem(
                      titel: 'basic_total',
                      value:
                          "${formatter.format(printingController.saleOrderInvoice!.totalPriceWitoutTaxAndDiscount)} SR",
                    ),
                    a4fotterItem(
                      titel: 'discount',
                      value:
                          "${formatter.format(printingController.saleOrderInvoice!.totalDiscount)} SR",
                    ),
                  ],
                  
                  if (SharedPr.invoiceSetting!.showSubtotal!) ...[
                    a4fotterItem(
                      titel: 'sub_total',
                      value:
                          "${formatter.format(printingController.saleOrderInvoice!.totalPriceSubtotal)} SR",
                    ),
                  ],
                  a4fotterItem(
                      titel: 'vat',
                      value:
                          "${formatter.format(printingController.saleOrderInvoice!.totalTaxes)} SR",
                      isAll: true),
                  a4fotterItem(
                      titel: 'total_2',
                      value:
                          "${formatter.format(printingController.saleOrderInvoice!.totalPrice)} SR",
                      isAll: true),
                  pw.Divider(
                      thickness: 1, color: const PdfColor.fromInt(0xFFDAD5D5)),
                  a4fotterItem(
                      titel: 'paid_on',
                      value: DateTime.now().toString().substring(0, 10),
                      isAll: true),
                  ...printingController.saleOrderInvoice!.invoiceChosenPayment
                      .map((item) => a4fotterItem(
                          titel:
                              "${printingController.accountJournalList.firstWhere((e) => e.id == item.id).name!.enUS}",
                          value: "${formatter.format(item.amount)} SR",
                          isPyment: true,
                          isAll: true)),
                  pw.Divider(
                      thickness: 1, color: const PdfColor.fromInt(0xFFDAD5D5)),
                  a4fotterItem(
                    titel: 'amount_due',
                    value:
                        "${formatter.format(printingController.saleOrderInvoice!.remaining)} SR",
                  ),
                  a4fotterItem(
                    titel: 'change',
                    value:
                        "${formatter.format(printingController.saleOrderInvoice!.change)} SR",
                  ),
                ]))
          ]),
        ];
      }));
  return pdf;
}
