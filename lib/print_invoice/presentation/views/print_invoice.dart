// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:printing/printing.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/domain/invoice_printing_viewmodel.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/presentation/views/printer_page.dart';
import 'package:yousentech_pos_payment/payment/domain/payment_viewmodel.dart';

class PrinterInvoice extends StatefulWidget {
  PaymentController paymentController;

  bool isFromPayment;
  bool showActions;
  double? maxPageWidth;
  double? padding;
  Color? backgroundColor;
  PrinterInvoice({
    super.key,
    required this.paymentController,
    this.isFromPayment = false,
    this.showActions = true,
    this.maxPageWidth,
    this.padding,
    this.backgroundColor,
  });

  @override
  State<PrinterInvoice> createState() => _PrinterInvoiceState();
}

class _PrinterInvoiceState extends State<PrinterInvoice> {
  PrintingInvoiceController printingController =
      Get.put(PrintingInvoiceController());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<PrintingInvoiceController>(builder: (controller) {
        return InteractiveViewer(
          clipBehavior: Clip.none,
          minScale: 0.5,
          maxScale: 5,
          child: PdfPreview(
              dpi: 150,
              scrollViewDecoration: BoxDecoration(
                color: widget.backgroundColor, // لون خلفية منطقة العرض
              ),
              useActions: false,
              canDebug: false,
              maxPageWidth: widget.maxPageWidth,
              padding: EdgeInsets.all(widget.padding ?? 0.0),
              actionBarTheme:
                  PdfActionBarTheme(backgroundColor: AppColor.cyanTeal),
              actions: widget.showActions
                  ? [
                      PrinterPage(
                        onPressedCheckbox: () {
                          printingController.isDefault =
                              !printingController.isDefault;
                          printingController.checkbox =
                              !printingController.checkbox;
                          printingController.update();
                        },
                        onPressedNext: (
                          BuildContext context,
                          LayoutCallback build,
                          PdfPageFormat pageFormat,
                        ) async {
                          await printingController.nextPressed(
                              format:
                                  printingController.checkbox ? "A4" : "Roll80",
                              isFromPayment: widget.isFromPayment);
                          widget.paymentController
                              .escapeFocus(frompayment: widget.isFromPayment);
                        },
                      ),
                    ]
                  : null,
              build: (format) {
                return printingController.isCash
                    ? printingController.generateCachPdf(
                        format: format, isdownloadRoll: true)
                    : printingController.generateTermPdf(
                        format: format,
                      );
              }),
        );
      }),
    );
  }
}

class PdfRoll80Example extends StatelessWidget {
  const PdfRoll80Example({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Roll80 Example')),
      body: PdfPreview(
        build: (format) => _generateRoll80Pdf(),
        initialPageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm, // Width of 80mm
          double.infinity, // Infinite height for roll paper
          marginAll: 5 * PdfPageFormat.mm, // Optional margin
        ),
        pdfFileName: 'roll80.pdf',
      ),
    );
  }

  Future<Uint8List> _generateRoll80Pdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm, // 80mm width
          200 * PdfPageFormat.mm, // Example: fixed 200mm height
        ),
        build: (context) => pw.Column(
          children: [
            pw.Text('Roll80 Printer Example',
                style: const pw.TextStyle(fontSize: 20)),
            pw.Divider(),
            pw.Text('This is a sample text for a receipt-like document.'),
            pw.Text('You can print this on an 80mm roll printer.'),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
