// ignore_for_file: use_super_parameters
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/domain/invoice_printing_viewmodel.dart';
import 'package:ysn_pos_android_printer/android_printer/printer.dart';
import 'dart:ui' as ui;

class ScreenshotWidget extends StatefulWidget {
  final Widget child;
  final String? printerIp;
  final bool isChasherInvoice;
  // ignore: prefer_const_constructors_in_immutables
  ScreenshotWidget(
      {required this.child,
      required this.printerIp,
      this.isChasherInvoice = false,
      Key? key})
      : super(key: key);

  @override
  State<ScreenshotWidget> createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {
  ScreenshotController screenshotController = ScreenshotController();
  PrintingInvoiceController printingController =
      Get.put(PrintingInvoiceController());
  ReceiptController? controller;
  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await Future.delayed(Duration.zero);
    //   await Future.delayed(Duration.zero);
    //   await screenshotController.capture(
    //     pixelRatio: 2,
    //   //   Material(
    //   //   child: Directionality(
    //   // textDirection:SharedPr.lang=='ar'?TextDirection.rtl: TextDirection.ltr,
    //   //     child: SizedBox(
    //   //       width: PaperSize.mm80.width.toDouble(),
    //   //       child: widget.child,
    //   //     ),
    //   //   ),
    //   // )
    //   )
    //   .then((image) async {
    //     await PrinterTypes.printer(imageThatC: image!, printerIp: widget.printerIp ,isChasherInvoice: widget.isChasherInvoice);
    //   }).whenComplete(() {
    //     Get.back(result: true);
    //   });
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      var image = await captureWidgetToImage(context, widget.child);
      await PrinterTypes.printer(
          imageThatC: image!,
          printerIp: widget.printerIp,
          isChasherInvoice: widget.isChasherInvoice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(backgroundColor: AppColor.white, body: Container()
          // SingleChildScrollView(
          //   child: Center(
          //     child: Screenshot(
          //       controller: screenshotController,
          //       child: SizedBox(
          //         width: PaperSize.mm80.width.toDouble(),
          //         child: widget.child,
          //       ),
          //     ),
          //   ),
          // ),
          ),
    );
  }
}

// Future<Uint8List?> captureWidgetToImage(Widget widget,
//     {double pixelRatio = 2}) async {
//   final RenderRepaintBoundary boundary = RenderRepaintBoundary();

//   final RenderView renderView = RenderView(
//     view: WidgetsBinding.instance.platformDispatcher.views.first,
//     child: RenderPositionedBox(
//       alignment: Alignment.center,
//       child: boundary,
//     ),
//     configuration: ViewConfiguration(
//       physicalConstraints:
//           BoxConstraints(maxWidth: PaperSize.mm80.width.toDouble()),
//       logicalConstraints:
//           BoxConstraints(maxWidth: PaperSize.mm80.width.toDouble()),
//       // size: const Size(800, 1200), // 👈 حجم الـ widget اللي تبغى تصوره
//       devicePixelRatio: pixelRatio,
//     ),
//   );

//   final PipelineOwner pipelineOwner = PipelineOwner();
//   final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

//   final renderElement = RenderObjectToWidgetAdapter<RenderBox>(
//     container: boundary,
//     child: Directionality(
//       textDirection: TextDirection.ltr,
//       child: widget,
//     ),
//   ).attachToRenderTree(buildOwner);

//   buildOwner.buildScope(renderElement);
//   pipelineOwner.flushLayout();
//   pipelineOwner.flushCompositingBits();
//   pipelineOwner.flushPaint();
//   await Future.microtask(() {});
//   await Future.delayed(Duration(milliseconds: 50));
//   final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
//   final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//   return byteData?.buffer.asUint8List();
// }






Future<Uint8List?> captureWidgetToImage(
  BuildContext context,
  Widget widget, {
  double pixelRatio = 2.0,
}) async {
  final repaintKey = GlobalKey();
  final overlay = Overlay.of(context);
  final completer = Completer<ui.Image>();

  final overlayEntry = OverlayEntry(
    builder: (_) => Offstage(
      offstage: true,
      child: RepaintBoundary(
        key: repaintKey,
        child: Material(child: widget),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  try {
    // 🧠 انتظر حتى Flutter يخلص من رسم الفريم الحالي بالكامل
    await WidgetsBinding.instance.endOfFrame;

    // 🔄 ننتظر فريم إضافي علشان نضمن اكتمال الرسم فعليًا
    await Future.delayed(const Duration(milliseconds: 60));

    final boundary = repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (boundary == null) {
      throw Exception('Boundary not found');
    }

    // 🔄 تأكد أنه جاهز فعلاً (بعض الأجهزة تحتاج وقت إضافي بسيط)
    int attempts = 0;
    while (boundary.debugNeedsPaint && attempts < 5) {
      await Future.delayed(const Duration(milliseconds: 30));
      attempts++;
    }

    // if (boundary.debugNeedsPaint) {
    //   throw Exception('Widget not painted yet after waiting');
    // }
    print("🎨 ready to capture: ${!boundary.debugNeedsPaint}");

    // 🖼️ نلتقط الصورة
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    completer.complete(image);
  } catch (e, st) {
    completer.completeError(e, st);
  } finally {
    overlayEntry.remove();
  }

  final uiImage = await completer.future;
  final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}



