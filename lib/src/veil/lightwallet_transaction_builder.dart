// ignore_for_file: empty_catches, non_constant_identifier_names, constant_identifier_names, unused_local_variable
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:convert/convert.dart';
import 'package:flutter_bitcoin/flutter_bitcoin.dart';
import 'package:veil_light_plugin/native/plugin.dart' as ecc;
import 'package:veil_light_plugin/src/core/array.dart';
import 'package:veil_light_plugin/src/core/buffer_utility.dart';
import 'package:veil_light_plugin/src/core/crypto.dart';
import 'package:veil_light_plugin/src/core/dart_ref.dart';
import 'package:veil_light_plugin/src/models/build_transaction_result.dart';
import 'package:veil_light_plugin/src/models/errors/add_ct_data_failed.dart';
import 'package:veil_light_plugin/src/models/errors/add_outputs_failed.dart';
import 'package:veil_light_plugin/src/models/errors/amount_is_over_balance.dart';
import 'package:veil_light_plugin/src/models/errors/amounts_must_not_be_negative.dart';
import 'package:veil_light_plugin/src/models/errors/change_address_is_not_stealth.dart';
import 'package:veil_light_plugin/src/models/errors/change_data_build_failed.dart';
import 'package:veil_light_plugin/src/models/errors/duplicate_index_found.dart';
import 'package:veil_light_plugin/src/models/errors/failed_to_generate_mlsag.dart';
import 'package:veil_light_plugin/src/models/errors/failed_to_get_ct_pointers_for_output_type.dart';
import 'package:veil_light_plugin/src/models/errors/failed_to_prepare_mlsag.dart';
import 'package:veil_light_plugin/src/models/errors/failed_to_select_range_proof_parameters.dart';
import 'package:veil_light_plugin/src/models/errors/failed_to_sign_range_proof.dart';
import 'package:veil_light_plugin/src/models/errors/get_destination_key_for_output_failed.dart';
import 'package:veil_light_plugin/src/models/errors/inputs_per_sigs_out_of_range.dart';
import 'package:veil_light_plugin/src/models/errors/insert_key_images_failed.dart';
import 'package:veil_light_plugin/src/models/errors/invalid_basecoin_address.dart';
import 'package:veil_light_plugin/src/models/errors/invalid_change_address.dart';
import 'package:veil_light_plugin/src/models/errors/invalid_ephemeral_pubkey.dart';
import 'package:veil_light_plugin/src/models/errors/key_images_failed.dart';
import 'package:veil_light_plugin/src/models/errors/missing_ephemeral_value.dart';
import 'package:veil_light_plugin/src/models/errors/no_anon_txes.dart';
import 'package:veil_light_plugin/src/models/errors/no_key_found_for_index.dart';
import 'package:veil_light_plugin/src/models/errors/no_pubkey_found.dart';
import 'package:veil_light_plugin/src/models/errors/pedersen_blindsum_failed.dart';
import 'package:veil_light_plugin/src/models/errors/pedersen_commit_failed.dart';
import 'package:veil_light_plugin/src/models/errors/receiving_pubkey_generation_failed.dart';
import 'package:veil_light_plugin/src/models/errors/recipient_data_build_failed.dart';
import 'package:veil_light_plugin/src/models/errors/ringsize_out_of_range.dart';
import 'package:veil_light_plugin/src/models/errors/select_spendable_tx_for_value_failed.dart';
import 'package:veil_light_plugin/src/models/errors/sign_and_verify_failed.dart';
import 'package:veil_light_plugin/src/models/errors/tx_at_lease_one_recipient.dart';
//import 'package:veil_light_plugin/src/models/errors/tx_fee_and_change_calc_failed.dart';
import 'package:veil_light_plugin/src/models/errors/unimplemented_exception.dart';
import 'package:veil_light_plugin/src/models/errors/unknown_output_type.dart';
import 'package:veil_light_plugin/src/models/errors/update_change_output_commitment_failed.dart';
import 'package:veil_light_plugin/src/models/rpc/lightwallet/get_anon_outputs_response.dart';
import 'package:veil_light_plugin/src/veil/chainparams.dart';
import 'package:veil_light_plugin/src/veil/coin_selection.dart';
import 'package:veil_light_plugin/src/veil/core/cmutable_transaction.dart';
import 'package:veil_light_plugin/src/veil/core/cscript.dart';
import 'package:veil_light_plugin/src/veil/core/ctemp_recipient.dart';
import 'package:veil_light_plugin/src/veil/core/ctx_destination.dart';
import 'package:veil_light_plugin/src/veil/core/ctx_in.dart';
import 'package:veil_light_plugin/src/veil/core/ctx_out_base.dart';
import 'package:veil_light_plugin/src/veil/core/ctx_out_ct.dart';
import 'package:veil_light_plugin/src/veil/core/ctx_out_data.dart';
import 'package:veil_light_plugin/src/veil/core/ctx_out_ring_ctor.dart';
import 'package:veil_light_plugin/src/veil/core/ctx_out_standard.dart';
import 'package:veil_light_plugin/src/veil/core/output_types.dart';
import 'package:veil_light_plugin/src/veil/cveil_address.dart';
import 'package:veil_light_plugin/src/veil/cveil_recipient.dart';
import 'package:veil_light_plugin/src/veil/cveil_stealth_address.dart';
import 'package:veil_light_plugin/src/veil/lightwallet_address.dart';
import 'package:veil_light_plugin/src/veil/policy.dart';
import 'package:veil_light_plugin/src/veil/stealth.dart';
import 'package:veil_light_plugin/src/veil/tx/clight_wallet_anon_output_data.dart';
import 'package:veil_light_plugin/src/veil/tx/cout_point.dart';
import 'package:veil_light_plugin/src/veil/tx/cwatch_only_tx.dart';
import 'package:veil_light_plugin/src/veil/tx/cwatch_only_tx_with_index.dart';

var random = FortunaRandom();
var _sGen = Random.secure();

class SpendableTxForValue {
  List<CWatchOnlyTxWithIndex> vSpendTheseTx;
  int nChange;

  SpendableTxForValue({required this.vSpendTheseTx, required this.nChange});
}

enum DataOutputTypes {
  DO_NULL(0), // reserved
  DO_NARR_PLAIN(1),
  DO_NARR_CRYPT(2),
  DO_STEALTH(3),
  DO_STEALTH_PREFIX(4),
  DO_VOTE(5),
  DO_FEE(6),
  DO_DEV_FUND_CFWD(7),
  DO_FUND_MSG(8);

  const DataOutputTypes(this.value);
  final int value;
}

class LightwalletTransactionBuilder {
  static List<CLightWalletAnonOutputData> AnonOutputsRawToObj(
      List<String> apiAnonOuts) {
    List<CLightWalletAnonOutputData> res = [];
    for (var out in apiAnonOuts) {
      var obj = CLightWalletAnonOutputData();
      obj.deserialize(Uint8List.fromList(hex.decode(out)));
      res.add(obj);
    }

    return res;
  }

  static List<CLightWalletAnonOutputData> AnonOutputsToObj(
      List<AnonOutput> apiAnonOuts) {
    List<CLightWalletAnonOutputData> res = [];
    for (var out in apiAnonOuts) {
      var obj = CLightWalletAnonOutputData();
      obj.deserialize(Uint8List.fromList(hex.decode(out.raw!)));
      res.add(obj);
    }

    return res;
  }

  // returns txHex
  static BuildTransactionResult buildLightWalletTransaction(
      Chainparams chainParams,
      LightwalletAddress address,
      List<CVeilRecipient> recipients,
      List<CWatchOnlyTxWithIndex> vSpendableTx,
      List<CLightWalletAnonOutputData> vDummyOutputs,
      bool strategyUseSingleTxPriority,
      {int ringSize = 5}) {
    List<CLightWalletAnonOutputData> vDummyOutputsReconstructed = [];
    List<CWatchOnlyTxWithIndex> vAnonTxes = [];
    List<CWatchOnlyTxWithIndex> vStealthTxes = [];

    for (var dummyOut in vDummyOutputs) {
      var indexUnusable = false;
      for (var tx in vSpendableTx) {
        if (tx.getRingCtIndex() == dummyOut.getIndex()) {
          indexUnusable = true;
          break;
        }
      }

      if (!indexUnusable) {
        vDummyOutputsReconstructed.add(dummyOut);
      }
    }

    if (vDummyOutputsReconstructed.length < vSpendableTx.length) {
      throw Exception('Not enough dummy outputs');
    }

    for (var tx in vSpendableTx) {
      if (tx.getType() == WatchOnlyTxType.ANON) {
        vAnonTxes.add(tx);
      }

      if (tx.getType() == WatchOnlyTxType.STEALTH) {
        vStealthTxes.add(tx);
      }
    }

    if (vAnonTxes.isNotEmpty) {
      // rebuild recipients
      List<CVeilRecipient> resultingRecipients = [];
      for (var rcp in recipients) {
        resultingRecipients.add(CVeilRecipient(
            rcp.address,
            double.parse(
                ((double.parse(rcp.amount.toString().replaceAll(',', '.')) *
                        chainParams.COIN.toInt()))
                    .toStringAsFixed(0))));
      }
      return LightwalletTransactionBuilder.buildLightWalletRingCTTransaction(
          chainParams,
          address,
          resultingRecipients,
          vAnonTxes,
          vDummyOutputsReconstructed,
          strategyUseSingleTxPriority,
          ringSize);
    } else if (vStealthTxes.isNotEmpty) {
      // return BuildLightWalletStealthTransaction(args, vStealthTxes, txHex, errorMsg);
      throw UnimplementedException('Not implemented (yes?)');
    } else {
      throw NoAnonTxes('No Anon or Stealth txes given to build transaction');
    }
  }

