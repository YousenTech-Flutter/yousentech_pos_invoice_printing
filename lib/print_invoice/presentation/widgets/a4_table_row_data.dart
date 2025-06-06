// ignore_for_file: non_constant_identifier_names

import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_shared_preferences/models/sale_order_line.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/presentation/widgets/a4_data_row_cell.dart';

import '../../domain/invoice_printing_viewmodel.dart';

List<pw.TableRow> a4TableRowData() {
  PrintingInvoiceController printingController =
      Get.put(PrintingInvoiceController());
  return List.generate(printingController.saleOrderLinesList!.length, (index) {
    SaleOrderLine item = printingController.saleOrderLinesList![index];
    final intl.NumberFormat formatter = intl.NumberFormat('#,##0.00', 'en_US');
    return pw.TableRow(
      decoration: pw.BoxDecoration(
          color: (index + 1) % 2 == 0
              ? PdfColors.white
              : const PdfColor.fromInt(0xfff8f5f7)),
      children: [
        // a4dataRowCell(
        //   expanded: 2,
        //   text: formatter.format(item.totalPrice),
        // ),
        // a4dataRowCell(
        //   text: formatter.format(item.tax * item.priceUnit!).toString(),
        // ),
        // a4dataRowCell(
        //   text: formatter.format(item.subtotalPrice).toString(),
        // ),
        // a4dataRowCell(
        //   text: formatter.format(item.tax).toString(),
        // ),
        // a4dataRowCell(
        //   text: formatter.format(item.priceUnit).toString(),
        // ),
        // a4dataRowCell(
        //   text: formatter.format(item.productUomQty).toString(),
        // ),
        // a4dataRowCell(
        //   expanded: 4,
        //   text: item.name ?? '',
        // ),

        a4dataRowCell(
          expanded: 2,
          text: formatter.format(item.totalPrice),
        ),

        a4dataRowCell(
          text: formatter.format(item.tax),
        ),

        a4dataRowCell(
          text: formatter.format(item.subtotalPrice),
        ),
        if (printingController.saleOrderInvoice!.totalDiscount != 0) ...[
          // dataRowCell(
          //   text: formatter.format(item.subtotalPrice).toString(),
          // ),
          a4dataRowCell(
            text: formatter.format(item.discountAsPercentage).toString(),
          ),
          a4dataRowCell(
            text: formatter
                .format(item.quantityMultipliedByUnitPriceForSubtotalPrice)
                .toString(),
          ),
        ],
        a4dataRowCell(
          text: formatter.format(item.priceUnit).toString(),
        ),
        a4dataRowCell(
          text: formatter.format(item.productUomQty).toString(),
        ),
        a4dataRowCell(
          expanded: 4,
          text: item.name ?? '',
        ),
      ],
    );
  });
}
