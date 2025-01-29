import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pos_desktop/features/payment/domain/payment_viewmodel.dart';

bool printingWrapperKeyEventHandler(KeyEvent event) {
  if (event is KeyDownEvent) {
    handleGlobalKeyEvent(event);
  }
  return false;
}

bool handleGlobalKeyEvent(KeyEvent event) {
  // print('=============paymentScreenWrapperKeyEventHandler==============');
  PaymentController paymentController = Get.find<PaymentController>();
  if (paymentController.isDialogOpen) {
    return false; // Ignore keyboard events while the dialog is open
  }
  //==============stop==================
  // if (event.logicalKey == LogicalKeyboardKey.f1) {
  //   paymentController.focusFirstSummeryCard();
  //   return true;
  // } else if (event.logicalKey == LogicalKeyboardKey.f2) {
  //   print("========================F22===============");
  //   // paymentController.focusPaymentMethodSection();
  //   return true;
  // } else if (event.logicalKey == LogicalKeyboardKey.f3) {
  //   print("========================F33===============");
  //   paymentController.focusKeyPad();
  //   return true;
  // }
  //==============stop==================

  // if (event.logicalKey == LogicalKeyboardKey.escape) {
  //   if (kDebugMode) {
  //     print("bacccccccccccccccccccccccccccccccccck");
  //   }
  //   // Navigate back when Esc is pressed
  //   Get.back();
  // }else

  // if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
  //   if (SharedPr.lang == 'en') {
  //     paymentController.focusFirstSummeryCard();
  //   } else {
  //     paymentController.focusPaymentMethodSection(paymentSummaryIndex: 0);
  //   }

  //   return true;
  // } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
  //   if (SharedPr.lang == 'en') {
  //     paymentController.focusPaymentMethodSection(paymentSummaryIndex: 0);
  //   } else {
  //     paymentController.focusFirstSummeryCard();
  //   }

  //   return true;
  // } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
  //   if (paymentController.paymentSummaryFocus.hasFocus) {
  //     paymentController.paymentSummaryMoveSelection();
  //     return true;
  //   }
  //   paymentController.moveUpInSummeryCardList();
  // } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
  //   if (paymentController.paymentSummaryFocus.hasFocus) {
  //     paymentController.paymentSummaryMoveSelection(down: true);
  //     return true;
  //   }
  //   // paymentController.arrowMoveInSummeryCardList(down: true);
  //   paymentController.moveDownInSummeryCardList();
  //   return true;
  // } else if (_isNumberKey(event)) {
  //   if (paymentController.paymentSummaryFocus.hasFocus) {
  //     return true;
  //   }
  //   if (paymentController.keypadFocus.hasFocus) {
  //     paymentController.selectionKeyPad(key: event.logicalKey.keyLabel);
  //   } else {
  //     bool anyFocused = paymentController.checkIfAnyOfSummeryCardFocused();
  //     if (anyFocused) {
  //     } else {
  //       paymentController.focusFirstSummeryCard();
  //     }
  //   }

  //   return true;
  // } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
  //   // if (paymentController.keypadFocus.hasFocus) {
  //   //   paymentController.selectionKeyPad(key: event.logicalKey.keyLabel);
  //   //   return true;
  //   // }
  //   print("backspace========");
  //   // paymentController.deleteORbackspaceFocusSummeryCard(isBackspace: true);
  //   return true;
  // } else if (event.logicalKey == LogicalKeyboardKey.delete) {
  //   if (paymentController.keypadFocus.hasFocus) {
  //     paymentController.selectionKeyPad(key: event.logicalKey.keyLabel);
  //     return true;
  //   }
  //   paymentController.deleteORbackspaceFocusSummeryCard();
  //   return true;
  // } else
  if (event.logicalKey == LogicalKeyboardKey.enter) {
    // print("========================Enter===============");
    paymentController.enterFocus(paymentController: paymentController);
    return true;
  }
  // } else if (event.logicalKey == LogicalKeyboardKey.escape) {
  //   // print("========================Escape===============");
  //   paymentController.escapeFocus();
  // } else if (event.logicalKey == LogicalKeyboardKey.tab) {
  //   // print("========================tab===============");
  //   // paymentController.tabFocus();
  // }

  return false;
}

bool _isNumberKey(KeyEvent event) {
  return (event.logicalKey.keyLabel.isNotEmpty &&
      (RegExp(r'^[0-9]$').hasMatch(event.logicalKey.keyLabel) ||
          event.logicalKey.keyLabel.contains('Numpad')));
}
