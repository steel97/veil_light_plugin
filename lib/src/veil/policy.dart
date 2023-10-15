// ignore_for_file: constant_identifier_names
import 'package:veil_light_plugin/src/veil/core/cmutable_transaction.dart';

const WITNESS_SCALE_FACTOR = 4;
const DEFAULT_BYTES_PER_SIGOP = 20;
const nBytesPerSigOp = DEFAULT_BYTES_PER_SIGOP;

int getVirtualTransactionSizeRaw(int nWeight, int nSigOpCost) {
  // int64_t
  var compute = nSigOpCost * nBytesPerSigOp;
  return ((nWeight > compute ? nWeight : compute) + WITNESS_SCALE_FACTOR - 1) ~/
      WITNESS_SCALE_FACTOR;
}

int getVirtualTransactionSize(CMutableTransaction tx, [int nSigOpCost = 0]) {
  return getVirtualTransactionSizeRaw(getTransactionWeight(tx), nSigOpCost);
}

// TO-DO
void getSerializeSize(CMutableTransaction s, int t) {
  //return (CSizeComputer(s.GetType(), s.nVersion()) << t).size();
}

int getTransactionWeight(CMutableTransaction tx) {
  return 1;
  //return getSerializeSize(tx,)
  //return :: GetSerializeSize(tx, SER_NETWORK, PROTOCOL_VERSION | SERIALIZE_TRANSACTION_NO_WITNESS) * (WITNESS_SCALE_FACTOR - 1) + :: GetSerializeSize(tx, SER_NETWORK, PROTOCOL_VERSION);
}
