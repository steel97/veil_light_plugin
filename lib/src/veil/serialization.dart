// ignore_for_file: constant_identifier_names

enum SerializationType {
  // primary actions
  SER_NETWORK(1 << 0),
  SER_DISK(1 << 1),
  SER_GETHASH(1 << 2);

  const SerializationType(this.value);
  final int value;
}
