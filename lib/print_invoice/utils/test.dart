import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ysn_pos_android_printer/android_printer/printer.dart';

class ScreenshotWidget extends StatefulWidget {
  final Widget child;
  final String? printerIp;
  const ScreenshotWidget(
      {required this.child, required this.printerIp, Key? key})
      : super(key: key);

  @override
  State<ScreenshotWidget> createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {

  ScreenshotController screenshotController = ScreenshotController();
  @override
  void initState() {
    super.initState();
    print("===============initState");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("WidgetsBinding.instance.addPostFrameCallback ===============");
      screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      ).then((image) async {
        print("=========image ${image!.length}");
        testPrint(imageThatC: image ,printerIp:widget.printerIp );
        
      }).catchError((onError) {
      });
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("===============Widget build");
    return Offstage(
      offstage: true,
      child: Screenshot(
        controller:screenshotController,
        child: SizedBox(width: 150.w, child: widget.child),
      ),
    );
  }
}