  // returns txHex
  static BuildTransactionResult buildLightWalletRingCTTransaction(
      Chainparams chainParams,
      LightwalletAddress address,
      List<CVeilRecipient> recipients,
      List<CWatchOnlyTxWithIndex> vSpendableTx,
      List<CLightWalletAnonOutputData> vDummyOutputs,
      bool strategyUseSingleTxPriority,
      int ringSize) {
    random.seed(KeyParameter(
        Uint8List.fromList(List.generate(32, (_) => _sGen.nextInt(255)))));

    var response = BuildTransactionResult(0, 0, txdata: null);

    var coinSelection = CoinSelection(chainParams);

    var spendKey = address.getSpendKey()!;
    var scanKey = address.getScanKey()!;

    var spend_secret = spendKey.privateKey;
    var scan_secret = scanKey.privateKey;
    var spend_pubkey = spendKey.publicKey;

    List<CTempRecipient> vecSend = [];
    int nValueOut = 0;
    // Build the Output
    for (var rcp in recipients) {
      nValueOut += rcp.amount.round();
      var destination = LightwalletTransactionBuilder.getTypeOut(rcp.address);
      var r = CTempRecipient();
      r.nType = destination.type.value;
      r.setAmount(rcp.amount.round());
      r.address = destination;
      if (r.nType == OutputTypes.OUTPUT_STANDARD.value) {
        r.fScriptSet = true;
        r.scriptPubKey = destination.scriptPubKey;
      }

      vecSend.add(r);
    }

    var vectorTxesWithAmountSet =
        vSpendableTx; //this.getAmountAndBlindForUnspentTx(vSpendableTx, spend_secret!, scan_secret!, spend_pubkey);

    if (!LightwalletTransactionBuilder.checkAmounts(
        chainParams, nValueOut, vectorTxesWithAmountSet)) {
      throw AmountIsOverBalance('Amount is over the balance of this address');
    }

    // Default ringsize is 11
    var nRingSize = ringSize;
    var nInputsPerSig = nRingSize;

    // Get change address - this is the same address we are sending from
    var sxAddr = CVeilStealthAddress();
    sxAddr.fromData(scan_secret!, Stealth.getPubKey(scan_secret),
        hash160(spend_secret!), Stealth.getPubKey(spend_secret), 0);

    //sxAddr.scan_pubkey = Stealth.getPubKey(sxAddr.scan_secret!);
    //sxAddr.spend_pubkey = Stealth.getPubKey(spend_secret!); // TO-DO spend_secret.IsValid()
    /*
        if (spend_secret.IsValid() && 0 != SecretToPublicKey(spend_secret, sxAddr.spend_pubkey)) {
            LogPrintf("Failed - Could not get spend public key.");
            errorMsg = "Could not get spend public key.";
            return false;
        } else {
            SetPublicKey(spend_pubkey, sxAddr.spend_pubkey);
        }        
        */

    var addrChange = CVeilAddress(null, sxAddr, true);
    if (!addrChange.isValidStealthAddress()) {
      throw InvalidChangeAddress('Invalid change address');
    }
    /*
            // TODO - if we can, remove coincontrol if we don't need to use it. bypass if we can
    // Set the change address in coincontrol
    CCoinControl coincontrol;
    coincontrol.destChange = addrChange.Get();
        
        */
    var destChange = LightwalletTransactionBuilder.getTypeOut(addrChange);
    // Check we are sending to atleast one address
    if (vecSend.isEmpty) {
      throw TxAtLeastOneRecipient(
          'Transaction must have at least one recipient.');
    }

    // Get total value we are sending in vecSend
    var nValue = 0;
    for (var r in vecSend) {
      nValue += r.nAmount;
      if (nValue < 0 || (r.nAmount) < 0) {
        throw AmountsMustNotBeNegative(
            'Transaction amounts must not be negative');
      }
    }

    // Check ringsize
    if (nRingSize < 3 || nRingSize > 32) {
      throw RingSizeOutOfRange('Ring size out of range.');
    }

    // Check inputspersig
    if (nInputsPerSig < 1 || nInputsPerSig > 32) {
      throw InputsPerSigsIsOutOfRange('Num inputs per signature out of range.');
    }

    // Build the recipient data
    if (!LightwalletTransactionBuilder.buildRecipientData(vecSend)) {
      throw RecipientDataBuildFailed('Failed - buildRecipientData');
    }

    var txNew = CMutableTransaction();

    // Create tx object
    txNew.nLockTime = 0;

    //FeeCalculation feeCalc;
    var nFeeNeeded = 0;
    var nBytes = 0;

    // Get inputs = vAvailableWatchOnly
    var nValueOutPlainRef = NumPass(0);
    var nChangePosInOutRef = NumPass(-1);

    List<List<List<int>>> vMI = []; //Array< Array< Array<int64_t>  > >
    List<Uint8List> vInputBlinds = []; // Array< Buffer>
    List<int> vSecretColumns = [];

    var nSubFeeTries = 100;
    var pick_new_inputs = true;
    var nValueIn = 0;

    var nFeeRetRef = NumPass(0);
    var nSubtractFeeFromAmount = 0;

    List<CWatchOnlyTx> vSelectedWatchOnly = [];

    txNew.vin = [];
    txNew.vpout = [];
    vSelectedWatchOnly = []; //???!

    var nValueToSelect = nValue;
    if (nSubtractFeeFromAmount == 0) {
      nValueToSelect += nFeeRetRef.num;
    }

    nValueIn = 0;

    // Select tx to spend
    var ssres = LightwalletTransactionBuilder.selectSpendableTxForValue(
        nValueOut, vectorTxesWithAmountSet, strategyUseSingleTxPriority);
    var vSelectedTxes = ssres.vSpendTheseTx;
    var nTempChange = ssres.nChange;

    // TODO, have the server give us the feerate per Byte, when asking for txes
    // TODO, for now set to CENT
    nFeeNeeded = chainParams.CENT.toInt();

    // Build the change recipient
    // Do not add change if we spending all balance
    var overallSpendableBalance = 0;
    for (var tx in vSpendableTx) {
      overallSpendableBalance += tx.getRingCtOut()!.getAmount()!.toInt();
    }
    if (nValueOut + nFeeNeeded < overallSpendableBalance) {
      var nChange = nTempChange; //CAmount
      if (!LightwalletTransactionBuilder.buildChangeData(chainParams, vecSend,
          nChangePosInOutRef, nFeeRetRef, nChange, destChange)) {
        //coincontrol.destChange(addrChange), errorMsg
        throw ChangeDataBuildFailed('Failed BuildChangeData');
      }
    }

    var nRemainder = vSelectedTxes.length % nInputsPerSig;
    var nTxRingSigs =
        (vSelectedTxes.length / nInputsPerSig + (nRemainder == 0 ? 0 : 1))
            .floor();

    var nRemainingInputs = vSelectedTxes.length; //size_t

    //Add blank anon inputs as anon inputs
    for (var k = 0; k < nTxRingSigs; ++k) {
      var nInputs = (k == (nTxRingSigs - 1) ? nRemainingInputs : nInputsPerSig);
      var txin = CTxIn();
      txin.nSequence = CTxIn.SEQUENCE_FINAL;
      txin.prevout.n = COutPoint.ANON_MARKER;
      txin.setAnonInfo(nInputs, nRingSize);
      txNew.vin.add(txin);

      nRemainingInputs -= nInputs;
    }

    vMI = List.filled(nTxRingSigs, List.empty());
    vInputBlinds = List.filled(nTxRingSigs, Uint8List(32));
    vSecretColumns = [];
    //vMI.resize(nTxRingSigs);
    //vInputBlinds.resize(nTxRingSigs);
    //vSecretColumns.resize(nTxRingSigs);
    for (var i = 0; i < nTxRingSigs; i++) {
      vMI[i] = [];
      //vInputBlinds[i] = Uint8List(32);
      vSecretColumns.add(0);
    }

    nValueOutPlainRef.num = 0;
    nChangePosInOutRef.num = -1;

    //var outFeeVdata = Buffer.alloc(9);
    var outFeeWriter = BufferWriter();
    outFeeWriter.writeUInt8(DataOutputTypes.DO_FEE.value);
    outFeeWriter.writeSlice(Uint8List(8));
    var outFee = CTxOutData(outFeeWriter.getBuffer());
    txNew.vpout.add(outFee);

    // Add CT DATA to txNew
    if (!LightwalletTransactionBuilder.lightWalletAddCTData(
        txNew,
        vecSend,
        nFeeRetRef,
        nValueOutPlainRef,
        nChangePosInOutRef,
        nSubtractFeeFromAmount)) {
      throw AddCTDataFailed('Failed LightWalletAddCTData');
    }

    // Add in real outputs
    if (!LightwalletTransactionBuilder.lightWalletAddRealOutputs(
        txNew, vSelectedTxes, vInputBlinds, vSecretColumns, vMI)) {
      throw AddOutputsFailed('Failed lightWalletAddRealOutputs');
    }

    // Add in dummy outputs
    LightwalletTransactionBuilder.lightWalletFillInDummyOutputs(
        txNew, vDummyOutputs, vSecretColumns, vMI);

    // Get the amout of bytes
    nBytes = getVirtualTransactionSize(txNew);

    if (nFeeRetRef.num >= nFeeNeeded) {
      // Reduce fee to only the needed amount if possible. This
      // prevents potential overpayment in fees if the coins
      // selected to meet nFeeNeeded result in a transaction that
      // requires less fee than the prior iteration.
      if (nFeeRetRef.num > nFeeNeeded &&
          nChangePosInOutRef.num != -1 &&
          nSubtractFeeFromAmount == 0) {
        var r = vecSend[nChangePosInOutRef.num];

        var extraFeePaid = nFeeRetRef.num - nFeeNeeded;

        r.nAmount += extraFeePaid;
        nFeeRetRef.num -= extraFeePaid;
      }
    } /*else if (!pick_new_inputs) {
      // This shouldn't happen, we should have had enough excess
      // fee to pay for the new output and still meet nFeeNeeded
      // Or we should have just subtracted fee from recipients and
      // nFeeNeeded should not have changed

      if (nSubtractFeeFromAmount <= 0 || (--nSubFeeTries) <= 0) {
        throw TxFeeAndChangeCalcFailed(
            "Failed Transaction fee and change calculation failed");
      }
    }*/

    // Try to reduce change to include necessary fee
    if (nChangePosInOutRef.num != -1 && nSubtractFeeFromAmount == 0) {
      var r = vecSend[nChangePosInOutRef.num];
      var additionalFeeNeeded = nFeeNeeded - nFeeRetRef.num;
      if (r.nAmount >=
          coinSelection.MIN_FINAL_CHANGE.toInt() + additionalFeeNeeded) {
        r.nAmount -= additionalFeeNeeded;
        nFeeRetRef.num += additionalFeeNeeded;
      }
    }

    // Include more fee and try again.
    nFeeRetRef.num = nFeeNeeded;

    vSelectedWatchOnly = vSelectedTxes;

    nValueOutPlainRef.num += nFeeRetRef.num;

    // Remove scriptSigs to eliminate the fee calculation dummy signatures
    for (var txin in txNew.vin) {
      txin.scriptData.stack[0] = Uint8List(0);
      txin.scriptWitness.stack[1] = Uint8List(0);
    }

    List<Uint8List> vpOutCommits = []; // std:: vector <const uint8_t *>
    List<Uint8List> vpOutBlinds = []; // std:: vector <const uint8_t *>
    var vBlindPlain = Uint8List(32); // std:: vector <const uint8_t *>

    var plainCommitment = Uint8List(33);
    if (nValueOutPlainRef.num > 0) {
      var res = ecc.pedersenCommit(
          plainCommitment, vBlindPlain, BigInt.from(nValueOutPlainRef.num));
      if (res == null) {
        throw PedersenCommitFailed('Pedersen Commit failed for plain out.');
      }
      plainCommitment = Uint8List.fromList(res.commitment);
      vBlindPlain = Uint8List.fromList(res.blind);

      vpOutCommits.add(plainCommitment);
      vpOutBlinds.add(vBlindPlain);
    }

    if (!LightwalletTransactionBuilder.lightWalletUpdateChangeOutputCommitment(
        txNew, vecSend, nChangePosInOutRef, vpOutCommits, vpOutBlinds)) {
      throw UpdateChangeOutputCommitmentFailed(
          'Failed LightWalletUpdateChangeOutputCommitment');
    }

    response.fee = nFeeRetRef.num;

    //Add actual fee to CT Fee output
    var vpTx1 = txNew.vpout[0] as CTxOutData;
    var vData = vpTx1.vData;
    vData = vData.sublist(0, 1); // carefull!
    //var tempBuf = Uint8List(16) Buffer.alloc(16);
    var ndWriter = BufferWriter();
    //ndWriter.writeVarInt(nFeeRetRef.num);
    ndWriter.customVarInt(nFeeRetRef.num);
    //vData = ndWriter.buffer.subarray(0, ndWriter.offset);//end ok
    var targetData = Uint8List(vData.length + ndWriter.offset);
    targetData.setAll(0, vData);
    targetData.setAll(1, ndWriter.buffer.sublist(0, ndWriter.offset));
    vData = targetData;
    vpTx1.vData = vData;

    List<Uint8List> vSplitCommitBlindingKeys = List.filled(
        txNew.vin.length,
        Uint8List(
            32)); //std:: vector < CKey > =(txNew.vin.length); // input amount commitment when > 1 mlsag
    //int nTotalInputs = 0;

    Map<int, Uint8List> vSigningKeys = {};
    //std:: vector < std:: pair < int64_t, CKey >> vSigningKeys;
    if (!LightwalletTransactionBuilder.lightWalletInsertKeyImages(
        txNew,
        vSigningKeys,
        vSelectedTxes,
        vSecretColumns,
        vMI,
        spend_pubkey,
        scan_secret,
        spend_secret)) {
      throw InsertKeyImagesFailed('Failed LightWalletInsertKeyImages.');
    }

    if (!LightwalletTransactionBuilder.lightWalletSignAndVerifyTx(
        txNew,
        vInputBlinds,
        vpOutCommits,
        vpOutBlinds,
        vSplitCommitBlindingKeys,
        vSigningKeys,
        vDummyOutputs,
        vSelectedTxes,
        vSecretColumns,
        vMI)) {
      throw SignAndVerifyFailed('Failed LightWalletSignAndVerifyTx');
    }

    var txData = hex.encode(txNew.encode()); //EncodeHexTx(*txRef);
    response.txdata = txData;
    response.amountSent = nValueOut;
    return response;
  }

