// ignore_for_file: empty_catches, unused_local_variable

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
// import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_shared_preferences/models/account_journal/data/account_journal.dart';
import 'package:pos_shared_preferences/models/customer_model.dart';
import 'package:pos_shared_preferences/models/pos_setting_info_model.dart';
import 'package:pos_shared_preferences/models/printing/data/powershell_shared_printer.dart';
import 'package:pos_shared_preferences/models/printing_setting.dart';
import 'package:pos_shared_preferences/models/sale_order.dart';
import 'package:pos_shared_preferences/models/sale_order_line.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:yousentech_pos_invoice/invoices/domain/invoice_operations/invoice_operations_viewmodel.dart';
import 'package:yousentech_pos_invoice/invoices/domain/invoice_viewmodel.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/config/app_enums.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/printer_helper.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/roll_print_android_helper.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/roll_print_helper2.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/show_pdf_invoic.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/screenshot_widget.dart';
import 'package:yousentech_pos_local_db/yousentech_pos_local_db.dart';
import 'package:yousentech_pos_messaging/messaging/domain/messaging_viewmodel.dart';
import 'package:yousentech_pos_messaging/messaging/utils/file_convert_helper.dart';
import 'package:yousentech_pos_payment/payment/domain/payment_viewmodel.dart';
import 'package:yousentech_pos_payment_summary/payment_summary/presentation/payment_sammry_screen.dart';
import 'package:yousentech_pos_printing/printing/domain/app_connected_printers/connected_printer_viewmodel.dart';
import 'package:yousentech_pos_printing/printing/utils/subnet_determination.dart';
import 'package:ysn_pos_android_printer/android_printer/printer.dart';
import 'package:ysn_pos_android_printer/test.dart';

