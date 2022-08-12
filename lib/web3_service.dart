import 'dart:convert';
import 'dart:developer';

import 'package:eth_sig_util/util/bigint.dart';
import 'package:eth_sig_util/util/utils.dart' as eth_sig_util;
import 'package:eth_sig_util/util/bytes.dart' as eth_sig_util_bytes;
import 'package:flutter/services.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class Web3ServiceImpl {
  /// Web3AbiService factory
  factory Web3ServiceImpl() {
    return _singleton;
  }

  Web3ServiceImpl._internal();

  /// Web3AbiService singleton
  static final Web3ServiceImpl _singleton = Web3ServiceImpl._internal();

  /// web3client
  late Web3Client client;

  /// contract variables
  late DeployedContract contract;

  /// function variable
  late ContractFunction identityOwnerFunction;
  late ContractFunction nonceFunction;
  late ContractFunction setAttributeSignedFunction;

  /// abi contract variable
  dynamic abi;

  void init(String rpcUrl) {
    client = Web3Client(
      rpcUrl,
      Client(),
    );
  }

  Future<void> initContract() async {
    /// define contract
    final abiRaw = await rootBundle
        .loadString('assets/contracts/EthereumDIDRegistry.json');
    abi = await json.decode(abiRaw);
    contract = DeployedContract(
      ContractAbi.fromJson(json.encode(abi), 'did'),

      /// edge
      EthereumAddress.fromHex('0x03d5003bf0e79C5F5223588F347ebA39AfbC3818'),

      /// goerli
      // EthereumAddress.fromHex('0xdCa7EF03e98e0DC2B855bE647C39ABe984fcF21B'),
    );

    identityOwnerFunction = contract.function('identityOwner');
    nonceFunction = contract.function('nonce');
    setAttributeSignedFunction = contract.function('setAttributeSigned');
  }

  Future<String> getIdentity(String address) async {
    await initContract();
    final identityOwner = await client.call(
      contract: contract,
      function: identityOwnerFunction,
      params: [EthereumAddress.fromHex(address)],
    );
    return identityOwner.first.toString();
  }

  Future<String> getNonce(String identityOwner) async {
    await initContract();
    final nonce = await client.call(
      contract: contract,
      function: nonceFunction,
      params: [EthereumAddress.fromHex(identityOwner)],
    );
    return nonce.first.toString();
  }

  Future<Transaction> setAttributeSignedTransaction(
    EthereumAddress identity,
    // int v,
    // Uint8List r,
    // Uint8List s,
    MsgSignature msgSignature,
    Uint8List name,
    Uint8List value,
    BigInt validity,
  ) async {
    await initContract();
    // log([
    //   identity,
    //   eth_sig_util.intToHex(
    //     BigInt.from(v).toInt(),
    //   ),
    //   bytesToHex(r, include0x: true),
    //   bytesToHex(s, include0x: true),
    //   bytesToHex(name, include0x: true),
    //   bytesToHex(value, include0x: true),
    //   validity,
    // ].toString());
    // final setAttributeSigned = await client.call(
    //   sender:
    //       EthereumAddress.fromHex('0xd25D03722dE1D3E911D68adf0F50FCC039b5B00C'),
    //   contract: contract,
    //   function: setAttributeSignedFunction,
    //   params: [
    //     identity,
    //     BigInt.from(v),
    //     r,
    //     s,
    //     name,
    //     value,
    //     validity,
    //   ],
    // );

    // final setAttributeSigned = setAttributeSignedFunction.encodeCall([
    //   identity,
    //   BigInt.from(v),
    //   r,
    //   s,
    //   name,
    //   value,
    //   validity,
    // ]);

    final nonceTx = await client.getTransactionCount(
      EthereumAddress.fromHex('0xd25D03722dE1D3E911D68adf0F50FCC039b5B00C'),
      atBlock: const BlockNum.pending(),
    );

    final tx = Transaction.callContract(
      contract: contract,
      function: setAttributeSignedFunction,
      nonce: nonceTx,
      from:
          EthereumAddress.fromHex('0xd25D03722dE1D3E911D68adf0F50FCC039b5B00C'),
      value: EtherAmount.inWei(BigInt.from(0)),
      maxGas: 100000,
      gasPrice: EtherAmount.inWei(
        BigInt.from(1500000000),
      ),
      parameters: [
        identity,
        BigInt.from(msgSignature.v),
        encodeBigInt(msgSignature.r, length: 32),
        encodeBigInt(msgSignature.s, length: 32),
        eth_sig_util_bytes.setLengthRight(name, 32),
        // Uint8List.fromList(name + Uint8List(32 - name.length)),
        value,
        validity,
      ],
    );

    // log(bytesToHex(tx));

    return tx;
  }

  Future<BigInt> getPrice() async {
    return (await client.getGasPrice()).getInWei;
  }
}