  // return outputType and destination
  static CTxDestination getTypeOut(CVeilAddress address) {
    if (address.isValidStealthAddress()) {
      return CTxDestination(
          null, address.getStealthAddress(), OutputTypes.OUTPUT_RINGCT);
    } else {
      //if (!IsValidDestination(destination)) {
      if (!address.isValid()) {
        throw InvalidBasecoinAddress('Invalid basecoin address');
      }

      return CTxDestination(
          address.getScriptPubKey(), null, OutputTypes.OUTPUT_STANDARD);
    }
  }

  static checkAmounts(
      Chainparams chainParams, int nValueOut, List<CWatchOnlyTx> vSpendableTx) {
    var nSum = 0;
    for (var tx in vSpendableTx) {
      nSum += (tx.getRingCtOut()?.getAmount())?.toInt() ?? 0;

      if ((nValueOut + chainParams.CENT.toInt()) <= nSum) {
        return true;
      }
    }

    return false;
  }

  // tx already has this info
  /*private static getAmountAndBlindForUnspentTx(vectorUnspentWatchonlyTx: Array<CWatchOnlyTx>, spend_secret: Buffer, scan_secret: Buffer, spend_pubkey: Buffer) {
         for (var currenttx in vectorUnspentWatchonlyTx) {
 
             var destinationKeyPriv = this.getDestinationKeyForOutput(currenttx, spend_secret, scan_secret, spend_pubkey);
 
             var vchEphemPK: Buffer;
             if (currenttx.getType() == WatchOnlyTxType.ANON) {
                 vchEphemPK = currenttx.getRingCtOut()?.getVCHEphemPK()!;
             } else {
                  throw UnimplementedException("Not implemented (yes?)");
             }
 
             // Regenerate nonce
             var nonce = ecc.ECDH_VEIL(vchEphemPK, destinationKeyPriv)
             var hasher = new Hash();
             hasher.update(nonce!, 32);
             var nonceHashed = hasher.digest();
             if (currenttx.getType() == WatchOnlyTxType.ANON) {
                 var amountres = ecc.rangeProofRewind(nonceHashed, this._commitment!, this._vRangeproof!);
                 currenttx.blind = uint256();
                 memcpy(currenttx.blind.begin(), blindOut, 32);
                 currenttx.nAmount = amountOut;
                 vTxes.emplace_back(currenttx);
             } else {
                  throw UnimplementedException("Not implemented (yes?)");
             }
             
         }
     }*/

  static getDestinationKeyForOutput(CWatchOnlyTx tx, Uint8List spend_secret,
      Uint8List scan_secret, Uint8List spend_pubkey) {
    if (tx.getType() == WatchOnlyTxType.ANON) {
      var idk = hash160(tx.getRingCtOut()!.getPubKey()!);
      //CKeyID idk = tx.ringctout.pk.GetID();

      var vchEphemPK = tx.getRingCtOut()?.getVCHEphemPK();
      var ecPubKey = Stealth.setPublicKey(spend_pubkey);
      var stealthSecretRes =
          Stealth.stealthSecret(scan_secret, vchEphemPK!, ecPubKey);

      var sShared = stealthSecretRes.sShared;
      //var pkExtracted = stealthSecretRes.pkExtracted;

      // TO-DO
      /*if (!sShared.IsValid()) {
                LogPrintf("sShared wasn't valid: tx type %s", tx.type == CWatchOnlyTx::ANON ? "anon" : "stealth");
            }*/

      var destinationKeyPriv =
          Stealth.stealthSharedToSecretSpend(sShared, spend_secret);

      var destinationKey = Stealth.getPubKey(destinationKeyPriv);
      var destIdent = hash160(destinationKey);
      if (hex.encode(destIdent) != hex.encode(idk)) {
        throw GetDestinationKeyForOutputFailed(
            'GetDestinationKeyForOutput failed to generate correct shared secret');
      }
      return destinationKeyPriv;
    } else {
      throw UnimplementedException('Not implemented (yes?)');
    }
  }

