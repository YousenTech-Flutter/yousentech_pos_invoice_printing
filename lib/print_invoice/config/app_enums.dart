enum PrintingType {
  is_silent_printing('Silent Printing'),
  disable_printing('Disable Printing'),
  is_show_printer_dialog('Show Printer Options Dialog');

  const PrintingType(this.text);
  final String text;

  @override
  String toString() => 'PrintingType($text)';
}
enum PrintingTypeSkip {
  skip_disable_customer_printing('skip Disable Customer Printing'),
  skip_disable_order_printing('skip Disable Order Printing');

  const PrintingTypeSkip(this.text);
  final String text;

  @override
  String toString() => 'PrintingType($text)';
}
