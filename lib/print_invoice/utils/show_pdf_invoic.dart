import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/presentation/views/print_invoice.dart';
import 'package:yousentech_pos_payment/payment/domain/payment_viewmodel.dart';

import '../domain/invoice_printing_viewmodel.dart';


showPDFInvoice({required PaymentController paymentController,
    bool isFromPayment = false,
    bool isShowOnly = false}) {
  PrintingInvoiceController printingController =
      Get.put(PrintingInvoiceController());
  paymentController.isPDFDialogOpen = true;
  return Get.defaultDialog(
      cancel: IconButton(
          onPressed: () {
            if (isShowOnly) {
              Get.back();
            } else {
              paymentController.escapeFocus(frompayment: isFromPayment);
              paymentController.updateDisableUserInteraction(val: false);
            }
          },
          icon: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: AppColor.backgroundTable,
                borderRadius: BorderRadius.circular(5)),
            child: Icon(
              Icons.close,
              size: Get.width * 0.01,
            ),
          )),
      title: printingController.title.tr,
      barrierDismissible: false,
      content: SizedBox(
          height: Get.height * 0.6,
          width: Get.width * 0.3,
          child: PrinterInvoice(
            paymentController: paymentController,
            isFromPayment: isFromPayment,
          ))).then((_) {
    paymentController.isPDFDialogOpen = false;
    printingController.checkbox = false;
    printingController.isDefault = true;
    printingController.update();
  });
}