  static buildRecipientData(List<CTempRecipient> vecSend) {
    for (var r in vecSend) {
      if (r.nType == OutputTypes.OUTPUT_STANDARD.value) {
        /*if (r.address.type() == typeid(CExtKeyPair)) {
                    errorMsg = "sending to extkeypair";
                    return false;
                } else if (r.address.type() == typeid(CKeyID)) {
                    r.scriptPubKey = GetScriptForDestination(r.address);
                } else {
                    if (!r.fScriptSet) {
                        r.scriptPubKey = GetScriptForDestination(r.address);
                        if (r.scriptPubKey.empty()) {
                            errorMsg = "Unknown address type and no script set.";
                            return false;
                        }
                    }
                }*/
        r.scriptPubKey = r.address?.scriptPubKey;
      } else if (r.nType == OutputTypes.OUTPUT_RINGCT.value) {
        var sEphem = r.sEphem;
        if (sEphem == null || sEphem.lengthInBytes < 32) {
          sEphem = random.nextBytes(
              32); //ECPair.makeRandom({ compressed: true }).privateKey!;
        }

        //if (r.address.type() == typeid(CStealthAddress)) {
        var sx = r.address?.stealthAddress;

        //Uint8List? sShared;
        Uint8List? pkSendTo;
        var k = 0;
        var nTries = 24;
        for (k = 0; k < nTries; ++k) {
          try {
            var scan_pubkey_t = Stealth.setPublicKey(sx!.scan_pubkey!);
            var spend_pubkey_t = Stealth.setPublicKey(sx.spend_pubkey!);
            var res =
                Stealth.stealthSecret(sEphem!, scan_pubkey_t, spend_pubkey_t);
            //sShared = res.sShared;
            pkSendTo = res.pkExtracted;
            break;
          } catch (e) {}
          sEphem = LightwalletTransactionBuilder.makeNewKey(
              true); // randomBytes.default(32);
        }
        if (k >= nTries) {
          throw ReceivingPubKeyGenerationFailed(
              'Could not generate receiving public key');
        }

        r.pkTo = pkSendTo;
        /*var idTo = */ hash160(r.pkTo!); //.GetID();

        if (sx!.prefix.number_bits > 0) {
          r.nStealthPrefix = LightwalletTransactionBuilder.fillStealthPrefix(
              sx.prefix.number_bits, sx.prefix.bitfield);
        }
        /*} else {
                    errorMsg = "RINGCT Outputs - Only able to send to stealth address for now.";
                    return false;
                }*/

        r.sEphem = sEphem;
      }
    }

    return true;
  }

  static bool buildChangeData(
      Chainparams chainParams,
      List<CTempRecipient> vecSend,
      NumPass nChangePositionOut,
      NumPass nFeeReturned,
      int nChange,
      CTxDestination changeDestination) {
    // Insert a sender-owned 0 value output that becomes the change output if needed
    // Fill an output to ourself
    var recipient = CTempRecipient();
    recipient.nType = OutputTypes.OUTPUT_RINGCT.value;
    recipient.fChange = true;
    //sEphem = ECPair.makeRandom().privateKey!;//MakeNewKey
    //recipient.sEphem.MakeNewKey(true);
    recipient.sEphem = LightwalletTransactionBuilder.makeNewKey(
        true); // ECPair.makeRandom({ compressed: true }).privateKey!.subarray(0);

    recipient.address = changeDestination;

    if (recipient.address?.type == OutputTypes.OUTPUT_RINGCT) {
      var sx = recipient.address?.stealthAddress;
      //CStealthAddress sx = boost:: get<CStealthAddress>(recipient.address);
      //CKey keyShared;
      //ec_point pkSendTo;

      //Uint8List? keyShared;
      Uint8List? pkSendTo;
      var k = 0;
      var nTries = 24;
      for (k = 0; k < nTries; ++k) {
        try {
          //if (StealthSecret(recipient.sEphem, sx.scan_pubkey, sx.spend_pubkey, keyShared, pkSendTo) == 0)
          var res = Stealth.stealthSecret(
              recipient.sEphem!, sx!.scan_pubkey!, sx.spend_pubkey!);
          //keyShared = res.sShared;
          pkSendTo = res.pkExtracted;
          break;
        } catch (e) {}
        recipient.sEphem = LightwalletTransactionBuilder.makeNewKey(true);
      }

      if (k >= nTries) {
        throw ReceivingPubKeyGenerationFailed(
            'Could not generate receiving public key');
      }

      var ecpairl = ECPair.fromPrivateKey(recipient.sEphem!);
      try {
        var pkEphem = ecpairl.publicKey;
        if (pkEphem.isEmpty) throw Exception();
      } catch (e) {
        throw InvalidEphemeralPubKey('Ephemeral pubkey is not valid');
      }

      recipient.pkTo = pkSendTo; // CPubKey(pkSendTo);

      var idTo = hash160(recipient.pkTo!); //.GetID();
      recipient.scriptPubKey =
          LightwalletTransactionBuilder.getScriptForDestinationKeyId(idTo);
    } else {
      throw ChangeAddressIsNotStealth(
          "Change address wasn't of CStealthAddress Type");
      //return false;
    }

    if (nChange > chainParams.minRelayTxFee!.getFee(2048)) {
      recipient.setAmount(nChange);
    } else {
      recipient.setAmount(0);
      nFeeReturned.num += nChange;
    }

    if (nChangePositionOut.num < 0) {
      nChangePositionOut.num =
          LightwalletTransactionBuilder.getRandInt(vecSend.length + 1);
    } else {
      nChangePositionOut.num = nChangePositionOut.num < vecSend.length
          ? nChangePositionOut.num
          : vecSend
              .length; // std::min(nChangePositionOut, (int) vecSend.length);
    }

    if (nChangePositionOut.num < vecSend.length &&
        vecSend[nChangePositionOut.num].nType ==
            OutputTypes.OUTPUT_DATA.value) {
      nChangePositionOut.num++;
    }

    //vecSend.splice(nChangePositionOut.num, 0, recipient);
    vecSend.insert(nChangePositionOut.num, recipient);
    //vecSend.insert(vecSend.begin() + nChangePositionOut, recipient);

    return true;
  }

  static getScriptForDestinationKeyId(Uint8List keyId) {
    //var targetBuf = Buffer.alloc(1024, 0);
    var writer = BufferWriter();
    writer.writeUInt8(opcodetype.OP_DUP.value);
    writer.writeUInt8(opcodetype.OP_HASH160.value);
    writer.writeSlice(keyId); // 20 bytes
    writer.writeUInt8(opcodetype.OP_EQUALVERIFY.value);
    writer.writeUInt8(opcodetype.OP_CHECKSIG.value);
    return writer.getBuffer(); // writer.buffer.subarray(0, writer.offset);
  }

  static int setStealthMask(int nBits /*uint8_t */) //uint32_t
  {
    return (nBits == 32 ? 0xFFFFFFFF : ((1 << nBits) - 1));
  }

  static int fillStealthPrefix(
      int nBits /* uint8_t */, int nBitfield /* uint32_t */) //uint32_t
  {
    var prefix = 0;
    var mask = LightwalletTransactionBuilder.setStealthMask(nBits);

    /*var bytes = randomBytes.default(4);
        var dv = new DataView(new Uint8Array(bytes).buffer);
        prefix = dv.getUint32(0);*/
    prefix = random.nextUint32();
    //GetStrongRandBytes((uint8_t *) & prefix, 4);

    prefix &= (~mask);
    prefix |= nBitfield & mask;
    return prefix;
  }

  static SpendableTxForValue selectSpendableTxForValue(
      int nValueOut,
      List<CWatchOnlyTxWithIndex> vSpendableTx,
      bool strategyUseSingleTxPriority) {
    //bool
    var res = SpendableTxForValue(
        vSpendTheseTx: [], // vSpendTheseTx
        nChange: 0);
    var currentMinimumChange = 0;
    var tempsingleamountchange = 0;
    var tempmultipleamountchange = 0;

    var fSingleInput = false;
    var fMultipleInput = false;

    // TODO - this can be improved, but works for now

    for (var tx in vSpendableTx) {
      //LogPrintf("tx amounts %d, ", tx.nAmount);
      //console.log(`tx amounts ${tx.getRingCtOut()?.getAmount()!}`);
      if ((tx.getRingCtOut()?.getAmount()?.toInt() ?? 0) > nValueOut) {
        tempsingleamountchange =
            (tx.getRingCtOut()?.getAmount()?.toInt() ?? 0) - nValueOut;
        if ((tempsingleamountchange < currentMinimumChange ||
                currentMinimumChange == 0) &&
            tempsingleamountchange > 0) {
          res.vSpendTheseTx = [];
          fSingleInput = true;
          res.vSpendTheseTx.add(tx);
          currentMinimumChange = tempsingleamountchange;
        }
      }
    }

    if (!fSingleInput || !strategyUseSingleTxPriority) {
      res.vSpendTheseTx = [];
      // We can use a single input for this transaction
      var currentSelected = 0;
      for (var tx in vSpendableTx) {
        currentSelected += (tx.getRingCtOut()?.getAmount()?.toInt() ?? 0);
        res.vSpendTheseTx.add(tx);
        if (currentSelected > nValueOut) {
          tempmultipleamountchange = currentSelected - nValueOut;
          fMultipleInput = true;
          break;
        }
      }
    }

    //LogPrintf("nValueOut %d, ", nValueOut);

    if (fSingleInput && !(fMultipleInput && !strategyUseSingleTxPriority)) {
      res.nChange = tempsingleamountchange;
    } else if (fMultipleInput) {
      res.nChange = tempmultipleamountchange;
    } else {
      throw SelectSpendableTxForValueFailed('selectSpendableTxForValue failed');
    }

    return res;
  }