import '../utils/a4_print_helper.dart';
// import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PrintingInvoiceController extends GetxController {
  SaleOrderInvoice? saleOrderInvoice;
  List<SaleOrderLine>? saleOrderLinesList;
  List<Customer>? customersList;
  FocusNode validateButtonFocus = FocusNode();
  List<AccountJournal> accountJournalList = [];
  Customer? customer;
  bool isDefault = true; // Default option
  bool checkbox = false;
  bool checkboxDisable = false;
  bool isDialogOpen = false;
  bool isCash = false;
  String dayOrder = '';
  String monthOrder = '';
  String yearOrder = '';
  String timeOrder = '';
  pw.Document? pdf;
  String title = '';
  pw.Font? fontMedium;
  pw.Font? fontBold;
  ScreenshotController screenshotController = ScreenshotController();
  @override
  Future<void> onInit() async {
    await loadFonts();
    super.onInit();
  }

  Future<void> loadFonts() async {
    try {
      final ttfMedium = await rootBundle.load('assets/fonts/ARIAL.TTF');
      final ttfBold = await rootBundle.load('assets/fonts/ARIALBD.TTF');
      fontMedium = pw.Font.ttf(ttfMedium.buffer.asByteData());
      fontBold = pw.Font.ttf(ttfBold.buffer.asByteData());
    } catch (e) {}
  }

  // ================================================================ [ GET ACCOUNT JOURNAL ] ===============================================================
  // nextPressed(
  //     {required String format,
  //     bool isFromPayment = false,
  //     bool skipDisablePrinting = false,
  //     bool skipDisablePrintOrderInvoice = false}) async {
  //   PdfPageFormat pdfFormat = getFormatByName(formatName: format);
  //   if (isFromPayment) {
  //     if (pdfFormat == PdfPageFormat.roll80) {
  //       if (SharedPr.printingPreferenceObj!.isSilentPrinting! ||
  //           ((Platform.isAndroid || Platform.isIOS))) {
  //         await printingInvoiceDirectPrintPdf(
  //             format: format,
  //             pdfFormat: pdfFormat,
  //             disablePrintFullInvoice:
  //                 (!SharedPr.printingPreferenceObj!.disablePrinting! ||skipDisablePrinting) && !skipDisablePrintOrderInvoice
  //                     ? false
  //                     : true,
  //             disablePrintOrderInvoice: skipDisablePrintOrderInvoice
  //                 ? false
  //                 : skipDisablePrinting ? true : SharedPr.currentPosObject!.disableNetworkPrinting!);
  //       } else {
  //         await printingInvoiceLayoutPdf(
  //             pdfFormat: pdfFormat,
  //             disablePrintFullInvoice:
  //                 (!SharedPr.printingPreferenceObj!.disablePrinting! ||
  //                         skipDisablePrinting) && !skipDisablePrintOrderInvoice
  //                     ? false
  //                     : true,
  //             disablePrintOrderInvoice: skipDisablePrintOrderInvoice
  //                 ? false
  //                 : skipDisablePrinting ? true : SharedPr.currentPosObject!.disableNetworkPrinting!);
  //       }
  //     } else if (SharedPr.printingPreferenceObj!.isDownloadPDF!) {
  //       await downloadPDF(format: pdfFormat);
  //     }
  //   } else {
  //     await printingInvoiceDirectPrintPdf(pdfFormat: pdfFormat, format: format);
  //   }
  // }

  nextPressed({
    required String format,
    bool isFromPayment = false,
    PrintingTypeSkip? printingTypeSkip,
  }) async {
    PdfPageFormat pdfFormat = getFormatByName(formatName: format);
    if (isFromPayment) {
      if (pdfFormat == PdfPageFormat.roll80) {
        PosSettingInfo? posSettingInfo = SharedPr.currentPosObject;
        if (posSettingInfo?.enableDirectPrinter != null &&
            posSettingInfo!.enableDirectPrinter!) {
          print("posSettingInfo?.enableDirectPrinter=======================");
          Printer? defaultPrinter = (Platform.isAndroid || Platform.isIOS) ? null : await PrintHelper.setDefaultPrinter();
          Printer? printer;
          // جلب الطابعة من الـ Controller إن وُجدت
          ConnectedPrinterController printingController =
              Get.isRegistered<ConnectedPrinterController>()
                  ? Get.find<ConnectedPrinterController>()
                  : Get.put(ConnectedPrinterController());
          if (printingController.connectedPrinterList
              .any((elem) => elem.paperType == format)) {
            String printerName = printingController.connectedPrinterList
                .firstWhere((elem) => elem.paperType == format)
                .printerName!;
            printer = printingController.systemPrinterList
                .firstWhere((elem) => elem.name == printerName);
          }
          if (posSettingInfo.customerPrinter! &&
              printingTypeSkip !=
                  PrintingTypeSkip.skip_disable_order_printing) {
            print("customerPrinter=======================");
            print(
                "posSettingInfo.customerPrintingMode======================= ${posSettingInfo.customerPrintingMode}");
            print("printingTypeSkip=======================$printingTypeSkip");
            print(
                "posSettingInfo.autoCustomerPrinter!=======================${posSettingInfo.autoCustomerPrinter!}");
            //  فاتورة العميل بلوثوث او usb
            if (posSettingInfo.autoCustomerPrinter! ||
                (printingTypeSkip != null &&
                    printingTypeSkip ==
                        PrintingTypeSkip.skip_disable_customer_printing)) {
              if (posSettingInfo.customerPrintingMode ==
                      PrintingType.is_silent_printing.name ||
                  ((Platform.isAndroid || Platform.isIOS))) {
                // var categoryids = saleOrderLinesList!.map((e) => e.productId!.soPosCategId!,).toList();
                await printingInvoiceDirectPrintPdf(
                  format: format,
                  pdfFormat: pdfFormat,
                  disablePrintFullInvoice: false,
                  disablePrintOrderInvoice: true,
                  printingNetworksIp: [],
                  categoryids: [],
                  isSilent: true,
                  isWindows: ((Platform.isAndroid || Platform.isIOS)) ? false : true,
                  printerIPorDefault: ((Platform.isAndroid || Platform.isIOS))
                      ? ''
                      : defaultPrinter ?? printer,
                  ipPorts: null,
                  printers: [],
                );
              } else {
                await printingInvoiceLayoutPdf(
                    pdfFormat: pdfFormat,
                    disablePrintFullInvoice: false,
                    disablePrintOrderInvoice: true,
                    categoryids: posSettingInfo.orderPrinterCategoryIds ?? []
                    
                    );
              }
            }
          }
          // حق طلبات المطبخ بلوثوت او usb
          if (posSettingInfo.orderPrinter! &&
              printingTypeSkip !=
                  PrintingTypeSkip.skip_disable_customer_printing) {
            print("orderPrinter=======================");
            print(
                "posSettingInfo.orderPrintingMode======================= ${posSettingInfo.orderPrintingMode}");
            print("printingTypeSkip=======================$printingTypeSkip");
            print(
                "posSettingInfo.autoOrderPrinter!=======================${posSettingInfo.autoOrderPrinter!}");
            if (posSettingInfo.autoOrderPrinter! ||
                (printingTypeSkip != null &&printingTypeSkip ==PrintingTypeSkip.skip_disable_order_printing)) {
              if (posSettingInfo.orderPrintingMode ==PrintingType.is_silent_printing.name ||
                  (Platform.isAndroid || Platform.isIOS)) {
                await printingInvoiceDirectPrintPdf(
                    format: format,
                    pdfFormat: pdfFormat,
                    disablePrintFullInvoice: true,
                    disablePrintOrderInvoice: false,
                    printingNetworksIp: [],
                    categoryids: posSettingInfo.orderPrinterCategoryIds ?? [],
                    isSilent: true,
                    isWindows:
                        ((Platform.isAndroid || Platform.isIOS)) ? false : true,
                    printerIPorDefault: ((Platform.isAndroid || Platform.isIOS))
                        ? ''
                        : defaultPrinter ?? printer,
                    ipPorts: null,
                    printers: []);
              } else {
                await printingInvoiceLayoutPdf(
                    pdfFormat: pdfFormat,
                    disablePrintFullInvoice: true,
                    disablePrintOrderInvoice: false,
                    categoryids: posSettingInfo.orderPrinterCategoryIds ?? []
                    );
              }
            }
          }
        }
        if (posSettingInfo?.enableNetworkPrint != null &&
            posSettingInfo!.enableNetworkPrint!) {
          print("enableNetworkPrint=======================");
          print(
              "enableDirectPrinter======================= ${posSettingInfo.enableDirectPrinter}");
          print("printingTypeSkip======================= ${printingTypeSkip}");
          List<dynamic> printingNetworksIp = await getPrintingSetting();
          var ipPorts = await LanPrintingHelper.listSharedPrintersWithIP();
          List<Printer> printers = await PrintHelper.getPrinters();
          final ip = printingNetworksIp.firstWhere(
            (s) => s.isCustomerPrinter,
            orElse: () => PrintingSetting(
                ipAddress: '',
                isCustomerPrinter: false,
                autoNetworkPrinter: false),
          );
          Printer? targetPrinter = printers.firstWhereOrNull(
            (p) => ipPorts.any((port) =>
                port.name.trim() == p.name.trim() &&
                port.portName == ip.ipAddress),
          );
          if (!posSettingInfo.enableDirectPrinter!) {
            await printingInvoiceDirectPrintPdf(
                format: format,
                pdfFormat: pdfFormat,
                categoryids: [],
                printingNetworksIp: printingNetworksIp,
                ipPorts: ipPorts,
                printers: printers,
                printerIPorDefault: targetPrinter,
                isWindows:
                    ((Platform.isAndroid || Platform.isIOS)) ? false : true,
                printingTypeSkip: printingTypeSkip,
                disablePrintOrderInvoice: (printingTypeSkip != null &&
                        printingTypeSkip ==
                            PrintingTypeSkip.skip_disable_customer_printing)
                    ? true
                    : false,
                disablePrintFullInvoice: (printingTypeSkip != null &&
                        printingTypeSkip ==
                            PrintingTypeSkip.skip_disable_order_printing)
                    ? true
                    : (printingTypeSkip != null &&
                            printingTypeSkip ==
                                PrintingTypeSkip.skip_disable_customer_printing)
                        ? false
                        : ip.autoNetworkPrinter == true
                            ? false
                            : true);
          }
          if (posSettingInfo.enableDirectPrinter!) {
            await printingInvoiceDirectPrintPdf(
                format: format,
                pdfFormat: pdfFormat,
                categoryids: [],
                ipPorts: ipPorts,
                printers: printers,
                printerIPorDefault: targetPrinter,
                printingNetworksIp: printingNetworksIp,
                isWindows:
                    ((Platform.isAndroid || Platform.isIOS)) ? false : true,
                disablePrintFullInvoice: posSettingInfo.customerPrinter ==
                            true ||
                        (printingTypeSkip != null &&
                            printingTypeSkip ==
                                PrintingTypeSkip.skip_disable_order_printing)
                    ? true
                    : (printingTypeSkip != null &&
                            printingTypeSkip ==
                                PrintingTypeSkip.skip_disable_customer_printing)
                        ? false
                        : ip.autoNetworkPrinter,
                disablePrintOrderInvoice:
                    posSettingInfo.orderPrinter! == true &&
                            (posSettingInfo.posCategoryIds!.length !=
                                posSettingInfo.orderPrinterCategoryIds!.length)
                        ? false
                        : posSettingInfo.orderPrinter! == true ||
                                (printingTypeSkip != null &&
                                    printingTypeSkip ==
                                        PrintingTypeSkip
                                            .skip_disable_customer_printing)
                            ? true
                            : false,
                printingTypeSkip: printingTypeSkip);
          }
        }
      }
      else if (SharedPr.printingPreferenceObj!.isDownloadPDF!) {
        await downloadPDF(format: pdfFormat);
      }
    } else {
      PaymentController paymentController = Get.put(PaymentController());
      showPDFInvoice(paymentController: paymentController, isFromPayment: isFromPayment);
      // await printingInvoiceDirectPrintPdf(pdfFormat: pdfFormat, format: format);
    }
  }
  downloadPDF({required format, bool isdownloadRoll = false}) async {
    PdfPageFormat pdfFormat =
        format is String ? getFormatByName(formatName: format) : format;
    final pdfDirectory = await pdfCreatDirectory('PDF Invoices');
    await buildPDFLayout(format: pdfFormat, isdownloadRoll: isdownloadRoll);
    // final file = File(filePath);
    update();
    await pdfCreatfile(
        pdfDirectory: pdfDirectory, filename: saleOrderInvoice!.id.toString());
  }

  // Future<void> printingInvoiceLayoutPdf({
  //   required PdfPageFormat pdfFormat,
  //   bool disablePrintFullInvoice = false,
  //   bool disablePrintOrderInvoice = false,
  // }) async {
  //   // ignore: unused_element
  //   Future<void> printItems({
  //     required List<SaleOrderLine> items,
  //     required bool silentPrint,
  //     required String ip,
  //   }) async {
  //     List<Printer> printers = await PrintHelper.getPrinters();
  //     var ipPorts = await LanPrintingHelper.listSharedPrintersWithIP();
  //     var defaultPrinter = await PrintHelper.setDefaultPrinter();

  //     Printer targetPrinter = printers.firstWhere(
  //       (p) {
  //         var port = ipPorts.firstWhere(
  //           (port) => port.portName == ip,
  //           orElse: () => PowerShellSharedPrinter(name: '', portName: ''),
  //         );
  //         return p.name.trim() == port.name.trim();
  //       },
  //       orElse: () => defaultPrinter,
  //     );

  //     final pdfLayout = await buildPDFLayout(
  //       format: pdfFormat,
  //       isdownloadRoll: false,
  //       items: items,
  //     );

  //     if (silentPrint) {
  //       await Printing.directPrintPdf(
  //         format: pdfFormat,
  //         printer: targetPrinter,
  //         onLayout: pdfLayout,
  //         name: items.isNotEmpty
  //             ? items[0].productId!.soPosCategName!
  //             : saleOrderInvoice!.id.toString(),
  //       );
  //     } else {
  //       await Printing.layoutPdf(
  //         format: pdfFormat,
  //         onLayout: pdfLayout,
  //         name: items.isNotEmpty
  //             ? items[0].productId!.soPosCategName!
  //             : saleOrderInvoice!.id.toString(),
  //       );
  //     }
  //   }

  //   if (!disablePrintOrderInvoice) {
  //     var printingSetting = await getPrintingSetting();
  //     Map<String, List<SaleOrderLine>> printerToItems = {};

  //     for (var printer in printingSetting) {
  //       if (printer.disablePrinting) continue;
  //       for (var categoryId in printer.posCategoryIds) {
  //         final filteredLines = saleOrderLinesList!
  //             .where((line) => line.productId?.soPosCategId == categoryId)
  //             .toList();
  //         if (filteredLines.isEmpty) continue;

  //         final key =
  //             '${printer.ipAddress}:$categoryId:${printer.printingMode}';
  //         printerToItems[key] = filteredLines;
  //       }
  //     }

  //     if (printerToItems.isNotEmpty) {
  //       for (var entry in printerToItems.entries) {
  //         final parts = entry.key.split(':');
  //         final ip = parts[0];
  //         final printingMode = parts[2];
  //         final items = entry.value;

  //         await printItems(
  //           items: items,
  //           silentPrint: printingMode == PrintingType.is_silent_printing.name,
  //           ip: ip,
  //         );
  //       }
  //     } else if (SharedPr.currentPosObject!.disableNetworkPrinting!) {
  //       if ((Platform.isAndroid || Platform.isIOS)) {
  //       } else {
  //         // طباعة حسب الفئات في حالة عدم وجود إعدادات طباعة معطلة الشبكة
  //         Map<int?, List<SaleOrderLine>> categoryToItems = {};
  //         for (var line in saleOrderLinesList!) {
  //           final category = line.productId?.soPosCategId;
  //           categoryToItems.putIfAbsent(category, () => []).add(line);
  //         }
  //         var defaultPrinter = await PrintHelper.setDefaultPrinter();
  //         for (var items in categoryToItems.values) {
  //           final pdfLayout = await buildPDFLayout(
  //             format: pdfFormat,
  //             isdownloadRoll: false,
  //             items: items,
  //           );
  //           await Printing.directPrintPdf(
  //             format: pdfFormat,
  //             printer: defaultPrinter,
  //             onLayout: pdfLayout,
  //             name: items.isNotEmpty
  //                 ? items[0].productId!.soPosCategName!
  //                 : saleOrderInvoice!.id.toString(),
  //           );
  //         }
  //       }
  //     }
  //   }

  //   if (!disablePrintFullInvoice) {
  //     await Printing.layoutPdf(
  //       format: pdfFormat,
  //       onLayout: await buildPDFLayout(
  //         format: pdfFormat,
  //         isdownloadRoll: true,
  //       ),
  //       name: saleOrderInvoice!.id.toString(),
  //     );
  //   }
  // }

  // Future<void> printingInvoiceDirectPrintPdf({
  //   required PdfPageFormat pdfFormat,
  //   required String format,
  //   bool disablePrintFullInvoice = false,
  //   bool disablePrintOrderInvoice = false,
  // }) async {
  //   var ipPorts;
  //   List<Printer> printers = [];
  //   Printer? printer;
  //   Printer? defaultPrinter;
  //   List<dynamic> printingSetting = await getPrintingSetting();

  //   if ((!Platform.isAndroid && !Platform.isIOS)) {
  //     ipPorts = await LanPrintingHelper.listSharedPrintersWithIP();
  //     printers = await PrintHelper.getPrinters();
  //     defaultPrinter = await PrintHelper.setDefaultPrinter();
  //     // جلب الطابعة من الـ Controller إن وُجدت
  //     ConnectedPrinterController printingController =
  //         Get.isRegistered<ConnectedPrinterController>()
  //             ? Get.find<ConnectedPrinterController>()
  //             : Get.put(ConnectedPrinterController());

  //     if (printingController.connectedPrinterList
  //         .any((elem) => elem.paperType == format)) {
  //       String printerName = printingController.connectedPrinterList
  //           .firstWhere((elem) => elem.paperType == format)
  //           .printerName!;
  //       printer = printingController.systemPrinterList
  //           .firstWhere((elem) => elem.name == printerName);
  //     }
  //   }
  //   // طباعة الأصناف حسب الإعدادات
  //   if (!disablePrintOrderInvoice) {
  //     if (printingSetting.isNotEmpty) {
  //       for (var setting in printingSetting) {
  //         if (setting.disablePrinting || setting.isCustomerPrinter) continue;
  //         Printer? targetPrinter;
  //         if ((!Platform.isAndroid && !Platform.isIOS)) {
  //           var findPort = ipPorts.firstWhere(
  //             (port) => port.portName == setting.ipAddress,
  //             orElse: () => PowerShellSharedPrinter(name: '', portName: ''),
  //           );
  //           targetPrinter = printers.firstWhere(
  //             (p) => p.name.trim() == findPort.name.trim(),
  //             orElse: () => printer ?? defaultPrinter!,
  //           );
  //         }
  //         for (var categoryId in setting.posCategoryIds) {
  //           final filteredLines = saleOrderLinesList!
  //               .where((line) => line.productId?.soPosCategId == categoryId)
  //               .toList();

  //           if (filteredLines.isEmpty) continue;

  //           await _printItems(filteredLines, targetPrinter,
  //               silent: setting.printingMode ==
  //                   PrintingType.is_silent_printing.name,
  //               printerIp: setting.ipAddress,
  //               format: pdfFormat);
  //         }
  //       }
  //     } else {
  //       if ((!Platform.isAndroid && !Platform.isIOS)) {
  //         // بدون إعدادات مخصصة: اطبع حسب الفئات
  //         var categoryToItems = <int?, List<SaleOrderLine>>{};
  //         for (var line in saleOrderLinesList!) {
  //           categoryToItems
  //               .putIfAbsent(line.productId?.soPosCategId, () => [])
  //               .add(line);
  //         }
  //         for (var items in categoryToItems.values) {
  //           await _printItems(items, printer ?? defaultPrinter,
  //               format: pdfFormat, printerIp: '');
  //         }
  //       }
  //     }
  //   }

  //   // طباعة الفاتورة الكاملة
  //   if (!disablePrintFullInvoice) {
  //     final ipAddress = printingSetting
  //         .firstWhere(
  //           (s) => s.isCustomerPrinter,
  //           orElse: () =>
  //               PrintingSetting(ipAddress: '', isCustomerPrinter: false),
  //         )
  //         .ipAddress;
  //     if ((Platform.isAndroid || Platform.isIOS)) {
  //       await  Get.to(() => ScreenshotWidget(
  //             printerIp: ipAddress,
  //             isChasherInvoice: true,
  //             child: rollAndroidPrint(isdownloadRoll: true),
  //           ));
  //         // await  Get.to(()=> TestUSBPrinter());
  //     } else {
  //       final targetPrinter = printers.firstWhere(
  //         (p) => ipPorts.any((port) =>
  //             port.name.trim() == p.name.trim() && port.portName == ipAddress),
  //         orElse: () => printer ?? defaultPrinter!,
  //       );
  //       await Printing.directPrintPdf(
  //         format: pdfFormat,
  //         printer: targetPrinter,
  //         onLayout: await buildPDFLayout(
  //           format: pdfFormat,
  //           isdownloadRoll: true,
  //         ),
  //         name: saleOrderInvoice!.id.toString(),
  //       );
  //     }
  //   }
  // }

  // // دالة لطباعة PDF مباشرة أو عرضها
  // Future<void> _printItems(List<SaleOrderLine> items, Printer? targetPrinter,
  //     {bool silent = true,
  //     required PdfPageFormat format,
  //     required String? printerIp}) async {
  //   final pdfLayout = await buildPDFLayout(
  //     format: format,
  //     isdownloadRoll: !silent,
  //     items: items,
  //   );
  //   if ((Platform.isAndroid || Platform.isIOS)) {
  //     if (printerIp != '') {
  //       await   Get.to(() => ScreenshotWidget(
  //             printerIp: printerIp,
  //             child: rollAndroidPrint(isdownloadRoll: false, items: items),
  //           ));
  //     }
  //   } else if (silent) {
  //     await Printing.directPrintPdf(
  //       format: format,
  //       printer: targetPrinter!,
  //       onLayout: pdfLayout,
  //       name: items.isNotEmpty
  //           ? items[0].productId!.soPosCategName!
  //           : saleOrderInvoice!.id.toString(),
  //     );
  //   } else {
  //     await Printing.layoutPdf(
  //       format: format,
  //       onLayout: pdfLayout,
  //       name: items.isNotEmpty
  //           ? items[0].productId!.soPosCategName!
  //           : saleOrderInvoice!.id.toString(),
  //     );
  //   }
  // }



  Future<void> printingInvoiceDirectPrintPdf({
    required PdfPageFormat pdfFormat,
    required String format,
    required dynamic printerIPorDefault,
    bool isWindows = false,
    bool disablePrintFullInvoice = false,
    bool disablePrintOrderInvoice = false,
    bool isSilent = false,
    required List<dynamic> printingNetworksIp,
    required List<int> categoryids,
    required dynamic ipPorts,
    required List<Printer> printers,
    PrintingTypeSkip? printingTypeSkip,
  }) async {
    // طباعة الأصناف حسب الإعدادات
    if (!disablePrintOrderInvoice) {
      // تبع الشبكات الاي بي
      if (printingNetworksIp.isNotEmpty) {
        print(" // تبع الشبكات الاي بي");
        for (var setting in printingNetworksIp) {
          if (setting.disablePrinting ||
              setting.isCustomerPrinter ||
              ((printingTypeSkip != null &&
                      printingTypeSkip ==
                          PrintingTypeSkip.skip_disable_order_printing)
                  ? false
                  : (setting.autoNetworkPrinter == true ? false : true)))
            continue;
          var findPort = ipPorts.firstWhere(
            (port) => port.portName == setting.ipAddress,
            orElse: () => PowerShellSharedPrinter(name: '', portName: ''),
          );
          Printer? targetPrinter = printers
              .firstWhereOrNull((p) => p.name.trim() == findPort.name.trim());
          for (var categoryId in setting.posCategoryIds) {
            final filteredLines = saleOrderLinesList!
                .where((line) => line.productId?.soPosCategId == categoryId)
                .toList();
            if (filteredLines.isEmpty) continue;
            await _printItems(filteredLines, targetPrinter,
                silent: setting.printingMode ==
                    PrintingType.is_silent_printing.name,
                printerIp: setting.ipAddress,
                isWindows: isWindows,
                format: pdfFormat);
          }
        }
      } else {
        print("طباعة فاتورة المطبخ لليواس بس والبلوثوث");
        print("categoryids $categoryids");
        for (var categoryId in categoryids) {
          final filteredLines = saleOrderLinesList!
              .where((line) => line.productId?.soPosCategId == categoryId)
              .toList();
          if (filteredLines.isEmpty) continue;
          await _printItems(filteredLines, printerIPorDefault.runtimeType==String ?null :printerIPorDefault,
              silent: isSilent,
              isWindows: isWindows,
              printerIp: printerIPorDefault,
              format: pdfFormat);
        }
      }
    }

    // طباعة الفاتورة الكاملة
    if (!disablePrintFullInvoice) {
      print(
          "// طباعة الفاتورة الكاملة===========isWindows $isWindows printerIPorDefault $printerIPorDefault");
      if (isWindows) {
        if (printerIPorDefault != null) {
          await Printing.directPrintPdf(
            format: pdfFormat,
            printer: printerIPorDefault,
            onLayout: await buildPDFLayout(
              format: pdfFormat,
              isdownloadRoll: true,
            ),
            name: saleOrderInvoice!.id.toString(),
          );
        }
      } else {
        print("$printerIPorDefault طباعة الفاتورة كاملة اندرويد");
        // await  Get.to(() => ScreenshotWidget(
        // printerIp: printerIPorDefault,
        // isChasherInvoice: true,
        // child: rollAndroidPrint(isdownloadRoll: true),
        //     ));
      }
    }
  }

  // دالة لطباعة PDF مباشرة أو عرضها
  Future<void> _printItems(List<SaleOrderLine> items, Printer? targetPrinter,
      {bool silent = true,
      bool isWindows = false,
      required PdfPageFormat format,
      required String? printerIp}) async {
    print(
        "items $items  targetPrinter $targetPrinter isWindows $isWindows printerIp $printerIp");
    if (isWindows) {
      print("طباعة فاتورة المطبخ للوندوز ");
      final pdfLayout = await buildPDFLayout(
        format: format,
        isdownloadRoll: !silent,
        items: items,
      );
      if (silent) {
        print(" اذا كانت سالينت طباعة فاتورة المطبخ للوندوز ");
        if (targetPrinter != null) {
          await Printing.directPrintPdf(
            format: format,
            printer: targetPrinter,
            onLayout: pdfLayout,
            name: items.isNotEmpty
                ? items[0].productId?.soPosCategName ?? "Invoice"
                : saleOrderInvoice!.id.toString(),
          );
        }
      } else {
        print(" اذا كانت ديلوق طباعة فاتورة المطبخ للوندوز ");
        await Printing.layoutPdf(
          format: format,
          onLayout: pdfLayout,
          name: items.isNotEmpty
              ? items[0].productId?.soPosCategName ?? "Invoice"
              : saleOrderInvoice!.id.toString(),
        );
      }
    } else {
      print(" طباعة فاتورة المطبخ اندرويد");
      await   Get.to(() => ScreenshotWidget(
      printerIp: printerIp,
      child: rollAndroidPrint(isdownloadRoll: false, items: items),
      ));
    }
  }

  Future<void> printingInvoiceLayoutPdf({
    required PdfPageFormat pdfFormat,
    bool disablePrintFullInvoice = false,
    bool disablePrintOrderInvoice = false,
    required List<int> categoryids
  }) async {

    if (!disablePrintOrderInvoice) {
          for (var categoryId in categoryids) {
            final filteredLines = saleOrderLinesList!
                .where((line) => line.productId?.soPosCategId == categoryId)
                .toList();
            final pdfLayout = await buildPDFLayout(
              format: pdfFormat,
              isdownloadRoll: false,
              items: filteredLines,
            );
            await Printing.layoutPdf(
              format: pdfFormat,
              onLayout: pdfLayout,
              name: saleOrderInvoice!.id.toString(),
            );
          }
    }
    if (!disablePrintFullInvoice) {
      await Printing.layoutPdf(
        format: pdfFormat,
        onLayout: await buildPDFLayout(
          format: pdfFormat,
          isdownloadRoll: true,
        ),
        name: saleOrderInvoice!.id.toString(),
      );
    }
  }
  Future<Directory> pdfCreatDirectory(String directoryName) async {
    Directory baseDir;

    if (Platform.isWindows) {
      baseDir = Directory('${Platform.environment['USERPROFILE']}/Documents');
    } else if (Platform.isAndroid) {
      // baseDir = (await getExternalStorageDirectory())!;
      baseDir = Directory('/storage/emulated/0/Download');
      if (kDebugMode) {
        print("Platform.isAndroid baseDir :: ${baseDir.path}");
      }
    } else if (Platform.isMacOS || Platform.isLinux) {
      baseDir = Directory('${Platform.environment['HOME']}/Documents');
    } else {
      // fallback for unsupported platform
      baseDir = await getApplicationDocumentsDirectory();
    }

    final downloadPath = SharedPr.printingPreferenceObj?.downloadPath;
    final pdfDirectory = Directory(
      (downloadPath == null || downloadPath.isEmpty)
          ? '${baseDir.path}/$directoryName'
          : downloadPath,
    );

    if (!pdfDirectory.existsSync()) {
      pdfDirectory.createSync(recursive: true);
    }

    return pdfDirectory;
  }

  pdfCreatfile(
      {pw.Document? pdfSession,
      required Directory pdfDirectory,
      required String filename}) async {
    var pdffile = pdfSession ?? pdf;
    if (pdffile != null) {
      final filePath = '${pdfDirectory.path}/$filename.pdf';
      try {
        final file = File(filePath);

        await file.writeAsBytes(await pdffile.save());
        if (Platform.isWindows) {
          await Process.run('cmd', ['/c', 'start', '""', filePath]);
        } else if (Platform.isMacOS) {
          await Process.run('open', [filePath]);
        } else if (Platform.isLinux) {
          await Process.run('xdg-open', [filePath]);
        }
      } catch (e) {}
    } else {}
  }

  PdfPageFormat getFormatByName({required String formatName}) {
    switch (formatName) {
      case 'A3':
        return PdfPageFormat.a3;
      case 'A4':
        return PdfPageFormat.a4;
      case 'A5':
        return PdfPageFormat.a5;
      case 'A6':
        return PdfPageFormat.a6;
      case 'Letter':
        return PdfPageFormat.letter;
      case 'Legal':
        return PdfPageFormat.legal;
      case 'Roll57':
        return PdfPageFormat.roll57;
      case 'Roll80':
        return PdfPageFormat.roll80;
      case 'Undefined':
        return PdfPageFormat.undefined;
      case 'Standard':
      default:
        return PdfPageFormat.standard;
    }
  }

  buildPDFLayout(
      {required PdfPageFormat format,
      bool isdownloadRoll = false,
      List<SaleOrderLine>? items}) {
    return (format) => isCash
        ? generateCachPdf(
            format: format, isdownloadRoll: isdownloadRoll, items: items)
        : generateTermPdf(
            format: format,
          );
  }

  Future<Uint8List> generateCachrollPdf() async {
    pdf = await rollPrint2();
    // ============================================= [ ENCODE PDF FILE TO BASE64 ] ============================================
    MessagingController messagingController =
        Get.isRegistered<MessagingController>()
            ? Get.find<MessagingController>()
            : Get.put(MessagingController());
    messagingController.encodedFile =
        FileConvertHelper.convertUint8ListToBase64(await pdf!.save());

    // ============================================= [ ENCODE PDF FILE TO BASE64 ] ============================================

    return pdf!.save();
  }

  Future<Uint8List> generateCacha4Pdf() async {
    pdf = await a4Print(
      isSimple: true,
    );
    // ============================================= [ ENCODE PDF FILE TO BASE64 ] ============================================
    MessagingController messagingController =
        Get.isRegistered<MessagingController>()
            ? Get.find<MessagingController>()
            : Get.put(MessagingController());
    messagingController.encodedFile =
        FileConvertHelper.convertUint8ListToBase64(await pdf!.save());

    return pdf!.save();
  }

  Future<Uint8List> generateCachPdf(
      {required PdfPageFormat format,
      required bool isdownloadRoll,
      List<SaleOrderLine>? items}) async {
    if (isDefault) {
      pdf = await rollPrint2(
          format: format, isdownloadRoll: isdownloadRoll, items: items);
      // ============================================= [ ENCODE PDF FILE TO BASE64 ] ============================================
      MessagingController messagingController =
          Get.isRegistered<MessagingController>()
              ? Get.find<MessagingController>()
              : Get.put(MessagingController());
      messagingController.encodedFile =
          FileConvertHelper.convertUint8ListToBase64(await pdf!.save());

      // ============================================= [ ENCODE PDF FILE TO BASE64 ] ============================================

      return pdf!.save();
    } else {
      InvoiceController invoiceController =
          Get.isRegistered<InvoiceController>()
              ? Get.find<InvoiceController>()
              : Get.put(InvoiceController());
      pdf = await a4Print(
          isSimple: true,
          format: format,
          isRefundInvoice: invoiceController.isRefundInvoiceColor);
      // ============================================= [ ENCODE PDF FILE TO BASE64 ] ============================================
      MessagingController messagingController =
          Get.isRegistered<MessagingController>()
              ? Get.find<MessagingController>()
              : Get.put(MessagingController());
      messagingController.encodedFile =
          FileConvertHelper.convertUint8ListToBase64(await pdf!.save());

      return pdf!.save();
    }
  }

  Future<Uint8List> generateTermPdf({
    required PdfPageFormat format,
  }) async {
    customer =
        customersList!.firstWhere((e) => e.id == saleOrderInvoice!.partnerId);
    InvoiceController invoiceController = Get.isRegistered<InvoiceController>()
        ? Get.find<InvoiceController>()
        : Get.put(InvoiceController());
    pdf = await a4Print(
        isSimple: customer!.isCompany! ? false : true,
        customer: customer,
        format: format,
        isRefundInvoice: invoiceController.isRefundInvoiceColor);
    // ============================================= [ ENCODE PDF FILE TO BASE64 ] ============================================
    MessagingController messagingController =
        Get.isRegistered<MessagingController>()
            ? Get.find<MessagingController>()
            : Get.put(MessagingController());
    messagingController.encodedFile =
        FileConvertHelper.convertUint8ListToBase64(await pdf!.save());
    // ============================================= [ ENCODE PDF FILE TO BASE64 ] ============================================
    return pdf!.save();
  }

  config() {
    final intl.DateFormat formatterAr = intl.DateFormat('MMMM', 'ar');
    if (saleOrderInvoice!.orderDate.toString().contains("T")) {
      timeOrder =
          saleOrderInvoice!.orderDate.toString().substring(11, 19).toString();
      yearOrder = saleOrderInvoice!.orderDate.toString().substring(0, 4);
      monthOrder = formatterAr
          .format(DateTime.parse(saleOrderInvoice!.orderDate!))
          .toString();
      dayOrder = saleOrderInvoice!.orderDate.toString().substring(8, 10);
    } else {
      timeOrder = intl.DateFormat("HH:mm:ss").format(DateTime.now());
      yearOrder =
          (DateTime.parse(saleOrderInvoice!.orderDate!).year).toString();
      monthOrder = formatterAr
          .format(DateTime.parse(saleOrderInvoice!.orderDate!))
          .toString();
      dayOrder = (DateTime.parse(saleOrderInvoice!.orderDate!).day).toString();
    }
  }

  printingInvoice({
    String? titleValue,
    bool isFromPayment = false,
    bool isShowOnly = false,
    SaleOrderInvoice? saleOrderInvoiceValue,
  }) async {
    PaymentController paymentController = Get.put(PaymentController());

    InvoiceController invoiceController = Get.put(InvoiceController());
    title = titleValue!;
    customersList = invoiceController.customersList;
    accountJournalList = paymentController.accountJournalList;
    if (isFromPayment) {
      saleOrderInvoice = invoiceController.saleOrderInvoice;
      checkboxDisable = invoiceController.saleOrderInvoice!.partnerId !=
          SharedPr.currentPosObject!.cashPartnerId;
      isCash = invoiceController.saleOrderInvoice!.partnerId ==
          SharedPr.currentPosObject!.cashPartnerId;
      saleOrderLinesList = invoiceController.saleOrderLinesList;
    } else {
      InvoiceOperationsController invoiceOperationsController =
          Get.find<InvoiceOperationsController>();
      bool checkConnect = await invoiceOperationsController.checkConnectivity();
      if (!checkConnect) {
        await invoiceController.updateSaleOrderLine(
            saleOrderInvoice: saleOrderInvoiceValue!);
      } else {
        invoiceController.saleOrderInvoice ??=
            SaleOrderInvoice.fromJson(saleOrderInvoiceValue!.toJson());
      }
      if (saleOrderInvoiceValue == null) {
        saleOrderInvoice = invoiceController.saleOrderInvoice;
        checkboxDisable = invoiceController.saleOrderInvoice!.partnerId !=
            SharedPr.currentPosObject!.cashPartnerId;
        isCash = invoiceController.saleOrderInvoice!.partnerId ==
            SharedPr.currentPosObject!.cashPartnerId;
        saleOrderLinesList = invoiceController.saleOrderLinesList;
      } else {
        saleOrderInvoice = saleOrderInvoiceValue;
        checkboxDisable = saleOrderInvoiceValue.partnerId !=
            SharedPr.currentPosObject!.cashPartnerId;
        isCash = saleOrderInvoiceValue.partnerId ==
            SharedPr.currentPosObject!.cashPartnerId;
        saleOrderLinesList = saleOrderInvoiceValue.saleOrderLine;
      }
    }

    await AppInvoiceStyle.loadFonts();
    if (isFromPayment) {
      if (SharedPr.printingPreferenceObj!.showPosPaymentSummary!) {
        await nextPressed(
            format: checkbox ? "A4" : "Roll80", isFromPayment: isFromPayment);
        invoiceController.preventQuantityDecrease = true;
        Get.to(() => PaymentSammryScreen(
              totalPrice: saleOrderInvoice!.totalPrice,
              newSaleOrder: saleOrderInvoiceValue,
            ));
      } else {
        paymentController.isPDFDialogOpen = true;
        await nextPressed(
            format: checkbox ? "A4" : "Roll80", isFromPayment: isFromPayment);
        paymentController.escapeFocus(frompayment: isFromPayment);
        paymentController.isPDFDialogOpen = false;
      }
    } else {
      showPDFInvoice(
          paymentController: paymentController,
          isFromPayment: isFromPayment,
          isShowOnly: isShowOnly);
    }
  }

  /// ================================================ [ PRINTING INVOICE ] =================================================

  Future<List<dynamic>> getPrintingSetting() async {
    var generalLocalDBInstance = GeneralLocalDB.getInstance<PrintingSetting>(
        fromJsonFun: PrintingSetting.fromJson);
    return await generalLocalDBInstance!.index();
  }

