// ignore_for_file: empty_catches, unused_local_variable

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:pos_shared_preferences/models/account_journal/data/account_journal.dart';
import 'package:pos_shared_preferences/models/customer_model.dart';
import 'package:pos_shared_preferences/models/printing/data/powershell_shared_printer.dart';
import 'package:pos_shared_preferences/models/printing_setting.dart';
import 'package:pos_shared_preferences/models/sale_order.dart';
import 'package:pos_shared_preferences/models/sale_order_line.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:printing/printing.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:yousentech_pos_invoice/invoices/domain/invoice_operations/invoice_operations_viewmodel.dart';
import 'package:yousentech_pos_invoice/invoices/domain/invoice_viewmodel.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/config/app_enums.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/printer_helper.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/roll_print_helper2.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/show_pdf_invoic.dart';
import 'package:yousentech_pos_local_db/yousentech_pos_local_db.dart';
import 'package:yousentech_pos_messaging/messaging/domain/messaging_viewmodel.dart';
import 'package:yousentech_pos_messaging/messaging/utils/file_convert_helper.dart';
import 'package:yousentech_pos_payment/payment/domain/payment_viewmodel.dart';
import 'package:yousentech_pos_payment_summary/payment_summary/presentation/payment_sammry_screen.dart';
import 'package:yousentech_pos_printing/printing/domain/app_connected_printers/connected_printer_viewmodel.dart';
import 'package:yousentech_pos_printing/printing/utils/subnet_determination.dart';
import 'package:ysn_pos_android_printer/android_printer/printer.dart';

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
  Font? fontMedium;
  Font? fontBold;

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
  nextPressed(
      {required String format,
      bool isFromPayment = false,
      bool skipDisablePrinting = false,
      bool skipDisablePrintOrderInvoice = false}) async {
    // print("=================== printToEpsonM267F===========");
    // // var printers= await PrintHelper.getPrinters();
    // // print("====printers ${printers.map((e)=>e.toMap()).toList()}");
    // // 
    // // await Printing.directPrintPdf(
    // //   format: pdfFormat,
    // //   printer: Printer(
    // //     url:'ipp://192.168.12.122',
    // //     name: 'My Printer',
    // //     isDefault: false,
    // //     isAvailable: true,
    // //   ),
    // //   onLayout: await buildPDFLayout(
    // //     format: pdfFormat,
    // //     isdownloadRoll: false,
    // //     items: saleOrderLinesList,
    // //   ),
    // //   name: '${saleOrderLinesList![0].productId?.soPosCategName}',
    // // );
    //   PdfPageFormat pdfFormat = getFormatByName(formatName: format);
    //     pdf = await rollPrint2(
    //       format: pdfFormat, isdownloadRoll: false, items: saleOrderLinesList);
    // var gg =  pdf!.save();

    // print("=================== gg===========${gg.runtimeType}");
    // await printImageToNetworkPrinter(pdfBytes: gg , fileName:'${saleOrderLinesList![0].productId?.soPosCategName}' );
    // print("=================== printToEpsonM267F End===========");
    // print("=================== printImage Start===========");
    // await  printImage();
    // print("=================== printImage End===========");

    // PdfPageFormat.roll80
    PdfPageFormat pdfFormat = getFormatByName(formatName: format);
    if (isFromPayment) {
      if (format == "Roll80") {
        if (SharedPr.printingPreferenceObj!.isSilentPrinting!) {
          await printingInvoiceDirectPrintPdf(
              format: format,
              pdfFormat: pdfFormat,
              disablePrintFullInvoice:
                  (!SharedPr.printingPreferenceObj!.disablePrinting! ||
                          skipDisablePrinting)
                      ? false
                      : true,
              disablePrintOrderInvoice: skipDisablePrintOrderInvoice
                  ? false
                  : SharedPr.currentPosObject!.disableNetworkPrinting!);
        } else {
          await printingInvoiceLayoutPdf(
              pdfFormat: pdfFormat,
              disablePrintFullInvoice:
                  (!SharedPr.printingPreferenceObj!.disablePrinting! ||
                          skipDisablePrinting)
                      ? false
                      : true,
              disablePrintOrderInvoice: skipDisablePrintOrderInvoice
                  ? false
                  : SharedPr.currentPosObject!.disableNetworkPrinting!);
        }
      } else if (SharedPr.printingPreferenceObj!.isDownloadPDF!) {
        await downloadPDF(format: pdfFormat);
      }
    } else {
      await printingInvoiceDirectPrintPdf(pdfFormat: pdfFormat, format: format);
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

  printingInvoiceLayoutPdf(
      {required PdfPageFormat pdfFormat,
      bool disablePrintFullInvoice = false,
      bool disablePrintOrderInvoice = false}) async {
    if (!disablePrintOrderInvoice) {
      var printingSetting = await getPrintingSetting();
      Map<String, List<SaleOrderLine>> printerToItems = {};
      for (var printer in printingSetting) {
        final printerIp = printer.ipAddress;
        final categoryIds = printer.posCategoryIds;
        final disablePrinting = printer.disablePrinting;
        final printingMode = printer.printingMode;
        // تخطي إذا كانت الطباعة غير مفعّلة
        if (disablePrinting) continue;

        for (var categoryId in categoryIds) {
          // نفلتر السطور التي تنتمي لهذا التصنيف
          final filteredLines = saleOrderLinesList!
              .where((line) => line.productId?.soPosCategId == categoryId)
              .toList();
          // نربط كل IP + category بمفتاح فريد
          final key = '$printerIp:$categoryId:$printingMode';
          printerToItems[key] = filteredLines;
        }
      }
      for (var entry in printerToItems.entries) {
        final ip = entry.key.split(':').first;
        final items = entry.value;
        if (entry.key.split(':').last == PrintingType.is_silent_printing.name) {
          List<Printer> printers = await PrintHelper.getPrinters();
          var ipPorts = await LanPrintingHelper.listSharedPrintersWithIP();
          var findPort = ipPorts.firstWhere((port) => port.portName == ip,
              orElse: () => PowerShellSharedPrinter(name: '', portName: ''));
          var defaultPrinter = await PrintHelper.setDefaultPrinter();
          await Printing.directPrintPdf(
            format: pdfFormat,
            printer: printers.firstWhere(
                (p) => p.name.trim() == findPort.name.trim(),
                orElse: () => defaultPrinter),
            onLayout: await buildPDFLayout(
              format: pdfFormat,
              isdownloadRoll: false,
              items: items,
            ),
            name: '${items[0].productId?.soPosCategName}',
          );
        } else {
          await Printing.layoutPdf(
            format: pdfFormat,
            onLayout: await buildPDFLayout(
              format: pdfFormat,
              isdownloadRoll: false,
              items: items,
            ),
            name: '${items[0].productId?.soPosCategName}',
          );
        }
      }
      if (printerToItems.entries.isEmpty &&
          SharedPr.currentPosObject!.disableNetworkPrinting!) {
        Map<int?, List<SaleOrderLine>> categoryToItems = {};
        for (var line in saleOrderLinesList!) {
          final category = line.productId?.soPosCategId;
          categoryToItems.putIfAbsent(category, () => []).add(line);
        }
        for (var entry in categoryToItems.entries) {
          var defaultPrinter = await PrintHelper.setDefaultPrinter();
          final items = entry.value;
          await Printing.directPrintPdf(
            format: pdfFormat,
            printer: defaultPrinter,
            onLayout: await buildPDFLayout(
              format: pdfFormat,
              isdownloadRoll: false,
              items: items,
            ),
            name: '${items[0].productId?.soPosCategName}',
          );
        }
      }
    }
    if (!disablePrintFullInvoice) {
      buildPDFLayout(format: pdfFormat);
      await Printing.layoutPdf(
        format: pdfFormat,
        onLayout: buildPDFLayout(
          format: pdfFormat,
          isdownloadRoll: true,
        ),
        name: saleOrderInvoice!.id.toString(),
      );
    }
  }

  printingInvoiceDirectPrintPdf(
      {required PdfPageFormat pdfFormat,
      required String format,
      bool disablePrintFullInvoice = false,
      bool disablePrintOrderInvoice = false}) async {
    bool result;
    Printer? printer;
    late Printer defaultPrinter;
    ConnectedPrinterController printingController =
        Get.isRegistered<ConnectedPrinterController>()
            ? Get.find<ConnectedPrinterController>()
            : Get.put(ConnectedPrinterController());

    if (printingController.connectedPrinterList.isNotEmpty &&
        printingController.connectedPrinterList.any(
          (elem) => elem.paperType == format,
        )) {
      String? printerName = printingController.connectedPrinterList
          .firstWhere(
            (elem) => elem.paperType == format,
          )
          .printerName;

      printer = printingController.systemPrinterList
          .firstWhere((elem) => elem.name == printerName);
    } else {
      defaultPrinter = await PrintHelper.setDefaultPrinter();
    }
    if (!disablePrintOrderInvoice) {
      var printingSetting = await getPrintingSetting();
      var ipPorts = await LanPrintingHelper.listSharedPrintersWithIP();
      List<Printer> printers = await PrintHelper.getPrinters();
      Map<String, List<SaleOrderLine>> printerToItems = {};
      // IP + تصنيف → سطور الأصناف
      for (var printer in printingSetting) {
        final printerIp = printer.ipAddress;
        final categoryIds = printer.posCategoryIds;
        final disablePrinting = printer.disablePrinting;
        final printingMode = printer.printingMode;
        // تخطي إذا كانت الطباعة غير مفعّلة
        if (disablePrinting) continue;
        for (var categoryId in categoryIds) {
          // نفلتر السطور التي تنتمي لهذا التصنيف
          final filteredLines = saleOrderLinesList!
              .where((line) => line.productId?.soPosCategId == categoryId)
              .toList();

          // نربط كل IP + category بمفتاح فريد
          final key = '$printerIp:$categoryId:$printingMode';
          printerToItems[key] = filteredLines;
        }
      }
      // طباعة حسب التصنيفات/IP
      for (var entry in printerToItems.entries) {
        final ip = entry.key.split(':').first;
        var findPort = ipPorts.firstWhere((port) => port.portName == ip,
            orElse: () => PowerShellSharedPrinter(name: '', portName: ''));
        final items = entry.value;
        if (entry.key.split(':').last == PrintingType.is_silent_printing.name) {
          result = await Printing.directPrintPdf(
            format: pdfFormat,
            printer: printers.firstWhere(
                (p) => p.name.trim() == findPort.name.trim(),
                orElse: () => printer ?? defaultPrinter),
            onLayout: await buildPDFLayout(
              format: pdfFormat,
              isdownloadRoll: false,
              items: items,
            ),
            name: '${items[0].productId?.soPosCategName}',
          );
        } else {
          await Printing.layoutPdf(
            format: pdfFormat,
            onLayout: await buildPDFLayout(
              format: pdfFormat,
              isdownloadRoll: false,
              items: items,
            ),
            name: '${items[0].productId?.soPosCategName}',
          );
        }
      }
      // if (printerToItems.entries.isEmpty && SharedPr.currentPosObject!.disableNetworkPrinting!) {
      //   // نجمع المنتجات حسب الفئة
      //   Map<int?, List<SaleOrderLine>> categoryToItems = {};
      //   for (var line in saleOrderLinesList!) {
      //     final category = line.productId?.soPosCategId;
      //     categoryToItems.putIfAbsent(category, () => []).add(line);
      //   }
      //   for (var entry in categoryToItems.entries) {
      //     final items = entry.value;
      //     result = await Printing.directPrintPdf(
      //       format: pdfFormat,
      //       printer: printer ?? defaultPrinter,
      //       onLayout: await buildPDFLayout(
      //         format: pdfFormat,
      //         isdownloadRoll: false,
      //         items: items,
      //       ),
      //       name: '${items[0].productId?.soPosCategName}',
      //     );
      //   }
      // }
    }
    // if (!disablePrintFullInvoice) {
    //   // ✅ اطبع كل الفاتورة كاملة (الكل)
    //   result = await Printing.directPrintPdf(
    //     format: pdfFormat,
    //     printer: printer ?? defaultPrinter,
    //     onLayout: await buildPDFLayout(
    //       format: pdfFormat,
    //       isdownloadRoll: true,
    //     ),
    //     name: saleOrderInvoice!.id.toString(),
    //   );
    // }
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
      {Document? pdfSession,
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
      pdf = await a4Print(isSimple: true, format: format);
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
    pdf = await a4Print(
        isSimple: customer!.isCompany! ? false : true,
        customer: customer,
        format: format);
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
      timeOrder = DateFormat("HH:mm:ss").format(DateTime.now());
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
  Future getPrintingSetting() async {
    var generalLocalDBInstance = GeneralLocalDB.getInstance<PrintingSetting>(
        fromJsonFun: PrintingSetting.fromJson);
    var ff = await generalLocalDBInstance!.index();
    return ff;
  }
}