  static BigInt getRand(BigInt nMax) {
    //uint64_t
    if (nMax == BigInt.zero) {
      return BigInt.zero;
    }

    // The range of the random source must be a multiple of the modulus
    // to give every possible output value an equal possibility
    var nRange = (BigInt.parse('18446744073709551615') ~/ nMax) *
        nMax; //std::numeric_limits<uint64_t>:: max()
    var nRand = BigInt.zero;
    do {
      /*var bytes = randomBytes.default(8);
            var dv = new DataView(new Uint8Array(bytes).buffer);
            nRand = dv.getBigUint64(0);*/
      nRand = random.nextBigInteger(64);
      //GetRandBytes((unsigned char *) & nRand, sizeof(nRand));
    } while (nRand >= nRange);
    return (nRand % nMax);
  }

  static int getRandInt(int nMax) {
    return LightwalletTransactionBuilder.getRand(BigInt.from(nMax)).toInt();
  }

  static void setCTOutVData(
      CTxOutCT txout, Uint8List pkEphem, int nStealthPrefix) {
    //var vData = Buffer.alloc(nStealthPrefix > 0 ? 38 : 33);
    var writer = BufferWriter();
    writer.writeSlice(pkEphem.sublist(0, 33));

    if (nStealthPrefix > 0) {
      writer.writeUInt8(DataOutputTypes.DO_STEALTH_PREFIX.value);
      writer.writeUInt32(nStealthPrefix);
    }
    txout.vData =
        writer.getBuffer(); //writer.buffer.subarray(0, writer.offset);
  }

  static CTxOutRingCTOr createOutputRingCT(
      Uint8List cmpPubKeyTo, int nStealthPrefix, Uint8List pkEphem) {
    var txbout = CTxOutRingCTOr();
    var txout = txbout;
    txout.pk = cmpPubKeyTo;
    LightwalletTransactionBuilder.setCTOutVData(txout, pkEphem, nStealthPrefix);
    return txbout;
  }

  static CTxOutBase? createOutput(CTempRecipient r) {
    // int
    CTxOutBase? txbout;
    switch (OutputTypes.values[r.nType ?? 0]) {
      case OutputTypes.OUTPUT_DATA:
        txbout = CTxOutData(r.vData!);
        break;
      case OutputTypes.OUTPUT_STANDARD:
        txbout = CTxOutStandard(r.nAmount, r.scriptPubKey!);
        break;
      case OutputTypes.OUTPUT_CT:
        {
          txbout = CTxOutCT(null);
          CTxOutCT txout = txbout as CTxOutCT;

          if (r.fNonceSet) {
            if ((r.vData?.length ?? 0) < 33) {
              throw MissingEphemeralValue(
                  'Missing ephemeral value, vData size ${r.vData?.length}');
            }
            txout.vData = r.vData;
          } else {
            Uint8List? pkEphem;
            var ecpairl = ECPair.fromPrivateKey(r.sEphem!);
            try {
              pkEphem = ecpairl.publicKey;
              if (pkEphem.isEmpty) throw Exception();
            } catch (e) {
              throw InvalidEphemeralPubKey('Ephemeral pubkey is not valid');
            }
            LightwalletTransactionBuilder.setCTOutVData(
                txout, pkEphem, r.nStealthPrefix ?? 0);
          }

          txout.scriptPubKey = r.scriptPubKey;
        }
        break;
      case OutputTypes.OUTPUT_RINGCT:
        {
          Uint8List? pkEphem;
          var ecpairl = ECPair.fromPrivateKey(r.sEphem!);
          try {
            pkEphem = ecpairl.publicKey;
            if (pkEphem.isEmpty) throw Exception();
          } catch (e) {
            throw InvalidEphemeralPubKey('Ephemeral pubkey is not valid');
          }
          txbout = LightwalletTransactionBuilder.createOutputRingCT(
              r.pkTo!, r.nStealthPrefix ?? 0, pkEphem);
        }
        break;
      default:
        throw UnknownOutputType('Unknown output type ${r.nType}');
    }

    return txbout;
  }

  static int countLeadingZeros(BigInt nValueIn) {
    //int
    var nZeros = 0;

    for (var i = 0; i < 64; ++i, nValueIn >>= 1) {
      // TO-DO?
      if ((nValueIn & BigInt.one) != BigInt.zero) {
        break;
      }
      nZeros++;
    }

    return nZeros;
  }

  static int countTrailingZeros(BigInt nValueIn) {
    //int
    var nZeros = 0;

    var mask = (BigInt.one) << 63;
    for (var i = 0; i < 64; ++i, nValueIn <<= 1) {
      if ((nValueIn & mask) != BigInt.zero) {
        break;
      }
      nZeros++;
    }

    return nZeros;
  }

  static BigInt ipow(BigInt base, BigInt exp) //int64_t
  {
    var result = BigInt.one;
    while (exp > BigInt.zero) {
      if ((exp & BigInt.one) != BigInt.zero) {
        result *= base;
      }
      exp >>= 1;
      base *= base;
    }
    return result;
  }

  static selectRangeProofParameters(
      int nValueIn, NumPass minValue, NumPass exponent, NumPass nBits) {
    // int
    var nLeadingZeros = (LightwalletTransactionBuilder.countLeadingZeros(
        BigInt.from(nValueIn)));
    var nTrailingZeros = (LightwalletTransactionBuilder.countTrailingZeros(
        BigInt.from(nValueIn)));

    var nBitsReq = 64 - nLeadingZeros - nTrailingZeros;

    nBits.num = 32;

    // TODO: output rangeproof parameters should depend on the parameters of the inputs
    // TODO: drop low value bits to fee

    if (nValueIn == 0) {
      exponent.num = LightwalletTransactionBuilder.getRandInt(5);
      if (LightwalletTransactionBuilder.getRandInt(10) == 0) {
        // sometimes raise the exponent
        nBits.num += LightwalletTransactionBuilder.getRandInt(5);
      }
      return 0;
    }

    var nTest = nValueIn;
    var nDiv10 = 0; // max exponent
    for (nDiv10 = 0; nTest % 10 == 0; nDiv10++, nTest ~/= 10) {}

    // TODO: how to pick best?

    var eMin = nDiv10 / 2;
    exponent.num = double.parse((eMin +
                LightwalletTransactionBuilder.getRandInt(
                    double.parse((nDiv10 - eMin).toString()).round()))
            .toString())
        .round();

    nTest = nValueIn ~/
        LightwalletTransactionBuilder.ipow(
                BigInt.from(10), BigInt.from(exponent.num))
            .toInt();

    nLeadingZeros =
        LightwalletTransactionBuilder.countLeadingZeros(BigInt.from(nTest));
    nTrailingZeros =
        LightwalletTransactionBuilder.countTrailingZeros(BigInt.from(nTest));

    nBitsReq = 64 - nTrailingZeros;

    if (nBitsReq > 32) {
      nBits.num = nBitsReq;
    }
    ;

    // make multiple of 4
    while (nBits.num < 63 && nBits.num % 4 != 0) {
      nBits.num++;
    }

    return 0;
  }

