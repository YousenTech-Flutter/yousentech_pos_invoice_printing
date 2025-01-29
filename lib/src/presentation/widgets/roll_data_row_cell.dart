import 'package:pdf/widgets.dart' as pw;

pw.Padding rolldataRowCell(
    {required text,
    required font,
    double? padding,
    isDescrebtion = false,
    isHeader = false}) {
  return pw.Padding(
      padding: pw.EdgeInsets.all(padding ?? 8.0),
      child: pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            text,
            textDirection: isDescrebtion ? pw.TextDirection.rtl : null,
            // snapshot.data[index]['Prodect_name'].toString(),
            style: pw.TextStyle(font: font, fontSize: isHeader ? 16 : 14),
          )));
}
