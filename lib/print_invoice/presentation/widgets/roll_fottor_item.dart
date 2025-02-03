import 'package:pdf/widgets.dart' as pw;

pw.Padding rollfotterItem(
    {required text, required font, double? padding, isHeader = false}) {
  return pw.Padding(
      padding: pw.EdgeInsets.all(padding ?? 4),
      child: pw.Text(
        text,

        // snapshot.data[index]['Prodect_name'].toString(),
        style: pw.TextStyle(font: font, fontSize: 14),
      ));
}
