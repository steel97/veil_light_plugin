import 'dart:async';
import 'dart:ffi';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

const String _libName = 'veil_light_plugin';
const int PUBLIC_KEY_COMPRESSED_SIZE = 33;
const int PUBLIC_KEY_UNCOMPRESSED_SIZE = 65;
const int PRIVATE_KEY_SIZE = 32;
const int WTF_BIG_SIZE_ARRAY = 1048576;

/// The dynamic library in which the symbols for [VeilLightPluginBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
//final VeilLightPluginBindings _bindings = VeilLightPluginBindings(_dylib);
var _lookup = _dylib.lookup;

void copyArray(Uint8List original, Pointer<Uint8> ptr, {int index = 0}) {
  for (int i = index; i < original.lengthInBytes; i++) {
    ptr[i] = original[i - index];
  }
}

void setZeros(Pointer<Uint8> ptr, int size) {
  for (int i = 0; i < size; i++) {
    ptr[i] = 0;
  }
}

Uint8List getArray(Pointer<Uint8> ptr, int start, int end) {
  var res = Uint8List(end - start);
  for (int i = start; i < end; i++) {
    res[i - start] = ptr[i];
  }
  return res;
}

//ffi.Pointer<ffi.Int32> myTestIntgr = _lookup<ffi.Int32>('MYTEST_INTGR');
//ffi.Pointer<ffi.Uint8> myTestArray = _lookup<ffi.Uint8>('MYTEST_ARRAY');
ffi.Pointer<ffi.Uint8> pkInputPtr = _lookup<ffi.Uint8>('PK_INPUT');
const int pkInputSize = PUBLIC_KEY_COMPRESSED_SIZE;

ffi.Pointer<ffi.Uint8> skInputPtr = _lookup<ffi.Uint8>('SK_INPUT');
const int skInputSize = PUBLIC_KEY_COMPRESSED_SIZE;

ffi.Pointer<ffi.Uint8> kiOutputPtr = _lookup<ffi.Uint8>('KI_OUTPUT');
const int kiOutputSize = PUBLIC_KEY_COMPRESSED_SIZE;

ffi.Pointer<ffi.Uint8> publicKeyInputPtr =
    _lookup<ffi.Uint8>('PUBLIC_KEY_INPUT');
const int publicKeyInputSize = PUBLIC_KEY_UNCOMPRESSED_SIZE;

ffi.Pointer<ffi.Uint8> privateKeyInputPtr =
    _lookup<ffi.Uint8>('PRIVATE_KEY_INPUT');
const int privateKeyInputSize = PRIVATE_KEY_SIZE;

ffi.Pointer<ffi.Uint8> nonceOutputPtr = _lookup<ffi.Uint8>('NONCE_OUTPUT');
const int nonceOutputSize = 32;

ffi.Pointer<ffi.Uint8> messageOutputPtr = _lookup<ffi.Uint8>('MESSAGE_OUTPUT');
const int messageOutputSize = 256;

ffi.Pointer<ffi.Uint8> commitPtr = _lookup<ffi.Uint8>('COMMIT');
const int commitSize = 33;

ffi.Pointer<ffi.Uint8> proofPtr = _lookup<ffi.Uint8>('PROOF');
const int proofSize = 40960;

ffi.Pointer<ffi.Uint8> proofResultPtr = _lookup<ffi.Uint8>('PROOFRESULT');
const int proofResultSize = 40;

ffi.Pointer<ffi.Uint8> blindOutputPtr = _lookup<ffi.Uint8>('BLIND_OUTPUT');
const int blindOutputSize = 32;

ffi.Pointer<ffi.Uint8> tweakInputPtr = _lookup<ffi.Uint8>('TWEAK_INPUT');
const int tweakInputSize = 32;

ffi.Pointer<ffi.Uint8> mInputPtr = _lookup<ffi.Uint8>('M_INPUT');
const int mInputSize = WTF_BIG_SIZE_ARRAY;

ffi.Pointer<ffi.Uint8> pcmInPtr = _lookup<ffi.Uint8>('PCM_IN');
const int pcmInSize = WTF_BIG_SIZE_ARRAY;

ffi.Pointer<ffi.Uint8> pcmOutPtr = _lookup<ffi.Uint8>('PCM_OUT');
const int pcmOutSize = WTF_BIG_SIZE_ARRAY;

