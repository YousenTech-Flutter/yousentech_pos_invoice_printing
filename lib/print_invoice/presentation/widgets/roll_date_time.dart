import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Row dateTime({titleDate, titleTime, orderDate, font}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        // "$titleDate :${orderDate.toString().substring(0, 10)}",
        "$titleDate :${!orderDate.toString().contains('T') ? orderDate.toString() : orderDate.toString().substring(0,orderDate!.indexOf('T'))}",
        style: pw.TextStyle(font: font, fontSize: 14),
      ),
      pw.Text(
        
        // "$titleTime :${orderDate.toString().substring(11, 19)}",
        "$titleTime :${!orderDate.toString().contains('T') ? DateFormat("HH:mm:ss").format(DateTime.now()) : orderDate.toString().substring(orderDate!.indexOf('T')+1)}",
        style: pw.TextStyle(font: font, fontSize: 14),
      ),
    ],
  );
}
