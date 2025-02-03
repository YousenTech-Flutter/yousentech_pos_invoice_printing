import 'package:flutter/services.dart';
import 'package:get/get.dart';

bool printingWrapperKeyEventHandler(KeyEvent event) {
  if (event is KeyDownEvent) {
    handleGlobalKeyEvent(event);
  }
  return false;
}

bool handleGlobalKeyEvent(KeyEvent event) {
  // TODO :=====
  // PaymentController paymentController = Get.find<PaymentController>();
  // if (paymentController.isDialogOpen) {
  //   return false; // Ignore keyboard events while the dialog is open
  // }
  
  // if (event.logicalKey == LogicalKeyboardKey.enter) {
  //   paymentController.enterFocus(paymentController: paymentController);
  //   return true;
  // }


  return false;
}

bool _isNumberKey(KeyEvent event) {
  return (event.logicalKey.keyLabel.isNotEmpty &&
      (RegExp(r'^[0-9]$').hasMatch(event.logicalKey.keyLabel) ||
          event.logicalKey.keyLabel.contains('Numpad')));
}