ffi.Pointer<ffi.Uint8> blindsPtr = _lookup<ffi.Uint8>('BLINDS');
const int blindsSize = WTF_BIG_SIZE_ARRAY;

ffi.Pointer<ffi.Uint8> kiBigOutputPtr = _lookup<ffi.Uint8>('KI_BIG_OUTPUT');
const int kiBigOutputSize = WTF_BIG_SIZE_ARRAY;

ffi.Pointer<ffi.Uint8> pcOutputPtr = _lookup<ffi.Uint8>('PC_OUTPUT');
const int pcOutputSize = WTF_BIG_SIZE_ARRAY;

ffi.Pointer<ffi.Uint8> psOutputPtr = _lookup<ffi.Uint8>('PS_OUTPUT');
const int psOutputSize = WTF_BIG_SIZE_ARRAY;

ffi.Pointer<ffi.Uint8> preimageInputPtr = _lookup<ffi.Uint8>('PREIMAGE_INPUT');
const int preimageInputSize = 32;

ffi.Pointer<ffi.Uint8> pksInputPtr = _lookup<ffi.Uint8>('PKS_INPUT');
const int pksInputSize = WTF_BIG_SIZE_ARRAY;

ffi.Pointer<ffi.Uint8> sksInputPtr = _lookup<ffi.Uint8>('SKS_INPUT');
const int sksInputSize = WTF_BIG_SIZE_ARRAY;

// helpers functions
int assumeCompression(bool? compressed, Uint8List? p) {
  if (compressed == null) {
    return p != null ? p.length : PUBLIC_KEY_COMPRESSED_SIZE;
  }
  return compressed ? PUBLIC_KEY_COMPRESSED_SIZE : PUBLIC_KEY_UNCOMPRESSED_SIZE;
}

/*var _is_pointPtr =
    _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.IntPtr)>>('isPoint');
var _is_point = _is_pointPtr.asFunction<int Function(int)>();
int is_point(int inputlen) => _is_point(inputlen);*/

// getKeyImage
//Uint8List?
/*int getKeyImage(Uint8List pk, Uint8List sk) {
  var outputlen = pk.length;
  var inputlen = pk.length;
  var inputlensk = sk.length;

  return using((Arena arena) {
    var pkPtr = arena.allocate<Uint8>(PUBLIC_KEY_COMPRESSED_SIZE);
    var skPtr = arena.allocate<Uint8>(PUBLIC_KEY_COMPRESSED_SIZE);
    var kiOutPtr = arena.allocate<Uint8>(PUBLIC_KEY_COMPRESSED_SIZE);

    copyArray(pk, pkPtr);
    copyArray(sk, skPtr);

    //const res = wasm.getKeyImage(outputlen, inputlen, inputlensk);

    /*return (res == 0 || res == 3)
        ? KI_OUTPUT.slice(0, validate.PUBLIC_KEY_COMPRESSED_SIZE)
        : null;*/
    return myTestArray[1];
  });
}*/

// INITIALIZE START
var _initializeContextPtr =
    _lookup<ffi.NativeFunction<ffi.Void Function()>>('initializeContext');
var _initializeContext = _initializeContextPtr.asFunction<void Function()>();
void initializeContext() {
  _initializeContext();
}
// INITIALIZE END

// GET KEY IMAGE START
var _getKeyImagePtr = _lookup<
        ffi.NativeFunction<ffi.Int32 Function(ffi.Size, ffi.Size, ffi.Size)>>(
    'getKeyImage');
var _getKeyImage = _getKeyImagePtr.asFunction<int Function(int, int, int)>();

Uint8List? getKeyImage(Uint8List pk, Uint8List sk) {
  try {
    var outputlen = pk.length;
    var inputlen = pk.length;
    var inputlensk = sk.length;

    copyArray(pk, pkInputPtr);
    copyArray(sk, skInputPtr);
    var res = _getKeyImage(outputlen, inputlen, inputlensk);
    return (res == 0 || res == 3)
        ? getArray(kiOutputPtr, 0, PUBLIC_KEY_COMPRESSED_SIZE)
        : null;
  } finally {
    setZeros(kiOutputPtr, kiOutputSize);
    setZeros(pkInputPtr, pkInputSize);
    setZeros(skInputPtr, skInputSize);
  }
}
// GET KEY IMAGE END

