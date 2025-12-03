import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pos_shared_preferences/models/pos_setting_info_model.dart';
import 'package:pos_shared_preferences/models/printing/data/powershell_shared_printer.dart';
import 'package:pos_shared_preferences/models/printing_setting.dart';
import 'package:pos_shared_preferences/models/sale_order_line.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:printing/printing.dart';
import 'package:shared_widgets/shared_widgets/app_snack_bar.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/config/app_enums.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/domain/invoice_printing_viewmodel.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/roll_print_android_helper.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/screenshot_widget.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/show_pdf_invoic.dart';
import 'package:yousentech_pos_payment/payment/domain/payment_viewmodel.dart';
import 'package:yousentech_pos_printing/printing/domain/app_connected_printers/connected_printer_viewmodel.dart';
import 'package:yousentech_pos_printing/printing/utils/subnet_determination.dart';

class PrintHelper {
// to print invoice
  static Future setDefaultPrinter() async {
    List<Printer> listPrinters = await getPrinters();
    return listPrinters.isEmpty? null : listPrinters.firstWhere((element) => element.isDefault);
  }

  static Future<List<Printer>> getPrinters() async {
    if (Platform.isWindows){
          return  await Printing.listPrinters();
    }
    return [];

  }

    static nextPressed({
    required String format,
    bool isFromPayment = false,
    PrintingTypeSkip? printingTypeSkip,
    required PrintingInvoiceController printingInvoiceController,
    required BuildContext context,
  }) async {
    PdfPageFormat pdfFormat = getFormatByName(formatName: format);
    try {
      if (isFromPayment) {
        if (pdfFormat == PdfPageFormat.roll80) {
          PosSettingInfo? posSettingInfo = SharedPr.currentPosObject;
          if (posSettingInfo?.enableDirectPrinter != null &&
              posSettingInfo!.enableDirectPrinter!) {
            Printer? defaultPrinter =
                (Platform.isAndroid || Platform.isIOS)
                    ? null
                    : await PrintHelper.setDefaultPrinter();
            Printer? printer;
            // جلب الطابعة من الـ Controller إن وُجدت
            ConnectedPrinterController printingController =
                Get.isRegistered<ConnectedPrinterController>()
                    ? Get.find<ConnectedPrinterController>()
                    : Get.put(ConnectedPrinterController());
            if (printingController.connectedPrinterList.any(
              (elem) => elem.paperType == format,
            )) {
              String printerName =
                  printingController.connectedPrinterList
                      .firstWhere((elem) => elem.paperType == format)
                      .printerName!;
              printer = printingController.systemPrinterList.firstWhere(
                (elem) => elem.name == printerName,
              );
            }

            if (posSettingInfo.customerPrinter! && printingTypeSkip !=PrintingTypeSkip.skip_disable_order_printing) {
              //  فاتورة العميل بلوثوث او usb
              if (posSettingInfo.autoCustomerPrinter! ||
                  (printingTypeSkip != null &&
                      printingTypeSkip ==
                          PrintingTypeSkip.skip_disable_customer_printing)) {
                if (posSettingInfo.customerPrintingMode ==
                        PrintingType.is_silent_printing.name ||
                    ((Platform.isAndroid || Platform.isIOS))) {
                  await printingInvoiceDirectPrintPdf(
                    context: context,
                    printingInvoiceController: printingInvoiceController,
                    format: format,
                    pdfFormat: pdfFormat,
                    disablePrintFullInvoice: false,
                    disablePrintOrderInvoice: true,
                    printingNetworksIp: [],
                    categoryids: [],
                    isSilent: true,
                    isWindows:
                        ((Platform.isAndroid || Platform.isIOS)) ? false : true,
                    printerIPorDefault:
                        ((Platform.isAndroid || Platform.isIOS))
                            ? ''
                            : defaultPrinter ?? printer,
                    ipPorts: null,
                    printers: [],
                  );
                } else {
                  await printingInvoiceLayoutPdf(
                    printingInvoiceController: printingInvoiceController,
                    pdfFormat: pdfFormat,
                    disablePrintFullInvoice: false,
                    disablePrintOrderInvoice: true,
                    categoryids: posSettingInfo.orderPrinterCategoryIds ?? [],
                  );
                }
              }
            }
            // حق طلبات المطبخ بلوثوت او usb
            if (posSettingInfo.orderPrinter! &&
                printingTypeSkip !=
                    PrintingTypeSkip.skip_disable_customer_printing) {
              if (posSettingInfo.autoOrderPrinter! ||
                  (printingTypeSkip != null &&
                      printingTypeSkip ==
                          PrintingTypeSkip.skip_disable_order_printing)) {
                if (posSettingInfo.orderPrintingMode ==
                        PrintingType.is_silent_printing.name ||
                    (Platform.isAndroid || Platform.isIOS)) {
                  await printingInvoiceDirectPrintPdf(
                    context: context,
                    printingInvoiceController: printingInvoiceController,
                    format: format,
                    pdfFormat: pdfFormat,
                    disablePrintFullInvoice: true,
                    disablePrintOrderInvoice: false,
                    printingNetworksIp: [],
                    categoryids: posSettingInfo.orderPrinterCategoryIds ?? [],
                    isSilent: true,
                    isWindows:
                        ((Platform.isAndroid || Platform.isIOS)) ? false : true,
                    printerIPorDefault:
                        ((Platform.isAndroid || Platform.isIOS))
                            ? ''
                            : defaultPrinter ?? printer,
                    ipPorts: null,
                    printers: [],
                  );
                } else {
                  await printingInvoiceLayoutPdf(
                    printingInvoiceController: printingInvoiceController,
                    pdfFormat: pdfFormat,
                    disablePrintFullInvoice: true,
                    disablePrintOrderInvoice: false,
                    categoryids: posSettingInfo.orderPrinterCategoryIds ?? [],
                  );
                }
              }
            }
          }
          if (posSettingInfo?.enableNetworkPrint != null &&
              posSettingInfo!.enableNetworkPrint!) {
            List<dynamic> printingNetworksIp =
                await printingInvoiceController.getPrintingSetting();
            var ipPorts =
                (Platform.isAndroid || Platform.isIOS)
                    ? []
                    : await LanPrintingHelper.listSharedPrintersWithIP();
            List<Printer> printers =
                (Platform.isAndroid || Platform.isIOS)
                    ? []
                    : await PrintHelper.getPrinters();
            final ip = printingNetworksIp.firstWhere(
              (s) => s.isCustomerPrinter,
              orElse:
                  () => PrintingSetting(
                    ipAddress: '',
                    isCustomerPrinter: false,
                    autoNetworkPrinter: false,
                  ),
            );
            Printer? targetPrinter = printers.firstWhereOrNull(
              (p) => ipPorts.any(
                (port) =>
                    port.name.trim() == p.name.trim() &&
                    port.portName == ip.ipAddress,
              ),
            );
            if (!posSettingInfo.enableDirectPrinter!) {
              await printingInvoiceDirectPrintPdf(
                context: context,
                printingInvoiceController: printingInvoiceController,
                format: format,
                pdfFormat: pdfFormat,
                categoryids: [],
                printingNetworksIp: printingNetworksIp,
                ipPorts: ipPorts,
                printers: printers,
                printerIPorDefault:
                    (Platform.isAndroid || Platform.isIOS)
                        ? ip.ipAddress
                        : targetPrinter,
                isWindows:
                    ((Platform.isAndroid || Platform.isIOS)) ? false : true,
                printingTypeSkip: printingTypeSkip,
                disablePrintOrderInvoice:
                    (printingTypeSkip != null &&
                            printingTypeSkip ==
                                PrintingTypeSkip.skip_disable_customer_printing)
                        ? true
                        : false,
                disablePrintFullInvoice:
                    (printingTypeSkip != null &&
                            printingTypeSkip ==
                                PrintingTypeSkip.skip_disable_order_printing)
                        ? true
                        : (printingTypeSkip != null &&
                            printingTypeSkip ==
                                PrintingTypeSkip.skip_disable_customer_printing)
                        ? false
                        : ip.autoNetworkPrinter == true
                        ? false
                        : true,
              );
            }
            if (posSettingInfo.enableDirectPrinter!) {
              await printingInvoiceDirectPrintPdf(
                context: context,
                printingInvoiceController: printingInvoiceController,
                format: format,
                pdfFormat: pdfFormat,
                categoryids: [],
                ipPorts: ipPorts,
                printers: printers,
                printerIPorDefault:
                    (Platform.isAndroid || Platform.isIOS)
                        ? ip.ipAddress
                        : targetPrinter,
                printingNetworksIp: printingNetworksIp,
                isWindows:
                    ((Platform.isAndroid || Platform.isIOS)) ? false : true,
                disablePrintFullInvoice:
                    posSettingInfo.customerPrinter == true ||
                            (printingTypeSkip != null &&
                                printingTypeSkip ==
                                    PrintingTypeSkip
                                        .skip_disable_order_printing)
                        ? true
                        : (printingTypeSkip != null &&
                            printingTypeSkip ==
                                PrintingTypeSkip.skip_disable_customer_printing)
                        ? false
                        : ip.autoNetworkPrinter == true
                        ? false
                        : true,
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
                printingTypeSkip: printingTypeSkip,
              );
            }
          }
        } else if (SharedPr.printingPreferenceObj!.isDownloadPDF!) {
          await printingInvoiceController.downloadPDF(format: pdfFormat);
        }
      } else {
        PaymentController paymentController = Get.put(PaymentController());
        showPDFInvoice(
          paymentController: paymentController,
          isFromPayment: isFromPayment,
        );
      }
    } catch (e) {
      appSnackBar(status: false , message: e);
    }
  }