  static bool lightWalletAddCTData(
      CMutableTransaction txNew,
      List<CTempRecipient> vecSend,
      NumPass nFeeReturned,
      NumPass nValueOutPlain,
      NumPass nChangePositionOut,
      int nSubtractFeeFromAmount) {
    var fFirst = BoolPass(false);
    for (var i = 0; i < vecSend.length; ++i) {
      var recipient = vecSend[i];

      // TODO - do we need this if fSubtractFeeFromAmount is never true? Keep this as we might enable that feature later
      // Only need to worry about this if fSubtractFeeFromAmount is true, which it isn't
      recipient.applySubFee(nFeeReturned.num, nSubtractFeeFromAmount, fFirst);

      var txbout = LightwalletTransactionBuilder.createOutput(recipient);

      if (recipient.nType == OutputTypes.OUTPUT_STANDARD.value) {
        nValueOutPlain.num += recipient.nAmount;
      }

      if (recipient.fChange &&
          recipient.nType == OutputTypes.OUTPUT_RINGCT.value) {
        nChangePositionOut.num = i;
      }

      recipient.n = txNew.vpout.length;
      txNew.vpout.add(txbout!);
      if (recipient.nType == OutputTypes.OUTPUT_RINGCT.value) {
        if (recipient.vBlind?.length != 32) {
          //recipient.vBlind = Buffer.alloc(32)//resize(32);
          //var bytes = randomBytes.default(32);
          recipient.vBlind = random.nextBytes(32);
        }

        //TODO  Can we take advantage of the AddCTData function? It looks like it is the exact same code, copy pasted
        //ADD CT DATA
        {
          CTxOutRingCTOr txboutRCT = txbout as CTxOutRingCTOr;
          var pCommitment = txboutRCT.commitment;
          var pvRangeproof = txboutRCT.vRangeproof;

          /*if (!pCommitment) {// || !pvRangeproof) {
                        throw Exception("Unable to get CT pointers for output type");
                    }*/
          pCommitment = Uint8List(32); // Buffer.alloc(32);

          var nValue = recipient.nAmount;
          //var rustsecp256k1_v0_4_1_generator *gen = rustsecp256k1_v0_4_1_generator_h;
          var pcres = ecc.pedersenCommit(
              pCommitment, recipient.vBlind!, BigInt.from(nValue));
          if (pcres == null) {
            throw PedersenCommitFailed('Pedersen commit failed');
          }
          pCommitment = pcres.commitment;

          Uint8List? nonce;
          if (recipient.fNonceSet) {
            nonce = recipient.nonce;
          } else {
            // TO-DO
            /*if (!recipient.sEphem.IsValid()) {
                            errorMsg = "Invalid ephemeral key.";
                            return false;
                        }
                        if (!recipient.pkTo.IsValid()) {
                            errorMsg = "Invalid recipient public key.";
                            return false;
                        }*/
            //nonce = recipient.sEphem.ECDH(recipient.pkTo);
            var nonceRes = ecc.ECDH_VEIL(recipient.pkTo!, recipient.sEphem!);

            //var hasher = new Hash();
            //hasher.update(nonceRes!, 32);
            //var nonceHashed = hasher.digest();
            var nonceHashed = SHA256Digest().process(nonceRes!);

            //recipient.fNonceSet = true; //TO-DO
            recipient.nonce = nonceHashed; //Buffer.from(nonceHashed);
            nonce = recipient.nonce;
          }

          List<int> list = (recipient.sNarration ?? '').codeUnits;
          Uint8List message = Uint8List.fromList(list);
          //var message = Uint8List. Buffer.from(recipient.sNarration ?? "");
          var mlen = message.lengthInBytes;

          var nRangeProofLen = 5134;
          //pvRangeproof.resize(nRangeProofLen);
          pvRangeproof =
              Uint8List(nRangeProofLen); // Buffer.alloc(nRangeProofLen);

          var min_value_ref = NumPass(0); //uint64_t
          var ct_exponent_ref = NumPass(2); //int
          var ct_bits = NumPass(32); //int

          if (0 !=
              LightwalletTransactionBuilder.selectRangeProofParameters(
                  nValue, min_value_ref, ct_exponent_ref, ct_bits)) {
            throw FailedToSelectRangeProofParameters(
                'Failed to select range proof parameters.');
          }

          if (recipient.fOverwriteRangeProofParams == true) {
            min_value_ref.num = recipient.min_value ?? 0;
            ct_exponent_ref.num = recipient.ct_exponent ?? 0;
            ct_bits.num = recipient.ct_bits ?? 0;
          }

          var rpres = ecc.rangeproofSign(
              pvRangeproof,
              nRangeProofLen,
              BigInt.from(min_value_ref.num),
              pCommitment,
              recipient.vBlind!,
              nonce!,
              ct_exponent_ref.num,
              ct_bits.num,
              BigInt.from(nValue),
              message,
              mlen);
          if (rpres == null) {
            throw FailedToSignRangeProof('Failed to sign range proof.');
          }

          pvRangeproof = rpres.proof;

          /*if (1 != secp256k1_rangeproof_sign(secp256k1_ctx_blind,
                                                   & (* pvRangeproof)[0], & nRangeProofLen,
                        min_value_ref.num, pCommitment,
                                                   & recipient.vBlind[0], nonce.begin(),
                        ct_exponent, ct_bits, nValue,
                        (const unsigned char *) message, mlen,
                        nullptr, 0, secp256k1_generator_h)) {
                    }*/
          //pvRangeproof = resizeBuf(pvRangeproof, nRangeProofLen);
          //pvRangeproof.resize(nRangeProofLen);
          txboutRCT.vRangeproof = pvRangeproof;
          txboutRCT.commitment = pCommitment;
          var xt = ecc.rangeProofVerify(
              txboutRCT.commitment!, txboutRCT.vRangeproof!);
          if (xt != 1) {
            throw FailedToSignRangeProof('Failed to sign range proof.');
          }
        }
      }
    }

    return true;
  }

  static bool lightWalletAddRealOutputs(
      CMutableTransaction txNew,
      List<CWatchOnlyTxWithIndex> vSelectedTxes,
      List<Uint8List> vInputBlinds,
      List<int> vSecretColumns,
      List<List<List<int>>> vMI) {
    List<int> setHave = []; //sort
    var nTotalInputs = 0;
    for (var l = 0; l < txNew.vin.length; ++l) {
      // Must add real outputs to setHave before picking decoys
      var txin = txNew.vin[l];
      var nSigInputs = NumPass(0);
      var nSigRingSize = NumPass(0);
      txin.getAnonInfo(nSigInputs, nSigRingSize);

      //vInputBlinds[l] = Buffer.from(vInputBlinds[l], 32 * nSigInputs.num);
      vInputBlinds[l] = resizeBuf(vInputBlinds[l], 32 * nSigInputs.num);
      //vInputBlinds[l].resize(32 * nSigInputs);

      //vCoins<txid, array index>
      List<CWatchOnlyTxWithIndex> vCoins = [];
      for (var i = nTotalInputs; i < nTotalInputs + nSigInputs.num; i++) {
        vCoins.add(vSelectedTxes[i]);
      }
      nTotalInputs += nSigInputs.num;
      //var currentSize = /*nTotalInputs +*/ nSigInputs.num;

      // Placing real inputs
      {
        if (nSigRingSize.num < 3 || nSigRingSize.num > 32) {
          throw RingSizeOutOfRange('Ring size out of range');
        }

        vSecretColumns[l] =
            LightwalletTransactionBuilder.getRandInt(nSigRingSize.num);

        vMI[l] = resizeNumArr<List<int>>(vMI[l], vCoins.length, []);
        //vMI[l].resize(currentSize);

        for (var k = 0; k < vCoins.length /*vSelectedTxes.length*/; ++k) {
          vMI[l][k] = resize(vMI[l][k], nSigRingSize.num, 0);
          //vMI[l][k].resize(nSigRingSize);
          for (var i = 0; i < nSigRingSize.num; ++i) {
            if (i == vSecretColumns[l]) {
              var vSelectedTx = vCoins[k];
              //var coin = vSelectedTx;
              /*var txhash = */ vSelectedTx.getTxHash();

              /*var pk = */ vSelectedTx.getRingCtOut()?.getPubKey();
              //CCmpPubKey pk = vSelectedTxes[k].ringctout.pk;
              //    memcpy(& vInputBlinds[l][k * 32], & vSelectedTxes[k].blind, 32);
              /*for (var ctr = 0; ctr < 32; ctr++) {
                                vInputBlinds[l][k * 32] = pk![i];
                            }*/
              //vInputBlinds[l].set(pk!.subarray(0, 32), k * 32);//1,33?
              vInputBlinds[l]
                  .setAll(k * 32, vSelectedTx.getRingCtOut()!.getBlind()!);

              var index = vSelectedTx.getRingCtIndex()!;

              if (setHave.contains(index)) {
                throw DuplicateIndexFound('Duplicate index found');
              }

              vMI[l][k][i] = index;
              setHave.add(index);
            }
          }
        }
      }
    }
    return true;
  }

  static void lightWalletFillInDummyOutputs(
      CMutableTransaction txNew,
      List<CLightWalletAnonOutputData> vDummyOutputs,
      List<int> vSecretColumns,
      List<List<List<int>>> vMI) {
    // Fill in dummy signatures for fee calculation.
    var knownIndexes = List.empty(growable: true);
    var knownAnonIndexes = List.empty(growable: true);
    for (var l = 0; l < txNew.vin.length; ++l) {
      var txin = txNew.vin[l];
      var nSigInputs = NumPass(0);
      var nSigRingSize = NumPass(0);
      txin.getAnonInfo(nSigInputs, nSigRingSize);

      for (var k = 0; k < vMI[l].length; ++k) {
        for (var i = 0; i < nSigRingSize.num; ++i) {
          if (i == vSecretColumns[l]) {
            knownIndexes.add(vMI[l][k][i]);
            continue;
          }
        }
      }
    }

    var nCurrentLocation = 0;
    for (var l = 0; l < txNew.vin.length; ++l) {
      var txin = txNew.vin[l];
      var nSigInputs = NumPass(0);
      var nSigRingSize = NumPass(0);
      txin.getAnonInfo(nSigInputs, nSigRingSize);

      // Place Hiding Outputs
      {
        //var nCurrentLocation = 0;
        for (var k = 0; k < vMI[l].length; ++k) {
          for (var i = 0; i < nSigRingSize.num; ++i) {
            if (i == vSecretColumns[l]) {
              continue;
            }
            //console.log(`looking at vector index :${nCurrentLocation}, setting index for dummy: ${vDummyOutputs[nCurrentLocation].getIndex()}`);
            //LogPrintf("looking at vector index :%d, setting index for dummy: %d\n", nCurrentLocation, vDummyOutputs[nCurrentLocation].index);
            var indexTemp = vDummyOutputs[nCurrentLocation].getIndex()!;
            if (knownIndexes.contains(indexTemp)) {
              throw Exception('Found duplicate index: $indexTemp');
            }
            if (knownAnonIndexes.contains(indexTemp)) {
              throw Exception('Found duplicate index: $indexTemp');
            }
            knownAnonIndexes.add(indexTemp);
            vMI[l][k][i] = indexTemp;
            nCurrentLocation++;
          }
        }
      }

      //var buf = Buffer.alloc(20000);//???
      var writer = BufferWriter();

      for (var k = 0; k < nSigInputs.num; ++k) {
        for (var i = 0; i < nSigRingSize.num; ++i) {
          //writer.writeVarInt(vMI[l][k][i]);
          //writer.writeSlice(putVarInt(vMI[l][k][i]));
          writer.customVarInt(vMI[l][k][i]);
        }
      }
      var vPubkeyMatrixIndices =
          writer.getBuffer(); // subarray(0, writer.offset);

      var vKeyImages = Uint8List(33 * nSigInputs.num);

      txin.scriptData.stack.add(vKeyImages);
      txin.scriptWitness.stack.add(vPubkeyMatrixIndices);

      var vDL = Uint8List((1 + (nSigInputs.num + 1) * nSigRingSize.num) *
              32 // extra element for C, extra row for commitment row
          +
          (txNew.vin.length > 1
              ? 33
              : 0)); // extra commitment for split value if multiple sigs
      txin.scriptWitness.stack.add(vDL);
    }
  }

