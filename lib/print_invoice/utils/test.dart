import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:ysn_pos_android_printer/android_printer/printer.dart';

class ScreenshotWidget extends StatefulWidget {
  final Widget child;
  final String? printerIp;
  const ScreenshotWidget({required this.child,required this.printerIp,  Key? key}) : super(key: key);

  @override
  State<ScreenshotWidget> createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {
  final GlobalKey _repaintKey = GlobalKey();

  Future<Uint8List?> capturePng() async {
    try {
      RenderRepaintBoundary? boundary =
          _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print("repaintBoundary is null");
        return null;
      }

      if (boundary.debugNeedsPaint) {
        print("Boundary still needs paint!");
        await Future.delayed(const Duration(milliseconds: 20));
        return capturePng(); // حاول مجدد بعد تأخير بسيط
      }

      final image = await boundary.toImage(pixelRatio: 3);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing image: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Uint8List? imageBytes = await capturePng();
      if (imageBytes != null) {
        // هنا تستخدم الصورة حسب حاجتك
        print("Image captured, length = ${imageBytes.length}");
        testPrint(imageThatC: imageBytes, printerIp: widget.printerIp);
      } else {
        print("Failed to capture image.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: true,
      child: RepaintBoundary(
        key: _repaintKey,
        child: Directionality(
          textDirection: SharedPr.lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
          child: widget.child,
        ),
      ),
    );
  }
}
