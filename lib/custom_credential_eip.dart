import 'dart:developer';
import 'dart:typed_data';
import 'package:did_demo/solidityKeccak256.dart';
import 'package:web3dart/src/crypto/secp256k1.dart' as secp256k1;
import 'package:web3dart/src/utils/typed_data.dart';

import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'tx_object_model.dart';

/// CustomCredentialEip1559
class CustomCredentialEipService extends CustomTransactionSender {
  /// CustomCredentialEip1559 constructor
  CustomCredentialEipService({
    this.privateKey,
    required this.client,
    this.chainId = 1,
    this.fetchChainIdFromNetworkId = false,
    // this.txObjectModel,
    // required this.presign,
  });

  // /// client
  final Web3Client client;

  /// privateKey
  final EthPrivateKey? privateKey;

  /// chainId
  final int? chainId;

  /// fetchChainIdFromNetworkId
  final bool fetchChainIdFromNetworkId;

  // /// txObjectModel
  // final TxObjectModel? txObjectModel;

  // /// presign
  // final String presign;

  @override
  Future<EthereumAddress> extractAddress() async {
    return privateKey!.extractAddress();
  }

  @override
  Future<String> sendTransaction(Transaction transaction) async {
    var signed = await client.signTransaction(
      this,
      transaction,
      chainId: chainId,
      fetchChainIdFromNetworkId: fetchChainIdFromNetworkId,
    );

    if (transaction.isEIP1559) {
      signed = prependTransactionType(0x02, signed);
    }
    print(signed);
    return client.sendRawTransaction(signed);
  }

  @override
  Future<MsgSignature> signToSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) async {
    print('ini signToSignature bosss');

    print('payload : ${keccak256(payload)}');

    final signature =
        secp256k1.sign(keccak256(payload), privateKey!.privateKey);
    final r = padUint8ListTo32(unsignedIntToBytes(signature.r));
    final s = padUint8ListTo32(unsignedIntToBytes(signature.s));
    final v = unsignedIntToBytes(BigInt.from(signature.v));
    log('v : ' + signature.v.toString());

    final ress = uint8ListFromList(r + s + v);
    log('signature : ' + bytesToHex(ress, include0x: true));

    // https://github.com/ethereumjs/ethereumjs-util/blob/8ffe697fafb33cefc7b7ec01c11e3a7da787fe0e/src/signature.ts#L26
    // be aware that signature.v already is recovery + 27
    int chainIdV;
    if (isEIP1559) {
      chainIdV = signature.v - 27;
    } else {
      chainIdV = chainId != null
          ? (signature.v - 27 + (chainId * 2 + 35))
          : signature.v;
    }

    print('r : ${signature.r}');
    print('s : ${signature.s}');
    print('v : $chainIdV');
    print('ecRecover :');

    final ecR1 = ecRecover(keccak256(payload),
        MsgSignature(signature.r, signature.s, signature.v));
    log('ecRecover  : ${EthereumAddress.fromPublicKey(ecR1)}');

    return MsgSignature(signature.r, signature.s, chainIdV);
  }
}