// ECDH_VEIL START
var _ECDH_VEILPtr =
    _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Size)>>('ECDH_VEIL');
var _ECDH_VEIL = _ECDH_VEILPtr.asFunction<int Function(int)>();

Uint8List? ECDH_VEIL(Uint8List publicKey, Uint8List privateKey) {
  try {
    copyArray(publicKey, publicKeyInputPtr);
    copyArray(privateKey, privateKeyInputPtr);
    var res = _ECDH_VEIL(publicKey.length);
    return res == 0
        ? getArray(nonceOutputPtr, 0, 32)
        : getArray(
            nonceOutputPtr, 0, 32); // TO-DO validation, return null if error
  } finally {
    setZeros(publicKeyInputPtr, publicKeyInputSize);
    setZeros(privateKeyInputPtr, privateKeyInputSize);
    setZeros(nonceOutputPtr, nonceOutputSize);
  }
}
// ECDH_VEIL END

// rangeProofRewind START
var _rangeProofRewindPtr =
    _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Size, ffi.Size)>>(
        'rangeProofRewind');
var _rangeProofRewind =
    _rangeProofRewindPtr.asFunction<int Function(int, int)>();

class RangeProofRewindResult {
  final Uint8List blindOut;
  final Uint8List messageOut;
  final BigInt value;
  final BigInt minValue;
  final BigInt maxValue;

  RangeProofRewindResult(
      {required this.blindOut,
      required this.messageOut,
      required this.value,
      required this.minValue,
      required this.maxValue});
}

RangeProofRewindResult? rangeProofRewind(
    Uint8List nonce, Uint8List commitment, Uint8List rangeproof) {
  try {
    var outLen = 256;

    copyArray(nonce, nonceOutputPtr);
    setZeros(messageOutputPtr, messageOutputSize);
    copyArray(commitment, commitPtr);
    copyArray(rangeproof, proofPtr);

    var proofLen = rangeproof.lengthInBytes;

    var res = _rangeProofRewind(outLen, proofLen);
    //console.log(PROOFRESULT.slice(0, 40));
    var dv = getArray(proofResultPtr, 0, 40).buffer.asByteData();
    return res == 1
        ? RangeProofRewindResult(
            blindOut: getArray(blindOutputPtr, 0, 32),
            value: BigInt.from(dv.getUint64(0, Endian.little)),
            minValue: BigInt.from(dv.getUint64(16, Endian.little)),
            maxValue: BigInt.from(dv.getUint64(24, Endian.little)),
            messageOut: getArray(
                messageOutputPtr,
                0,
                int.parse(
                    BigInt.from(dv.getUint64(32, Endian.little)).toString())))
        : null;
  } finally {
    setZeros(proofResultPtr, proofResultSize);
    setZeros(blindOutputPtr, blindOutputSize);
    setZeros(messageOutputPtr, messageOutputSize);
    setZeros(nonceOutputPtr, nonceOutputSize);
    setZeros(commitPtr, commitSize);
    setZeros(proofPtr, proofSize);
  }
}
// rangeProofRewind END

// pointMultiply START
var _pointMultiplyPtr =
    _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Size, ffi.Size)>>(
        'pointMultiply');
var _pointMultiply = _pointMultiplyPtr.asFunction<int Function(int, int)>();

Uint8List? pointMultiply(Uint8List p, Uint8List tweak,
    {bool compressed = false}) {
  // TO-DO validate
  //validate.validatePoint(p);
  //validate.validateTweak(tweak);
  var outputlen = assumeCompression(compressed, p);
  try {
    copyArray(p, publicKeyInputPtr);
    copyArray(tweak, tweakInputPtr);

    return _pointMultiply(p.length, outputlen) == 1
        ? getArray(publicKeyInputPtr, 0, outputlen)
        : null;
  } finally {
    setZeros(publicKeyInputPtr, publicKeyInputSize);
    setZeros(tweakInputPtr, tweakInputSize);
  }
}
// pointMultiply END

// pointAddScalar START
var _pointAddScalarPtr =
    _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Size, ffi.Size)>>(
        'pointAddScalar');
var _pointAddScalar = _pointAddScalarPtr.asFunction<int Function(int, int)>();