  static bool lightWalletUpdateChangeOutputCommitment(
      CMutableTransaction txNew,
      List<CTempRecipient> vecSend,
      NumPass nChangePositionOut,
      List<Uint8List> vpOutCommits,
      List<Uint8List> vpOutBlinds) {
    // Update the change output commitment
    for (var i = 0; i < vecSend.length; ++i) {
      var r = vecSend[i];

      if (i == nChangePositionOut.num) {
        // Change amount may have changed

        if (r.nType != OutputTypes.OUTPUT_RINGCT.value) {
          throw ChangeAddressIsNotStealth('Change output is not RingCT type.');
        }

        if (r.vBlind?.length != 32) {
          r.vBlind = random.nextBytes(32); // randomBytes.default(32);
          //GetStrongRandBytes(& r.vBlind[0], 32);
        }

        {
          var txout = txNew.vpout[r.n ?? 0] as CTxOutCT; //CTxOutBase

          var pCommitment = txout.commitment;
          var pvRangeproof = txout.vRangeproof; //GetPRangeproof

          if (pCommitment == null || pvRangeproof == null) {
            throw FailedToGetCTPointersForOutputType(
                'Unable to get CT pointers for output type');
          }

          var nValue = r.nAmount;
          var pdcRes =
              ecc.pedersenCommit(pCommitment, r.vBlind!, BigInt.from(nValue));
          if (pdcRes == null) {
            throw PedersenCommitFailed('Pedersen commit failed.');
          }
          pCommitment = pdcRes.commitment;
          txout.commitment = pCommitment; //!!!!

          var nonce = Uint8List(32); // Buffer.alloc(32);
          if (r.fNonceSet) {
            nonce = r.nonce!;
          } else {
            //TO-DO
            /*if (!r.sEphem.IsValid()) {
                            errorMsg = "Invalid ephemeral key";
                            return false;
                        }
                        if (!r.pkTo.IsValid()) {
                            errorMsg = "Invalid recipient public key";
                            return false;
                        }*/
            var preNonce = ecc.ECDH_VEIL(r.pkTo!, r.sEphem!);

            /*var hasher = new Hash();
                        hasher.update(preNonce!, 32);
                        nonce = Buffer.from(hasher.digest());*/
            nonce = SHA256Digest().process(preNonce!);
            r.nonce = nonce;
          }

          //var message = Buffer.from(r.sNarration ?? "");
          List<int> list = (r.sNarration ?? '').codeUnits;
          Uint8List message = Uint8List.fromList(list);

          var mlen = message.length;
          var nRangeProofLen = 5134;
          if (pvRangeproof.length >= nRangeProofLen) {
            pvRangeproof = pvRangeproof.sublist(0, nRangeProofLen);
          } else {
            var nlist = Uint8List(nRangeProofLen);
            nlist.setAll(0, pvRangeproof);
            pvRangeproof = nlist;
          }

          var min_value = NumPass(0);
          var ct_exponent = NumPass(2);
          var ct_bits = NumPass(32);

          if (0 !=
              LightwalletTransactionBuilder.selectRangeProofParameters(
                  nValue, min_value, ct_exponent, ct_bits)) {
            throw FailedToSelectRangeProofParameters(
                'Failed to select range proof parameters.');
          }

          if (r.fOverwriteRangeProofParams == true) {
            min_value.num = r.min_value!;
            ct_exponent.num = r.ct_exponent!;
            ct_bits.num = r.ct_bits!;
          }

          var rpres = ecc.rangeproofSign(
              pvRangeproof,
              nRangeProofLen,
              BigInt.from(min_value.num),
              pCommitment,
              r.vBlind!,
              nonce,
              ct_exponent.num,
              ct_bits.num,
              BigInt.from(nValue),
              message,
              mlen);
          if (rpres == null) {
            throw FailedToSignRangeProof('Failed to sign range proof.');
          }
          //pvRangeproof = resizeBuf(pvRangeproof, nRangeProofLen);
          pvRangeproof = rpres.proof;
          txout.vRangeproof = pvRangeproof;
          var xt = ecc.rangeProofVerify(txout.commitment!, txout.vRangeproof!);
          if (xt != 1) {
            throw FailedToSignRangeProof('Failed to sign range proof.');
          }
        }
      }

      if (r.nType == OutputTypes.OUTPUT_CT.value ||
          r.nType == OutputTypes.OUTPUT_RINGCT.value) {
        CTxOutCT txCt = txNew.vpout[r.n!] as CTxOutCT;
        vpOutCommits.add(txCt.commitment!); //  -> GetPCommitment() -> data);
        vpOutBlinds.add(r.vBlind!);
      }
    }

    return true;
  }

  static bool lightWalletInsertKeyImages(
      CMutableTransaction txNew,
      Map<int, Uint8List> vSigningKeys,
      List<CWatchOnlyTxWithIndex> vSelectedTxes,
      List<int> vSecretColumns,
      List<List<List<int>>> vMI,
      Uint8List spend_pubkey,
      Uint8List scan_secret,
      Uint8List spend_secret) {
    //var rv = 0;
    for (var l = 0; l < txNew.vin.length; ++l) {
      var txin = txNew.vin[l];

      var nSigInputs = NumPass(0);
      var nSigRingSize = NumPass(0);
      txin.getAnonInfo(nSigInputs, nSigRingSize);

      var vKeyImages = txin.scriptData.stack[0];
      var vkiTemp = Uint8List(33 * nSigInputs.num);
      vkiTemp.setAll(0, vKeyImages);
      vKeyImages = vkiTemp;

      for (var k = 0; k < nSigInputs.num; ++k) {
        var i = vSecretColumns[l];
        var nIndex = vMI[l][k][i];

        //var vchEphemPK = Uint8List(33);
        CWatchOnlyTxWithIndex? foundTx;

        for (var tx in vSelectedTxes) {
          if (tx.getRingCtIndex() == nIndex) {
            //vchEphemPK = Buffer.from(tx.getRingCtOut()!.getVData()!, 33);
            /*vchEphemPK = */ resizeBuf(tx.getRingCtOut()!.getVData()!, 33);
            //memcpy(& vchEphemPK[0], & tx.ringctout.vData[0], 33);
            //LogPrintf("Found the correct outpoint to generate vchEphemPK for index %d\n", nIndex);
            //console.log(`Found the correct outpoint to generate vchEphemPK for index ${nIndex}`);
            foundTx = tx;
            break;
          }
        }

        /*CKey sShared;
                ec_point pkExtracted;
                ec_point ecPubKey;
                    SetPublicKey(spend_pubkey, ecPubKey);*/
        //var ecPubKey = Stealth.setPublicKey(spend_pubkey);

        var keyDestination =
            LightwalletTransactionBuilder.getDestinationKeyForOutput(
                foundTx!, spend_secret, scan_secret, spend_pubkey);
        if (keyDestination.length == 0) {
          throw KeyImagesFailed('Failed on keyimages');
        }
        vSigningKeys[foundTx.getRingCtIndex()!] = keyDestination;

        // Keyimage is required for the tx hash
        var keyImage = ecc.getKeyImage(
            foundTx.getRingCtOut()!.getPubKey()!, keyDestination);
        //var keyImageOr = foundTx.getRingCtOut()?.getKeyImage(); keyimage should be same as this
        if (keyImage == null) {
          throw KeyImagesFailed('Failed to get keyimage');
        }

        vKeyImages.setAll(k * 33, keyImage);
      }

      txin.scriptData.stack[0] = vKeyImages;
    }

    return true;
  }

