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

List<T> resizeNumArr<T>(List<T> arr, int newSize, T fillval) {
  if (arr.length > newSize) {
    return arr.sublist(0, newSize);
  }

  List<T> nlist = [];
  for (var i = arr.length; i < newSize; i++) {
    //arr[i] = [] as T;
    nlist.add(fillval);
  }
  return arr + nlist;
}

List<Uint8List> createArrayBuf(int arraySize, int fillSize) {
  List<Uint8List> ab = List.empty(growable: true);
  for (var i = 0; i < arraySize; i++) {
    ab.add(Uint8List(fillSize));
  }
  return ab;
}
