import 'dart:typed_data';

Uint8List resizeBuf(Uint8List buf, int size) {
  if (buf.length > size) {
    return buf.sublist(0, size);
  }

  var carr = Uint8List(size);
  carr.setAll(0, buf);
  return carr;
}

/*export function resize(arr: Array<any>, newSize: number, defaultValue: any) {
    return [...arr, ...Array(Math.max(newSize - arr.length, 0)).fill(defaultValue)];
}*/
List<T> resize<T>(List<T> arr, int newSize, dynamic defaultValue) {
  return [
    ...arr,
    ...List.filled(
        newSize - arr.length > 0 ? newSize - arr.length : 0, defaultValue)
  ];
}

List<T> resizeNumArr<T>(List<T> arr, int newSize) {
  for (var i = 0; i < newSize; i++) {
    arr[i] = [] as T;
  }
  return arr;
}

List<Uint8List> createArrayBuf(int arraySize, int fillSize) {
  List<Uint8List> ab = [];
  for (var i = 0; i < arraySize; i++) {
    ab[i] = Uint8List(fillSize);
  }
  return ab;
}