// Future<RenderRepaintBoundary> widgetToImage(Widget widget, {double pixelRatio = 3.0}) async {
//   final repaintBoundary = RenderRepaintBoundary();

//   final renderView = RenderView(
//     child: RenderPositionedBox(
//       alignment: Alignment.center,
//       child: repaintBoundary,
//     ),
//     configuration: ViewConfiguration(
//       logicalConstraints: const BoxConstraints.tightFor(width: 800, height: 600),
//       physicalConstraints: const BoxConstraints.tightFor(width: 800, height: 600),
//       devicePixelRatio: pixelRatio,
//     ),
//     view: PlatformDispatcher.instance.implicitView!,
//   );

//   final pipelineOwner = PipelineOwner();
//   final buildOwner = BuildOwner(focusManager: FocusManager());

//   renderView.attach(pipelineOwner);

//   final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
//     container: repaintBoundary,
//     child: Directionality(
//       textDirection: SharedPr.lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
//       child: widget,
//     ),
//   ).attachToRenderTree(buildOwner);

//   // build & layout
//   buildOwner.buildScope(rootElement);
//   buildOwner.finalizeTree();
//   pipelineOwner.flushLayout();
//   pipelineOwner.flushCompositingBits();
//   pipelineOwner.flushPaint();

//   // // تحويل للصورة
//   // final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
//   // final byteData = await image.toByteData(format: ImageByteFormat.png);
//   // return byteData!.buffer.asUint8List();
//   return repaintBoundary;
// }
  Future<Uint8List> generateInvoiceImage(List<SaleOrderLine> items,
      {int width = 600, int height = 800}) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = const Color(0xFFFFFFFF);
    // ارسم خلفية بيضاء
    canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);

    final textPainter = TextPainter(
      textDirection: TextDirection.rtl, // لو لغتك عربية
    );

    // ارسم عنوان الفاتورة
    textPainter.text = TextSpan(
      text: 'فاتورة',
      style: TextStyle(color: Color(0xFF000000), fontSize: 30),
    );
    textPainter.layout(minWidth: 0, maxWidth: width.toDouble());
    textPainter.paint(canvas, Offset(20, 20));

    // ارسم جدول أو بيانات العناصر
    double yPosition = 70;
    final textStyle = TextStyle(color: Color(0xFF000000), fontSize: 18);

    for (var item in items) {
      final line =
          '${item.name}  x ${item.productUomQty}  -  ${item.priceUnit}';
      textPainter.text = TextSpan(text: line, style: textStyle);
      textPainter.layout(minWidth: 0, maxWidth: width.toDouble());
      textPainter.paint(canvas, Offset(20, yPosition));
      yPosition += 30;
    }

    // أنهي الرسم وحصل على الصورة
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}
