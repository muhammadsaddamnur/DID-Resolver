// import 'package:pinenacl/ed25519.dart';

import 'dart:developer';
import 'dart:typed_data';
// import 'package:convert/convert.dart';
import 'package:eth_sig_util/util/keccak.dart' as eth_sig_util;
// import 'package:eth_sig_util/util/utils.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Solidity {
  Uint8List solidityKeccak256(List<dynamic> values) {
    final list = <int>[];

    for (final value in values) {
      if (value is Uint8List) {
        list.addAll(value);
      }
      if (value is String) {
        list.addAll(Uint8List.fromList(value.codeUnits));
      }
      if (value is int) {
        final bytes = ByteData(32);
        bytes.setInt32(bytes.lengthInBytes - 4, value);

        final response = bytes.buffer.asInt8List().toList();
        list.addAll(Uint8List.fromList(response));
      }
    }

    final res = keccak256(Uint8List.fromList(list));
    return res;
  }

  Uint8List solidityPack(List<dynamic> values) {
    final list = <String>['0x1900'];
    for (final value in values) {
      if (value is Uint8List) {
        list.add(bytesToHex(value));
      }
      if (value is String) {
        list.add(bytesToHex(value.codeUnits));
      }
      if (value is EthereumAddress) {
        list.add(bytesToHex(hexToBytes(value.hex)));
      }
      if (value is int) {
        final bytes = ByteData(32);
        bytes.setInt32(bytes.lengthInBytes - 4, value);

        final response = bytes.buffer.asInt8List().toList();
        list.add(bytesToHex(Uint8List.fromList(response)));
      }
    }
    log(list.toString());
    return hexToBytes(list.join(',').replaceAll(',', ''));
  }
}
