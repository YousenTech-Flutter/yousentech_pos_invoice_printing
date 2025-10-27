// ignore_for_file: use_super_parameters
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
      var image = await captureWidgetToImage(widget.child);
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

Future<Uint8List?> captureWidgetToImage(Widget widget,
    {double pixelRatio = 2}) async {
  final RenderRepaintBoundary boundary = RenderRepaintBoundary();

  final RenderView renderView = RenderView(
    view: WidgetsBinding.instance.platformDispatcher.views.first,
    child: RenderPositionedBox(
      alignment: Alignment.center,
      child: boundary,
    ),
    configuration: ViewConfiguration(
      physicalConstraints:
          BoxConstraints(maxWidth: PaperSize.mm80.width.toDouble()),
      logicalConstraints:
          BoxConstraints(maxWidth: PaperSize.mm80.width.toDouble()),
      // size: const Size(800, 1200), // 👈 حجم الـ widget اللي تبغى تصوره
      devicePixelRatio: pixelRatio,
    ),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

  final renderElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: boundary,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: widget,
    ),
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(renderElement);
  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}
