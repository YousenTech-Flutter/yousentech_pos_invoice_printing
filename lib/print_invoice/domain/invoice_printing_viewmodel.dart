// ignore_for_file: empty_catches, unused_local_variable

import 'dart:async';
import 'dart:io';

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
import 'package:pos_shared_preferences/models/sale_order.dart';
import 'package:pos_shared_preferences/models/sale_order_line.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:printing/printing.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:yousentech_pos_invoice/invoices/domain/invoice_operations/invoice_operations_viewmodel.dart';
import 'package:yousentech_pos_invoice/invoices/domain/invoice_viewmodel.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/printer_helper.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/roll_print_helper2.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/show_pdf_invoic.dart';
import 'package:yousentech_pos_messaging/messaging/domain/messaging_viewmodel.dart';
import 'package:yousentech_pos_messaging/messaging/utils/file_convert_helper.dart';
import 'package:yousentech_pos_payment/payment/domain/payment_viewmodel.dart';
import 'package:yousentech_pos_payment/payment/presentation/payment_sammry_screen.dart';
import 'package:yousentech_pos_printing/printing/domain/app_connected_printers/connected_printer_viewmodel.dart';
import '../utils/a4_print_helper.dart';
import 'package:pdf/widgets.dart' as pw;

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
  nextPressed({required String format, bool isFromPayment = false}) async {
    PdfPageFormat pdfFormat = getFormatByName(formatName: format);

    if (isFromPayment) {
      if (!SharedPr.printingPreferenceObj!.disablePrinting!) {
        if (SharedPr.printingPreferenceObj!.isSilentPrinting!) {
          await printingInvoiceDirectPrintPdf(
            format: format,
            pdfFormat: pdfFormat,
          );
        } else {
          await printingInvoiceLayoutPdf(pdfFormat: pdfFormat);
        }
      }

      if (SharedPr.printingPreferenceObj!.isDownloadPDF!) {
        await downloadPDF(format: pdfFormat);
      }
    } else {
      await printingInvoiceDirectPrintPdf(pdfFormat: pdfFormat, format: format);
    }
  }

  downloadPDF({required format}) async {
    PdfPageFormat pdfFormat =
        format is String ? getFormatByName(formatName: format) : format;
    final pdfDirectory = pdfCreatDirectory('PDF Invoices');
    await buildPDFLayout(format: pdfFormat);
    update();
    await pdfCreatfile(
        pdfDirectory: pdfDirectory, filename: saleOrderInvoice!.id.toString());
  }

  printingInvoiceLayoutPdf({required PdfPageFormat pdfFormat}) async {
    buildPDFLayout(format: pdfFormat);
    await Printing.layoutPdf(
      format: pdfFormat,
      onLayout: buildPDFLayout(
        format: pdfFormat,
      ),
      name: saleOrderInvoice!.id.toString(),
    );
  }

  printingInvoiceDirectPrintPdf(
      {required PdfPageFormat pdfFormat, required String format}) async {
    final bool result;
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
    result = await Printing.directPrintPdf(
      format: pdfFormat,
      printer: printer ?? defaultPrinter,
      onLayout: await buildPDFLayout(
        format: pdfFormat,
      ),
      name: saleOrderInvoice!.id.toString(),
    );
  }

  Directory pdfCreatDirectory(String directoryName) {
    final directory =
        Directory('${Platform.environment['USERPROFILE']}/Documents');
    // For macOS and Linux use: '${Platform.environment['HOME']}/Documents'
    final pdfDirectory = Directory(
        SharedPr.printingPreferenceObj!.downloadPath == null ||
                SharedPr.printingPreferenceObj!.downloadPath == ''
            ? '${directory.path}/$directoryName'
            : SharedPr.printingPreferenceObj!.downloadPath!);

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
      } catch (e) {
      }
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

  buildPDFLayout({
    required PdfPageFormat format,
  }) {
    return (format) => isCash
        ? generateCachPdf(
            format: format,
          )
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

  Future<Uint8List> generateCachPdf({
    required PdfPageFormat format,
  }) async {
    if (isDefault) {
      pdf = await rollPrint2(format: format);
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
}