Uint8List? pointAddScalar(Uint8List p, Uint8List tweak,
    {bool compressed = false}) {
  // TO-DO validate
  //validate.validatePoint(p);
  //validate.validateTweak(tweak);
  var outputlen = assumeCompression(compressed, p);
  try {
    copyArray(p, publicKeyInputPtr);
    copyArray(tweak, tweakInputPtr);
    return _pointAddScalar(p.length, outputlen) == 1
        ? getArray(publicKeyInputPtr, 0, outputlen)
        : null;
  } finally {
    setZeros(publicKeyInputPtr, publicKeyInputSize);
    setZeros(tweakInputPtr, tweakInputSize);
  }
}
// pointAddScalar END

// privateAdd START
var _privateAddPtr =
    _lookup<ffi.NativeFunction<ffi.Int32 Function()>>('privateAdd');
var _privateAdd = _privateAddPtr.asFunction<int Function()>();

Uint8List? privateAdd(Uint8List d, Uint8List tweak) {
  // TO-DO
  //validate.validatePrivate(d);
  //validate.validateTweak(tweak);

  try {
    copyArray(d, privateKeyInputPtr);
    copyArray(tweak, tweakInputPtr);
    return _privateAdd() == 1
        ? getArray(privateKeyInputPtr, 0, PRIVATE_KEY_SIZE)
        : null;
  } finally {
    setZeros(privateKeyInputPtr, privateKeyInputSize);
    setZeros(tweakInputPtr, tweakInputSize);
  }
}
// privateAdd END

// pedersenCommit START
var _pedersenCommitPtr =
    _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Uint64)>>(
        'pedersenCommit');
var _pedersenCommit = _pedersenCommitPtr.asFunction<int Function(int)>();

class PedersenCommitResult {
  final Uint8List blind;
  final Uint8List commitment;

  PedersenCommitResult({required this.blind, required this.commitment});
}

PedersenCommitResult? pedersenCommit(
    Uint8List commitment, Uint8List blind_output, BigInt value) {
  try {
    copyArray(blind_output, blindOutputPtr);
    copyArray(commitment, commitPtr);

    var res = _pedersenCommit(value.toInt());

    if (res == 1) {
      var out = PedersenCommitResult(
          blind: getArray(blindOutputPtr, 0, 32),
          commitment: getArray(commitPtr, 0, 33));
      return out;
    } else {
      return null;
    }
  } finally {
    setZeros(blindOutputPtr, blindOutputSize);
    setZeros(commitPtr, commitSize);
  }
}
// pedersenCommit END

// rangeproofSign START

var _rangeproofSignPtr = _lookup<
    ffi.NativeFunction<
        ffi.Int32 Function(ffi.Uint32, ffi.Uint64, ffi.Int32, ffi.Int32,
            ffi.Uint64, ffi.Size)>>('rangeproofSign');
var _rangeproofSign =
    _rangeproofSignPtr.asFunction<int Function(int, int, int, int, int, int)>();

class RangeProofSignResult {
  final Uint8List proof;
  final int proof_len;
  final Uint8List commit;
  final Uint8List blind_output;
  final Uint8List nonce_output;
  final Uint8List message_output;

  RangeProofSignResult(
      {required this.proof,
      required this.proof_len,
      required this.commit,
      required this.blind_output,
      required this.nonce_output,
      required this.message_output});
}

RangeProofSignResult? rangeproofSign(
    Uint8List proof,
    int plen,
    BigInt min_value,
    Uint8List commitment,
    Uint8List blind,
    Uint8List nonce,
    int exp,
    int min_bits,
    BigInt value,
    Uint8List message,
    int msg_len) {
  try {
    copyArray(proof, proofPtr);
    copyArray(commitment, commitPtr);
    copyArray(blind, blindOutputPtr);
    copyArray(nonce, nonceOutputPtr);
    copyArray(message, messageOutputPtr);

    var res = _rangeproofSign(
        plen, min_value.toInt(), exp, min_bits, value.toInt(), msg_len);

    if (res == 1) {
      var dv = getArray(privateKeyInputPtr, 0, 4).buffer.asByteData();
      var nplen = dv.getUint32(0, Endian.little);
      var out = RangeProofSignResult(
          proof: getArray(proofPtr, 0, nplen),
          proof_len: nplen,
          commit: getArray(commitPtr, 0, 33),
          blind_output: getArray(blindOutputPtr, 0, 32),
          nonce_output: getArray(nonceOutputPtr, 0, 32),
          message_output: getArray(messageOutputPtr, 0, msg_len));
      return out;
    } else {
      return null;
    }
  } finally {
    setZeros(proofPtr, proofSize);
    setZeros(commitPtr, commitSize);
    setZeros(blindOutputPtr, blindOutputSize);
    setZeros(nonceOutputPtr, nonceOutputSize);
    setZeros(messageOutputPtr, messageOutputSize);
  }
}
// rangeproofSign END

