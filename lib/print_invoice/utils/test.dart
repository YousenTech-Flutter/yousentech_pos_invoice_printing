// ignore_for_file: use_super_parameters

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:ysn_pos_android_printer/android_printer/printer.dart';

class ScreenshotWidget extends StatefulWidget {
  final Widget child;
  final String? printerIp;
  // ignore: prefer_const_constructors_in_immutables
  ScreenshotWidget({required this.child, required this.printerIp, Key? key})
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
    print("===============initState");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      print("WidgetsBinding.instance.addPostFrameCallback ===============");
      await screenshotController.capture()
      .then((image) async {
        print("=========image ${image!.length}");
        await testPrint(imageThatC: image, printerIp: widget.printerIp);
      }).whenComplete(() {
        print("=========whenComplete");
        Get.back(result: true);
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("===============Widget build");
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Receipt(
        builder: (context) => Screenshot(
          controller: screenshotController,
          child: SizedBox(
              width: 150.w, child: widget.child),
        ),
        onInitialized: (controller) {
          controller.paperSize = PaperSize.mm80;
          this.controller = controller;
        },
      ),
    );
  }
}