  static Future<void> printingInvoiceDirectPrintPdf({
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
    required PrintingInvoiceController printingInvoiceController,
    required BuildContext context,
  }) async {
    // طباعة الأصناف حسب الإعدادات
    if (!disablePrintOrderInvoice) {
      // تبع الشبكات الاي بي
      if (printingNetworksIp.isNotEmpty) {
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
          Printer? targetPrinter = printers.firstWhereOrNull(
            (p) => p.name.trim() == findPort.name.trim(),
          );
          for (var categoryId in setting.posCategoryIds) {
            final filteredLines =
                printingInvoiceController.saleOrderLinesList!
                    .where((line) => line.productId?.soPosCategId == categoryId)
                    .toList();
            if (filteredLines.isEmpty) continue;
            await _printItems(
              context: context,
              filteredLines,
              targetPrinter,
              silent:
                  setting.printingMode == PrintingType.is_silent_printing.name,
              printerIp: setting.ipAddress,
              isWindows: isWindows,
              format: pdfFormat,
              printingInvoiceController: printingInvoiceController,
            );
          }
        }
      } else {
        for (var categoryId in categoryids) {
          final filteredLines =
              printingInvoiceController.saleOrderLinesList!
                  .where((line) => line.productId?.soPosCategId == categoryId)
                  .toList();
          if (filteredLines.isEmpty) continue;
          await _printItems(
            context: context,
            filteredLines,
            printerIPorDefault.runtimeType == String
                ? null
                : printerIPorDefault,
            silent: isSilent,
            isWindows: isWindows,
            printerIp: printerIPorDefault,
            printingInvoiceController: printingInvoiceController,
            format: pdfFormat,
          );
        }
      }
    }

