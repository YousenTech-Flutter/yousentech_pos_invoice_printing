// ignore_for_file: use_super_parameters
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:ysn_pos_android_printer/android_printer/printer.dart';

class ScreenshotWidget extends StatefulWidget {
  final Widget child;
  final String? printerIp;
  final bool isChasherInvoice;
  // ignore: prefer_const_constructors_in_immutables
  ScreenshotWidget({required this.child, required this.printerIp, this.isChasherInvoice =false ,Key? key})
      : super(key: key);

  @override
  State<ScreenshotWidget> createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {
  ScreenshotController screenshotController = ScreenshotController();
  ReceiptController? controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      await screenshotController.capture(pixelRatio: 1.0)
      .then((image) async {
        await PrinterTypes.printer(imageThatC: image!, printerIp: widget.printerIp ,isChasherInvoice: widget.isChasherInvoice );
      }).whenComplete(() {
        Get.back(result: true);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Receipt(
        builder: (context) => Screenshot(
          controller: screenshotController,
          child: Center(
            child: SizedBox(
              width: PaperSize.mm80.width.toDouble(),
              child: widget.child),
          ),
        ),
        onInitialized: (controller) {
          controller.paperSize = PaperSize.mm80;
          this.controller = controller;
        },
      ),
    );
  }
}
