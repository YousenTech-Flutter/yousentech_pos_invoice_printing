enum PrintingType {
  is_silent_printing('Silent Printing'),
  disable_printing('Disable Printing'),
  is_show_printer_dialog('Show Printer Options Dialog');

  const PrintingType(this.text);
  final String text;

  @override
  String toString() => 'PrintingType($text)';
}