// rangeProofVerify START
var _rangeProofVerifyPtr =
    _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Size, ffi.Size)>>(
        'rangeProofVerify');
var _rangeProofVerify =
    _rangeProofVerifyPtr.asFunction<int Function(int, int)>();

int rangeProofVerify(Uint8List commitment, Uint8List rangeproof) {
  try {
    var outLen = 256;
    setZeros(messageOutputPtr, messageOutputSize);
    copyArray(commitment, commitPtr);
    copyArray(rangeproof, proofPtr);

    var proofLen = rangeproof.lengthInBytes;
    var res = _rangeProofVerify(outLen, proofLen);

    return res;
  } finally {
    setZeros(proofResultPtr, proofResultSize);
    setZeros(blindOutputPtr, blindOutputSize);
    setZeros(messageOutputPtr, messageOutputSize);
    setZeros(nonceOutputPtr, nonceOutputSize);
    setZeros(commitPtr, commitSize);
    setZeros(proofPtr, proofSize);
  }
}
// rangeProofVerify END

// prepareMlsag START
var _prepareMlsagPtr = _lookup<
    ffi.NativeFunction<
        ffi.Int32 Function(ffi.Size, ffi.Size, ffi.Size, ffi.Size, ffi.Size,
            ffi.Size)>>('prepareMlsag');
var _prepareMlsag =
    _prepareMlsagPtr.asFunction<int Function(int, int, int, int, int, int)>();

class PrepareMlsagResult {
  final Uint8List M;
  final Uint8List SK;

  PrepareMlsagResult({required this.M, required this.SK});
}

PrepareMlsagResult? prepareMlsag(
    Uint8List m_input,
    Uint8List sk_input,
    int nOuts,
    int nBlinded,
    int vpInCommitsLen,
    int vpBlindsLen,
    int nCols,
    int nRows,
    List<Uint8List> vpInCommits,
    List<Uint8List> vpOutCommits,
    List<Uint8List> vpBlinds) {
  try {
    copyArray(m_input, mInputPtr);
    copyArray(sk_input, skInputPtr);

    setZeros(pcmInPtr, pcmInSize);
    int index = 0;
    for (var local in vpInCommits) {
      copyArray(local, pcmInPtr, index: index);
      index += local.length;
    }

    setZeros(pcmOutPtr, pcmOutSize);
    index = 0;
    for (var local in vpOutCommits) {
      copyArray(local, pcmOutPtr, index: index);
      index += local.length;
    }

    setZeros(blindsPtr, blindsSize);
    index = 0;
    for (var local in vpBlinds) {
      copyArray(local, blindsPtr, index: index);
      index += local.length;
    }

    //blinds_size = n?
    var res = _prepareMlsag(
        nOuts, nBlinded, vpInCommitsLen, vpBlindsLen, nCols, nRows);

    if (res == 0) {
      return PrepareMlsagResult(
          M: getArray(mInputPtr, 0, m_input.length),
          SK: getArray(skInputPtr, 0, sk_input.length));
    } else {
      return null;
    }
  } finally {
    setZeros(mInputPtr, mInputSize);
    setZeros(skInputPtr, skInputSize);
    setZeros(pcmInPtr, pcmInSize);
    setZeros(pcmOutPtr, pcmOutSize);
    setZeros(blindsPtr, blindsSize);
  }
}
// prepareMlsag END

// pedersenBlindSum START
var _pedersenBlindSumPtr = _lookup<
        ffi.NativeFunction<ffi.Int32 Function(ffi.Size, ffi.Size, ffi.Size)>>(
    'pedersenBlindSum');
var _pedersenBlindSum =
    _pedersenBlindSumPtr.asFunction<int Function(int, int, int)>();

