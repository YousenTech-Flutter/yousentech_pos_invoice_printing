import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_desktop/core/config/app_invoice_colors.dart';
import 'package:pos_desktop/core/config/app_invoice_styles.dart';
import 'package:pos_desktop/features/basic_data_management/customer/data/customer.dart';
import 'package:pos_desktop/features/invoice_printing/domain/invoice_printing_viewmodel.dart';
import 'package:pos_desktop/features/invoice_printing/presentation/widgets/a4_data_row_cell.dart';
import 'package:pos_desktop/features/invoice_printing/presentation/widgets/a4_detail_item_company.dart';
import 'package:pos_desktop/features/invoice_printing/presentation/widgets/a4_table_row_data.dart';

import '../../../core/config/app_shared_pr.dart';
import '../../../core/utils/translations/ar.dart';
import '../../../core/utils/translations/en.dart';
import '../presentation/widgets/a4_fottor_item.dart';
import '../presentation/widgets/a4_header_item.dart';
import '../presentation/widgets/a4_header_table_item.dart';

Future<pw.Document> a4Print({required bool isSimple, Customer? customer, PdfPageFormat? format}) async {
  PrintingInvoiceController printingController =
      Get.put(PrintingInvoiceController());
  Customer? company = SharedPr.currentCompanyObject;
  final intl.NumberFormat formatter = intl.NumberFormat('#,##0.00', 'en_US');
  // String dateOrder = printingController.saleOrderInvoice!.orderDate
  //     .toString()
  //     .substring(0, 11)
  //     .toString();
  printingController.config();
  // String myString =
  //     "تاريخ الترحيل:$dateOrder\n وقت الترحيل:  $timeOrder\n إجمالي الفاتورة:  ${printingController.saleOrderInvoice!.totalPrice} \n اسم الشركة: ${company.name.toString()} \n الرقم الضريبي: ${company.vat.toString()}  ";
  // List<int> bytes = utf8.encode(myString);
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

  // await AppInvoiceStyle.loadFonts();
  List listHeder = [
    {'title': "total_price", 'expanded': 2},
    {'title': "vat_amount", 'expanded': 1},
    {'title': "amount", 'expanded': 1},
    {'title': "taxes", 'expanded': 1},
    {'title': "unit_price", 'expanded': 1},
    {'title': "quantity", 'expanded': 1},
    {'title': "description", 'expanded': 3},
  ];
  pdf.addPage(pw.MultiPage(
      textDirection: pw.TextDirection.rtl,
      pageFormat: format,
      header: (pw.Context context) => pw.Container(
            height: 70,
          ),
      // PdfPageFormat(
      //   80 * mm,
      //   double.maxFinite,
      //   marginAll: 5 * mm,
      // ),

      // orientation: pw.PageOrientation.landscape,
      // textDirection: lang == "ar" ? pw.TextDirection.rtl : pw.TextDirection.ltr,
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
                    '${en[printingController.title]!} / ${ar[printingController.title]!}', // Arabic text
                    style: AppInvoiceStyle.titlInvoiceStyle(),
                  ),
                  pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
                  // if (SharedPr.invoiceSetting!.showOrderNumber!) ...[
                  headerItem(
                    titel: 'invoice_nmuber',
                    value: printingController.saleOrderInvoice!.invoiceName ??
                        printingController.saleOrderInvoice!.id,
                  ),
                  // ],
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
                  // decoration: pw.BoxDecoration(
                  //   border: pw.Border.all(color: PdfColor.fromInt(0xfff8f9fa)),
                  // ),
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
              ...TableRowData(),
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
                    dataRowCell(
                        expanded: 2,
                        isTotal: true,
                        text: formatter.format(
                            printingController.saleOrderInvoice!.totalPrice)),
                    dataRowCell(
                        isTotal: true,
                        text: formatter.format(
                            printingController.saleOrderInvoice!.totalTaxes)),
                    dataRowCell(
                        isTotal: true,
                        text: formatter.format(printingController
                            .saleOrderInvoice!.totalPriceSubtotal)),
                    dataRowCell(
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
                  if (SharedPr.invoiceSetting!.showSubtotal!) ...[
                    fotterItem(
                      titel: 'sub_total',
                      value:
                          "${formatter.format(printingController.saleOrderInvoice!.totalPriceSubtotal)} SR",
                    ),
                  ],
                  fotterItem(
                      titel: 'vat',
                      value:
                          "${formatter.format(printingController.saleOrderInvoice!.totalTaxes)} SR",
                      isAll: true),
                  fotterItem(
                      titel: 'total_2',
                      value:
                          "${formatter.format(printingController.saleOrderInvoice!.totalPrice)} SR",
                      isAll: true),
                  pw.Divider(
                      thickness: 1, color: const PdfColor.fromInt(0xFFDAD5D5)),
                  fotterItem(
                      titel: 'paid_on',
                      value: DateTime.now().toString().substring(0, 10),
                      isAll: true),
                  ...printingController.saleOrderInvoice!.invoiceChosenPayment
                      .map((item) => fotterItem(
                          titel:
                              "${printingController.accountJournalList.firstWhere((e) => e.id == item.id).name!.enUS}",
                          value: "${formatter.format(item.amount)} SR",
                          isPyment: true,
                          isAll: true)),
                  pw.Divider(
                      thickness: 1, color: const PdfColor.fromInt(0xFFDAD5D5)),
                  fotterItem(
                    titel: 'amount_due',
                    value:
                        "${formatter.format(printingController.saleOrderInvoice!.remaining)} SR",
                  ),
                  fotterItem(
                    titel: 'change',
                    value:
                        "${formatter.format(printingController.saleOrderInvoice!.change)} SR",
                  ),
                ]))
          ]),
        
        
        ];
      }));
  // print("addPage2");
  return pdf;
}
