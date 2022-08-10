import 'dart:convert';
import 'dart:developer';

import 'package:eth_sig_util/util/utils.dart' as eth_sig_util;
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
      EthereumAddress.fromHex('0xdCa7EF03e98e0DC2B855bE647C39ABe984fcF21B'),
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

  Future<Uint8List> setAttributeSigned(
    EthereumAddress identity,
    int v,
    Uint8List r,
    Uint8List s,
    Uint8List name,
    Uint8List value,
    BigInt validity,
  ) async {
    await initContract();
    log([
      identity,
      eth_sig_util.intToHex(
        BigInt.from(v).toInt(),
      ),
      bytesToHex(r, include0x: true),
      bytesToHex(s, include0x: true),
      bytesToHex(name, include0x: true),
      bytesToHex(value, include0x: true),
      validity,
    ].toString());
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
    final setAttributeSigned = setAttributeSignedFunction.encodeCall([
      identity,
      BigInt.from(v),
      r,
      s,
      name,
      value,
      validity,
    ]);

    log(bytesToHex(setAttributeSigned));

    return setAttributeSigned;
  }

  Future<BigInt> getPrice() async {
    return (await client.getGasPrice()).getInWei;
  }
}
