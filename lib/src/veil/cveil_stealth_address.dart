// ignore_for_file: constant_identifier_names, non_constant_identifier_names, camel_case_types

import "dart:typed_data";

import "package:veil_light_plugin/src/veil/chainparams.dart";
import 'package:veil_light_plugin/src/core/bitcoin_dart_fix.dart';
import 'package:bech32/bech32.dart';

const MAX_STEALTH_NARRATION_SIZE = 48;
const MIN_STEALTH_RAW_SIZE = 1 + 33 + 1 + 33 + 1 + 1;
const EC_SECRET_SIZE = 32;
const EC_COMPRESSED_SIZE = 33;
const EC_UNCOMPRESSED_SIZE = 65;

class stealth_prefix {
  int number_bits;
  int bitfield;

  stealth_prefix(this.number_bits, this.bitfield);
}

class CVeilStealthAddress {
  Uint8List? data;
  bool isValid = false;

  int options = 0;
  stealth_prefix prefix = stealth_prefix(0, 0);
  int number_signatures = 0;
  Uint8List? scan_secret;
  Uint8List? scan_pubkey;
  Uint8List? spend_pubkey;
  Uint8List? spend_secret_id;

  void fromData(Uint8List scan_secret, Uint8List scan_pub,
      Uint8List spend_secret_id, Uint8List spend_pub, int number_bits) {
    this.scan_secret = scan_secret;
    scan_pubkey = scan_pub;
    this.spend_secret_id = spend_secret_id;
    spend_pubkey = spend_pub;
    prefix.number_bits = number_bits;
    isValid = true;
  }

  void fromBuffer(Uint8List buffer) {
    data = buffer;
    var nSize = buffer.length;
    if (nSize < MIN_STEALTH_RAW_SIZE) {
      return;
    }

    var index = 0;
    options = buffer[index++];

    scan_pubkey = buffer.sublist(index, index + EC_COMPRESSED_SIZE);
    index += EC_COMPRESSED_SIZE;
    var spend_pubkeys = buffer[index++];

    if (nSize <
        MIN_STEALTH_RAW_SIZE + EC_COMPRESSED_SIZE * (spend_pubkeys - 1)) {
      return;
    }

    spend_pubkey =
        buffer.sublist(index, index + EC_COMPRESSED_SIZE * spend_pubkeys);

    index += EC_COMPRESSED_SIZE * spend_pubkeys;

    number_signatures = buffer[index++];
    prefix.number_bits = buffer[index++];
    prefix.bitfield = 0;
    var nPrefixBytes = (prefix.number_bits / 8.0).ceil();

    if (nSize <
        MIN_STEALTH_RAW_SIZE +
            EC_COMPRESSED_SIZE * (spend_pubkeys - 1) +
            nPrefixBytes) {
      return;
    }

    if (nPrefixBytes >= 1) {
      var dv = buffer.sublist(index, index + nPrefixBytes).buffer.asByteData();
      prefix.bitfield = dv.getUint32(0);
    }
    //  memcpy(&prefix.bitfield, p, nPrefixBytes);

    isValid = true;
  }

  String toBech32(Chainparams chain) {
    var buffer_cache = Uint8List(512);
    var buffer = buffer_cache.buffer.asByteData();

    var index = 0;
    buffer.setUint8(index++, options);
    //buffer.writeUInt8(options, index++);

    buffer_cache.setAll(index, scan_pubkey!);
    //buffer.set(scan_pubkey!, index);
    index += EC_COMPRESSED_SIZE;

    const spend_pubkeys = 1;
    buffer.setUint8(index++, spend_pubkeys);
    //buffer.writeUInt8(
    //    spend_pubkeys, index++); //const spend_pubkeys = buffer[index++];

    buffer_cache.setAll(index, spend_pubkey!);
    //buffer.set(spend_pubkey!, index);
    index += EC_COMPRESSED_SIZE * spend_pubkeys;

    buffer.setUint8(index++, number_signatures);
    buffer.setUint8(index++, prefix.number_bits);
    //buffer.writeUInt8(number_signatures, index++);
    //buffer.writeUInt8(prefix.number_bits, index++);

    var nPrefixBytes = (prefix.number_bits / 8.0).ceil();
    if (nPrefixBytes >= 1) {
      buffer.setUint32(index, prefix.bitfield, Endian.big);
      //buffer.writeUInt32BE(prefix.bitfield, index);
      index += 4;
    }

    var words = convertBits(buffer_cache.sublist(0, index), 8, 5, true);
    var data =
        bech32.encode(Bech32(chain.bech32Prefixes.STEALTH_ADDRESS, words), 128);

    return data;
  }
}
