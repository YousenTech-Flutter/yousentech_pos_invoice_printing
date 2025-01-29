// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pos_desktop/core/config/app_colors.dart';
import 'package:pos_desktop/features/invoice_printing/domain/invoice_printing_viewmodel.dart';
import 'package:printing/printing.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:yousentech_pos_invoice_printing/src/domain/invoice_printing_viewmodel.dart';

class PrinterPage extends StatefulWidget {
  void Function()? onPressedCheckbox;
  void Function(BuildContext, FutureOr<Uint8List> Function(PdfPageFormat),
      PdfPageFormat)? onPressedNext;
  PrinterPage({super.key, this.onPressedCheckbox, required this.onPressedNext});

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfPreviewAction(
        icon: GetBuilder<PrintingInvoiceController>(builder: (controller) {
          return Padding(
            padding: EdgeInsets.symmetric(
                vertical: controller.checkboxDisable ? 8.0 : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                controller.checkboxDisable
                    ? Container()
                    : InkWell(
                        onTap: widget.onPressedCheckbox,
                        child: Column(
                          children: [
                            Checkbox(
                              checkColor:
                                  controller.checkbox ? AppColor.purple : null,
                              fillColor: controller.checkbox
                                  ? WidgetStateProperty.all(AppColor.white)
                                  : null,
                              value: controller.checkbox,
                              side: BorderSide(
                                color: AppColor.white, // Border color
                                width: 2.0, // Border width
                              ),
                              onChanged: null,
                            ),
                            Text(
                              'A4',
                              style: TextStyle(
                                  fontSize: Get.width * 0.01,
                                  color: AppColor.white),
                            ),
                          ],
                        ),
                      ),
                ElevatedButton(
                  onPressed: () {
                    if (widget.onPressedNext != null) {
                      PdfPreviewAction pdfPreviewAction = PdfPreviewAction(
                        icon: Container(),
                        onPressed: widget.onPressedNext!,
                      );
                      pdfPreviewAction.pressed(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cyanTeal.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          5.0), // Set your desired radius here
                    ),
                  ),
                  child: Text(
                    'Download'.tr,
                    style: TextStyle(
                        color: AppColor.white,
                        fontSize: MediaQuery.of(context).size.width * 0.01),
                  ),
                )
              ],
            ),
          );
        }),
        onPressed: null);
  }
}