    // طباعة الفاتورة الكاملة
    if (!disablePrintFullInvoice) {
      if (isWindows) {
        if (printerIPorDefault != null) {
          await Printing.directPrintPdf(
            format: pdfFormat,
            printer: printerIPorDefault,
            onLayout: await printingInvoiceController.buildPDFLayout(
              format: pdfFormat,
              isdownloadRoll: true,
            ),
            name: printingInvoiceController.saleOrderInvoice!.id.toString(),
          );
        }
      } else {

        await Get.to(
          () => ScreenshotWidget(
            printerIp: printerIPorDefault,
            isChasherInvoice: true,
            child: rollAndroidPrint(context: context, isdownloadRoll: true),
          ),
        );
      }
    }
  }

  // دالة لطباعة PDF مباشرة أو عرضها
  static Future<void> _printItems(
    List<SaleOrderLine> items,
    Printer? targetPrinter, {
    bool silent = true,
    bool isWindows = false,
    required PdfPageFormat format,
    required PrintingInvoiceController printingInvoiceController,
    required BuildContext context,
    required String? printerIp,
  }) async {
    if (isWindows) {
      final pdfLayout = await printingInvoiceController.buildPDFLayout(
        format: format,
        isdownloadRoll: !silent,
        items: items,
      );
      if (silent) {
        if (targetPrinter != null) {
          await Printing.directPrintPdf(
            format: format,
            printer: targetPrinter,
            onLayout: pdfLayout,
            name:
                items.isNotEmpty
                    ? items[0].productId?.soPosCategName ?? "Invoice"
                    : printingInvoiceController.saleOrderInvoice!.id.toString(),
          );
        }
      } else {
        await Printing.layoutPdf(
          format: format,
          onLayout: pdfLayout,
          name:
              items.isNotEmpty
                  ? items[0].productId?.soPosCategName ?? "Invoice"
                  : printingInvoiceController.saleOrderInvoice!.id.toString(),
        );
      }
    } else {
      await Get.to(
        () => ScreenshotWidget(
          printerIp: printerIp,
          child: rollAndroidPrint(
            context: context,
            isdownloadRoll: false,
            items: items,
          ),
        ),
      );
    }
  }

  static Future<void> printingInvoiceLayoutPdf({
    required PdfPageFormat pdfFormat,
    bool disablePrintFullInvoice = false,
    bool disablePrintOrderInvoice = false,
    required List<int> categoryids,
    required PrintingInvoiceController printingInvoiceController,
  }) async {
    if (!disablePrintOrderInvoice) {
      for (var categoryId in categoryids) {
        final filteredLines =
            printingInvoiceController.saleOrderLinesList!
                .where((line) => line.productId?.soPosCategId == categoryId)
                .toList();
        final pdfLayout = await printingInvoiceController.buildPDFLayout(
          format: pdfFormat,
          isdownloadRoll: false,
          items: filteredLines,
        );
        await Printing.layoutPdf(
          format: pdfFormat,
          onLayout: pdfLayout,
          name: printingInvoiceController.saleOrderInvoice!.id.toString(),
        );
      }
    }
    if (!disablePrintFullInvoice) {
      await Printing.layoutPdf(
        format: pdfFormat,
        onLayout: await printingInvoiceController.buildPDFLayout(
          format: pdfFormat,
          isdownloadRoll: true,
        ),
        name: printingInvoiceController.saleOrderInvoice!.id.toString(),
      );
    }
  }

  static PdfPageFormat getFormatByName({required String formatName}) {
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

}