  static bool lightWalletSignAndVerifyTx(
      CMutableTransaction txNew,
      List<Uint8List> vInputBlinds,
      List<Uint8List> vpOutCommits,
      List<Uint8List> vpOutBlinds,
      List<Uint8List> vSplitCommitBlindingKeys,
      Map<int, Uint8List> vSigningKeys,
      List<CLightWalletAnonOutputData> vDummyOutputs,
      List<CWatchOnlyTxWithIndex> vSelectedTx,
      List<int> vSecretColumns,
      List<List<List<int>>> vMI) {
    var nTotalInputs = 0;
    var rv = 0;

    for (var l = 0; l < txNew.vin.length; ++l) {
      var txin = txNew.vin[l];

      var nSigInputs = NumPass(0);
      var nSigRingSize = NumPass(0);
      txin.getAnonInfo(nSigInputs, nSigRingSize);

      var nCols = nSigRingSize;
      var nRows = nSigInputs.num + 1;

      var randSeed = random.nextBytes(32);

      List<Uint8List> vsk = createArrayBuf(nSigInputs.num, 32);
      List<Uint8List> vpsk = createArrayBuf(nRows, 32);

      var vm = Uint8List(nCols.num * nRows * 33);
      List<Uint8List> vCommitments =
          createArrayBuf(nCols.num * nSigInputs.num, 33);
      //vCommitments.fill(ebuf, 0, nCols.num * nSigInputs.num);
      //std:: vector < secp256k1_pedersen_commitment > vCommitments;
      //vCommitments.reserve(nCols * nSigInputs);

      List<Uint8List> vpInCommits =
          createArrayBuf(nCols.num * nSigInputs.num, 33); // TO-DO
      //vpsk.fill(ebuf, 0, nCols.num * nSigInputs.num);
      //std:: vector <const uint8_t *> vpInCommits(nCols * nSigInputs);

      List<Uint8List> vpBlinds = [];
      //std:: vector <const uint8_t *> vpBlinds;

      var vKeyImages = txin.scriptData.stack[0];

      //LogPrintf("nSigInputs %d , nCols %d\n", nSigInputs, nCols);
      //console.log(`nSigInputs ${nSigInputs.num} , nCols ${nCols.num}`);
      for (var k = 0; k < nSigInputs.num; ++k) {
        for (var i = 0; i < nCols.num; ++i) {
          var nIndex = vMI[l][k][i];

          // Actual output
          if (i == vSecretColumns[l]) {
            var fFoundKey = false;
            for (var index in vSigningKeys.keys) {
              var first = index;
              var second = vSigningKeys[index];
              if (first == nIndex) {
                vsk[k] = second!;
                fFoundKey = true;
                break;
              }
            }

            if (!fFoundKey) {
              throw NoKeyFoundForIndex('No key for index');
              //return false;
            }

            vpsk[k] = vsk[k];

            vpBlinds.add(vInputBlinds[l]
                .sublist(k * 32, k * 32 + 32)); //vInputBlinds[l][k * 32]);

            var fFound = false;
            for (var tx in vSelectedTx) {
              if (tx.getRingCtIndex() == nIndex) {
                fFound = true;
                var pk = tx.getRingCtOut()?.getPubKey();
                vm.setAll((i + k * nCols.num) * 33, pk!);
                //memcpy(& vm[(i + k * nCols) * 33], tx.ringctout.pk.begin(), 33);
                vCommitments.add(tx.getRingCtOut()!.getCommitment()!);
                vpInCommits[i + k * nCols.num] =
                    vCommitments[vCommitments.length - 1];
                break;
              }
            }

            if (!fFound) {
              throw NoPubKeyFound('No pubkey found for real output');
              //return false;
            }
          } else {
            var fFound = false;
            for (var item in vDummyOutputs) {
              if (item.getIndex() == nIndex) {
                fFound = true;
                var pk = item.getOutput()?.getPubKey();
                vm.setAll((i + k * nCols.num) * 33, pk!);
                //memcpy(& vm[(i + k * nCols) * 33], item.output.pubkey.begin(), 33);
                vCommitments.add(item.getOutput()!.getCommitment()!);
                vpInCommits[i + k * nCols.num] =
                    vCommitments[vCommitments.length - 1];
                break;
              }
            }

            if (!fFound) {
              //LogPrintf("Couldn't find dummy index for nIndex=%d\n", nIndex);
              throw NoPubKeyFound('No pubkey found for dummy output');
              //return false;
            }
          }
        }
      }

      var blindSum = Uint8List(32);
      vpsk[nRows - 1] = blindSum;

      var vDL = txin.scriptWitness.stack[1];

      if (txNew.vin.length == 1) {
        var tmpvDL =
            Uint8List((1 + (nSigInputs.num + 1) * nSigRingSize.num) * 32);
        tmpvDL.setAll(0, vDL);
        vDL = tmpvDL;
        //vDL = Buffer.from(vDL, (1 + (nSigInputs.num + 1) * nSigRingSize.num) * 32);
        //vDL.resize((1 + (nSigInputs + 1) * nSigRingSize) * 32); // extra element for C, extra row for commitment row
        vpBlinds = vpBlinds + vpOutBlinds;
        //vpBlinds.insert(vpBlinds.end(), vpOutBlinds.begin(), vpOutBlinds.end());

        var rprres = ecc.prepareMlsag(
            vm,
            blindSum,
            vpOutCommits.length,
            vpOutCommits.length,
            /*added */ vpInCommits.length,
            vpBlinds.length,
            /*end */ nCols.num,
            nRows,
            vpInCommits,
            vpOutCommits,
            vpBlinds);
        rv = rprres != null ? 0 : 1;
        if (0 != rv) {
          throw FailedToPrepareMlsag('Failed to prepare mlsag');
        }
        vpsk[nRows - 1] = rprres!
            .SK; // reset to returned blindsum? from secp256k1_prepare_mlsag
        vm = rprres.M; // reset vm to returned m from secp256k1_prepare_mlsag
      } else {
        // extra element for C extra, extra row for commitment row, split input commitment
        var tmpvDL =
            Uint8List((1 + (nSigInputs.num + 1) * nSigRingSize.num) * 32 + 33);
        tmpvDL.setAll(0, vDL);
        vDL = tmpvDL;
        //vDL = Buffer.from(vDL, (1 + (nSigInputs.num + 1) * nSigRingSize.num) * 32 + 33);
        //vDL.resize((1 + (nSigInputs + 1) * nSigRingSize) * 32 + 33);

        if (l == txNew.vin.length - 1) {
          var vpAllBlinds = vpOutBlinds;

          for (var k = 0; k < l; ++k) {
            vpAllBlinds.add(vSplitCommitBlindingKeys[k]);
          }

          var res = ecc.pedersenBlindSum(vSplitCommitBlindingKeys[l],
              vpAllBlinds, vpAllBlinds.length, vpOutBlinds.length);

          if (res == null) {
            throw PedersenBlindSumFailed('Pedersen blind sum failed.');
          }
          vSplitCommitBlindingKeys[l] =
              res; // got from secp256k1_pedersen_blind_sum
        } else {
          //ECPair.makeRandom().privateKey!;
          //Buffer.alloc(32); - work for some reason
          // TO-DO should be this.makeNewKey(true)
          var zeros = Uint8List(32);
          zeros.fillRange(0, 32, 0x00);
          vSplitCommitBlindingKeys[l] =
              zeros; //Uint8List(32); //makeNewKey(true);
          //Uint8List(32); //Buffer.alloc(32);//this.makeNewKey(true);// Buffer.alloc(32);// this.makeNewKey(true);// ECPair.makeRandom({ compressed: true }).privateKey!;//.MakeNewKey(true);
        }

        var nCommitValue = 0;
        for (var k = 0; k < nSigInputs.num; k++) {
          var coin = vSelectedTx[nTotalInputs + k];
          nCommitValue += coin.getRingCtOut()!.getAmount()!.toInt();
        }

        nTotalInputs += nSigInputs.num;

        /*
                CAmount nCommitValue = 0;
                    for (size_t k = 0; k < nSigInputs; ++k) {
                        const auto &coin = setCoins[nTotalInputs+k];
                        const COutputRecord *oR = coin.first->second.GetOutput(coin.second);
                        nCommitValue += oR->GetAmount();
                    }

                    nTotalInputs += nSigInputs;
                */

        var splitInputCommit = Uint8List(33); // Buffer.alloc(33);
        var commres = ecc.pedersenCommit(splitInputCommit,
            vSplitCommitBlindingKeys[l], BigInt.from(nCommitValue));

        if (commres == null) {
          throw PedersenCommitFailed('Pedersen commit failed.');
        }
        splitInputCommit =
            commres.commitment; // set from secp256k1_pedersen_commit
        vSplitCommitBlindingKeys[l] =
            commres.blind; // set from secp256k1_pedersen_commit

        vDL.setAll((1 + (nSigInputs.num + 1) * nSigRingSize.num) * 32,
            splitInputCommit);
        //memcpy(& vDL[(1 + (nSigInputs + 1) * nSigRingSize) * 32], splitInputCommit.data, 33);
        vpBlinds.add(vSplitCommitBlindingKeys[l]);

        var pSplitCommits = [splitInputCommit];
        // size_t nOuts, size_t nBlinded, /* added */ size_t vpInCommitsLen, size_t vpBlindsLen, /* end */ size_t nCols, size_t nRows,
        var rprres = ecc.prepareMlsag(
            vm,
            blindSum,
            1,
            1,
            /*added */ vpInCommits.length,
            vpBlinds.length,
            /*end */ nCols.num,
            nRows,
            vpInCommits,
            pSplitCommits,
            vpBlinds);
        rv = rprres != null ? 0 : 1;
        if (0 != rv) {
          throw FailedToPrepareMlsag('Failed to prepare mlsag with');
        }

        vpsk[nRows - 1] = rprres!
            .SK; // reset to returned blindsum? from secp256k1_prepare_mlsag
        vm = rprres.M; // reset vm to returned m from secp256k1_prepare_mlsag

        //vpBlinds.pop();
        vpBlinds.removeLast();
      }

      var hashOutputs = txNew.getOutputsHash();
      var res = ecc.generateMlsag(
          vKeyImages,
          vDL,
          vDL.sublist(32),
          randSeed,
          hashOutputs,
          nCols.num,
          nRows,
          vSecretColumns[l],
          vpsk.length,
          vpsk,
          vm);
      /*
            secp256k1_generate_mlsag(& vKeyImages[0], & vDL[0], & vDL[32],
                randSeed, hashOutputs, nCols, nRows, vSecretColumns[l], vpsk.length,
                vpsk, vm)
            */
      if (res == null) {
        throw FailedToGenerateMlsag('Failed to generate mlsag');
      }
      vKeyImages = res.KI;
      vDL.setAll(0, res.PC);
      vDL.setAll(32, res.PS);

      // Validate the mlsag
      rv = ecc.verifyMlsag(
          hashOutputs, nCols.num, nRows, vm, vKeyImages, vDL, vDL.sublist(32));
      if (0 != rv) {
        throw FailedToGenerateMlsag(
            'Failed to generate mlsag on initial generation');
      }

      txin.scriptData.stack[0] = vKeyImages;
      txin.scriptWitness.stack[1] = vDL;
    }

    return true;
  }

  static Uint8List makeNewKey(bool compressed) {
    Uint8List buf;
    do {
      buf = random.nextBytes(32);
    } while (!ecc.seckeyVerify(buf)); //  !Check(keydata.data()));
    return buf;
  }
}
