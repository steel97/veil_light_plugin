// ignore_for_file: constant_identifier_names

enum OutputTypes {
  OUTPUT_NULL(0), // marker for CCoinsView (0.14)
  OUTPUT_STANDARD(1),
  OUTPUT_CT(2),
  OUTPUT_RINGCT(3),
  OUTPUT_DATA(4);

  const OutputTypes(this.value);
  final int value;
}
