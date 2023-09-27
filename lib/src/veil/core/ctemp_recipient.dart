// ignore_for_file: non_constant_identifier_names

import "dart:typed_data";
import "package:veil_light_plugin/src/core/dart_ref.dart";
import "package:veil_light_plugin/src/veil/core/ctx_destination.dart";
import "package:veil_light_plugin/src/veil/core/output_types.dart";

class CTempRecipient {
  void setAmount(int nValue) {
    nAmount = nValue;
    nAmountSelected = nValue;
  }

  bool applySubFee(int nFee, int nSubtractFeeFromAmount, BoolPass fFirst) {
    if (nType != OutputTypes.OUTPUT_DATA.value) {
      if (fSubtractFeeFromAmount && !fExemptFeeSub) {
        /*if (nAmount == null) {
          nAmount = 0;
        }*/
        nAmount -= (nFee / nSubtractFeeFromAmount)
            as int; // Subtract fee equally from each selected recipient

        if (fFirst.boolean) {
          // first receiver pays the remainder not divisible by output count
          fFirst.boolean = false;
          nAmount -= nFee % nSubtractFeeFromAmount;
        }
        return true;
      }
    }
    return false;
  }

  //bool ApplySubFee(CAmount nFee, size_t nSubtractFeeFromAmount, bool &fFirst);

  int? nType; // uint8_t
  int nAmount =
      0; //uint64           // If fSubtractFeeFromAmount, nAmount = nAmountSelected - feeForOutput
  int? nAmountSelected; //uint64
  bool fSubtractFeeFromAmount = false;
  bool fSplitBlindOutput = false;
  bool fExemptFeeSub =
      false; // Value too low to sub fee when blinded value split into two outputs
  bool fZerocoin = false;
  bool fZerocoinMint = false;
  CTxDestination? address;
  bool isMine = false;
  Uint8List? scriptPubKey;
  Uint8List? vData; // std::vector<uint8_t>
  Uint8List? vBlind; // std::vector<uint8_t>
  Uint8List? vRangeproof; // std::vector<uint8_t>
  Uint8List? commitment; //secp256k1_pedersen_commitment
  Uint8List? nonce; //uint256

  // TODO: range proof parameters, try to keep similar for fee
  // Allow an overwrite of the parameters.
  bool fOverwriteRangeProofParams = false;
  int? min_value; //uint64_t
  int? ct_exponent; //int
  int? ct_bits; //int

  Uint8List? sEphem; //CKey
  Uint8List? pkTo; //CPubKey
  int? n; //int
  String? sNarration; //std::string
  bool fScriptSet = false;
  bool fChange = false;
  bool fLastBlindDummy = false;
  bool fNonceSet = false;
  int? nChildKey; //uint32_t // update later
  int? nStealthPrefix; //uint32_t
}