Uint8List? pedersenBlindSum(
    Uint8List blind, List<Uint8List> blinds, int n, int npositive) {
  try {
    copyArray(blind, blindOutputPtr);
    setZeros(blindsPtr, blindsSize);

    var index = 0;
    for (var blind_local in blinds) {
      copyArray(blind_local, blindsPtr, index: index);
      index += blind_local.length; //32?
    }

    //blinds_size = n?
    var res = _pedersenBlindSum(n, n, npositive);

    if (res > 0) {
      return getArray(blindOutputPtr, 0, 32);
    } else {
      return null;
    }
  } finally {
    setZeros(blindOutputPtr, blindOutputSize);
    setZeros(blindsPtr, blindsSize);
  }
}
// pedersenBlindSum END

// generateMlsag START
var _generateMlsagPtr = _lookup<
    ffi.NativeFunction<
        ffi.Int32 Function(
            ffi.Size, ffi.Size, ffi.Size, ffi.Size)>>('generateMlsag');
var _generateMlsag =
    _generateMlsagPtr.asFunction<int Function(int, int, int, int)>();

class GenerateMlsagResult {
  final Uint8List KI;
  final Uint8List PC;
  final Uint8List PS;

  GenerateMlsagResult({required this.KI, required this.PC, required this.PS});
}

GenerateMlsagResult? generateMlsag(
    Uint8List ki,
    Uint8List pc,
    Uint8List ps,
    Uint8List nonce,
    Uint8List preimage,
    int nCols,
    int nRows,
    int indexRef,
    int sk_size,
    List<Uint8List> sks,
    Uint8List pk) {
  try {
    copyArray(ki, kiBigOutputPtr);
    copyArray(pc, pcOutputPtr);
    copyArray(ps, psOutputPtr);
    copyArray(nonce, nonceOutputPtr);
    copyArray(preimage, preimageInputPtr);
    copyArray(pk, pksInputPtr);

    setZeros(sksInputPtr, sksInputSize);
    var index = 0;
    for (var local in sks) {
      copyArray(local, sksInputPtr, index: index);
      index += local.length;
    }

    //blinds_size = n?
    var res = _generateMlsag(nCols, nRows, indexRef, sk_size);
    if (res == 0) {
      return GenerateMlsagResult(
          KI: getArray(kiBigOutputPtr, 0, ki.length),
          PC: getArray(pcOutputPtr, 0, pc.length),
          PS: getArray(psOutputPtr, 0, ps.length));
    } else {
      return null;
    }
  } finally {
    setZeros(kiBigOutputPtr, kiBigOutputSize);
    setZeros(pcOutputPtr, pcOutputSize);
    setZeros(psOutputPtr, psOutputSize);
    setZeros(nonceOutputPtr, nonceOutputSize);
    setZeros(preimageInputPtr, preimageInputSize);
    setZeros(pksInputPtr, pksInputSize);
    setZeros(sksInputPtr, sksInputSize);
  }
}
// generateMlsag END

// verifyMlsag START
var _verifyMlsagPtr =
    _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Size, ffi.Size)>>(
        'verifyMlsag');
var _verifyMlsag = _verifyMlsagPtr.asFunction<int Function(int, int)>();

int verifyMlsag(Uint8List preimage, int nCols, int nRows, Uint8List pk,
    Uint8List ki, Uint8List pc, Uint8List ps) {
  try {
    copyArray(preimage, preimageInputPtr);
    copyArray(pk, pksInputPtr);
    copyArray(ki, kiBigOutputPtr);
    copyArray(pc, pcOutputPtr);
    copyArray(ps, psOutputPtr);

    var res = _verifyMlsag(nCols, nRows);
    return res;
  } finally {
    setZeros(preimageInputPtr, preimageInputSize);
    setZeros(pksInputPtr, pksInputSize);
    setZeros(kiBigOutputPtr, kiBigOutputSize);
    setZeros(pcOutputPtr, pcOutputSize);
    setZeros(psOutputPtr, psOutputSize);
  }
}
// verifyMlsag END

// seckeyVerify START
var _seckeyVerifyPtr =
    _lookup<ffi.NativeFunction<ffi.Int32 Function()>>('seckeyVerify');
var _seckeyVerify = _seckeyVerifyPtr.asFunction<int Function()>();

bool seckeyVerify(Uint8List input) {
  try {
    copyArray(input, publicKeyInputPtr);

    var res = _seckeyVerify();
    return res == 1;
  } finally {
    setZeros(publicKeyInputPtr, publicKeyInputSize);
  }
}
// seckeyVerify END