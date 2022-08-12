import 'dart:convert';
import 'dart:developer';

import 'package:did_demo/check_user_did.dart';
import 'package:did_demo/generate_controller_key.dart';
import 'package:did_demo/generate_device_key.dart';
import 'package:did_demo/web3_service.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:eth_sig_util/util/utils.dart' as eth_sig_util;
import 'package:flutter/material.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart';
import 'construct_did.dart';
import 'custom_credential_eip.dart';
import 'solidityKeccak256.dart';
import 'tx_object_model.dart';
import 'package:eth_sig_util/util/abi.dart' as abi;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AsymmetricPublicKey? devicePubKey;
  EthPrivateKey? controllerKey;
  String? userDID;
  String? resolverDID;
  bool resolverLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DID Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Device key (ED25519) : ' +
                        (devicePubKey == null
                            ? ''
                            : bytesToHex(devicePubKey!.asTypedList)),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Controller key (secp256k1) : ' +
                        (controllerKey == null
                            ? ''
                            : bytesToHex(
                                controllerKey!.privateKey,
                              )),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Address (secp256k1) : ' +
                        (controllerKey == null
                            ? ''
                            : controllerKey!.address.hex),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'userDID : $userDID',
                  ),
                ),
              ),
              resolverLoading == true
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'resolverDID : $resolverDID',
                        ),
                      ),
                    ),
              Center(
                child: ElevatedButton(
                  child: const Text(
                    'Generate Device Key',
                  ),
                  onPressed: () {
                    devicePubKey = GenerateDeviceKey().generate();
                    setState(() {});
                    log(devicePubKey.toString());
                  },
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text(
                    'Generate Controller Key',
                  ),
                  onPressed: () {
                    controllerKey = GenerateControllerKey().generate();
                    setState(() {});
                    log(controllerKey!.address.toString());
                  },
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text(
                    'Contruct UserDID',
                  ),
                  onPressed: () {
                    userDID = ConstructDID()
                        .generate(key: controllerKey!, chainId: 100);
                    setState(() {});
                    log(userDID.toString());
                  },
                ),
              ),
              // ElevatedButton(
              //   child: const Text('Send Goerli'),
              //   onPressed: () async {
              //     Web3ServiceImpl web3serviceImpl = Web3ServiceImpl();

              //     web3serviceImpl.init(
              //         'https://nd-597-324-099.p2pify.com/b539bdf723b75c6a98e7038674ede7f0');

              //     /// identityOwner
              //     String? identityOwner = await web3serviceImpl
              //         .getIdentity(controllerKey!.address.hex);
              //     print('identityOwner : ' + identityOwner);

              //     /// nonce
              //     String? nonce = await web3serviceImpl.getNonce(identityOwner);
              //     print('nonce : ' + nonce);

              //     var credentials = CustomCredentialEipService(
              //       client: web3serviceImpl.client,
              //       chainId: 5,
              //       privateKey: controllerKey,
              //     );

              //     final payload = Solidity().solidityPack(
              //       [
              //         EthereumAddress.fromHex(
              //           '0xdca7ef03e98e0dc2b855be647c39abe984fcf21b',
              //         ),
              //         int.parse(nonce),
              //         EthereumAddress.fromHex(controllerKey!.address.hex),
              //         'setAttribute',
              //         hexToBytes(
              //             '0x6469642f7075622f456432353531392f766572694b65792f6261736536340000'),
              //         deviceKey,
              //         300,
              //       ],
              //     );

              //     final sign = await credentials.signToSignature(
              //       payload,
              //     );

              //     log('big to int' + sign.r.toRadixString(16));

              //     final setAttributeSign =
              //         await web3serviceImpl.setAttributeSignedTx(
              //       EthereumAddress.fromHex(controllerKey!.address.hex),
              //       sign.v,
              //       hexToBytes(sign.r.toRadixString(16)),
              //       hexToBytes(sign.s.toRadixString(16)),
              //       hexToBytes(
              //           '0x6469642f7075622f456432353531392f766572694b65792f6261736536340000'),
              //       deviceKey!,
              //       BigInt.from(300),
              //     );

              //     log(bytesToHex(setAttributeSign));

              //     final nonceTx =
              //         await web3serviceImpl.client.getTransactionCount(
              //       EthereumAddress.fromHex(
              //           '0xd25D03722dE1D3E911D68adf0F50FCC039b5B00C'),
              //       atBlock: const BlockNum.pending(),
              //     );

              //     final txObject = Transaction(
              //       nonce: nonceTx,
              //       from: EthereumAddress.fromHex(
              //           '0xd25D03722dE1D3E911D68adf0F50FCC039b5B00C'),

              //       /// address contract
              //       to: EthereumAddress.fromHex(
              //           '0xdCa7EF03e98e0DC2B855bE647C39ABe984fcF21B'),

              //       /// native / matic
              //       value: EtherAmount.inWei(BigInt.from(0)),

              //       /// 3jt, 500rb
              //       maxGas: 100000,

              //       /// 1 gwei (10^9 wei)
              //       gasPrice: EtherAmount.inWei(
              //         BigInt.from(1500000000),
              //         // await web3serviceImpl.getPrice(),
              //       ),

              //       /// mau ke fungsi mana parameternya apa,
              //       /// amount USDC disini
              //       data: setAttributeSign,

              //       /// ini untuk EIP1559
              //       /// 3000000000
              //       maxFeePerGas: EtherAmount.inWei(
              //         BigInt.from(1500000000),
              //         // await web3serviceImpl.getPrice(),
              //       ),
              //       maxPriorityFeePerGas: EtherAmount.inWei(
              //         BigInt.from(1500000000),
              //         // await web3serviceImpl.getPrice(),
              //       ),
              //     );

              //     log(txObject.gasPrice!.getInWei.toString());
              //     final paymasterKey = EthPrivateKey.fromHex(
              //         '0x1b145e2a5b8d344038a5de9414e49b97905e0b0c62716027829f26c42e67891d');

              //     /// ini tadi error
              //     credentials = CustomCredentialEipService(
              //       privateKey: paymasterKey,
              //       client: web3serviceImpl.client,
              //       chainId: 5,
              //     );

              //     final result = await web3serviceImpl.client.sendTransaction(
              //       credentials,
              //       txObject,
              //       chainId: 5,
              //     );
              //     log('txHash ' + result);
              //   },
              // ),
              ElevatedButton(
                child: const Text('Send Edge'),
                onPressed: () async {
                  Web3ServiceImpl web3serviceImpl = Web3ServiceImpl();

                  web3serviceImpl.init(
                      'http://ec2-35-88-32-250.us-west-2.compute.amazonaws.com:8545');

                  /// identityOwner
                  String? identityOwner = await web3serviceImpl
                      .getIdentity(controllerKey!.address.hex);
                  print('identityOwner : ' + identityOwner);

                  /// nonce
                  String? nonce = await web3serviceImpl.getNonce(identityOwner);
                  print('nonce : ' + nonce);

                  var credentials = CustomCredentialEipService(
                    client: web3serviceImpl.client,
                    chainId: 100,
                    privateKey: controllerKey,
                  );

                  // final payload = Solidity().solidityPack(
                  //   [
                  //     /// contract address
                  //     EthereumAddress.fromHex(
                  //       '0x03d5003bf0e79C5F5223588F347ebA39AfbC3818',
                  //     ),
                  //     int.parse(nonce),
                  //     EthereumAddress.fromHex(controllerKey!.address.hex),
                  //     'setAttribute',
                  //     hexToBytes(
                  //         '0x6469642f7075622f456432353531392f766572694b65792f6261736536340000'),
                  //     hexToBytes(
                  //         eth_sig_util.bytesToHex(deviceKey!, include0x: true)),
                  //     300,
                  //   ],
                  // );
                  const contractAddr =
                      '0x03d5003bf0e79C5F5223588F347ebA39AfbC3818';
                  final identityAddr = controllerKey!.address;
                  final attrName = Uint8List.fromList(
                    utf8.encode('did/pub/Ed25519/veriKey/base58'),
                  );
                  final attrValue = devicePubKey!.asTypedList;
                  final attrValidity = BigInt.from(300);

                  final msgToSign = abi.AbiUtil.solidityPack(
                    [
                      'address',
                      'uint',
                      'address',
                      'string',
                      'bytes32',
                      'bytes',
                      'uint'
                    ],
                    [
                      abi.AbiUtil.encodeSingle('address', contractAddr),
                      nonce,
                      identityAddr.addressBytes,
                      'setAttribute',
                      attrName,
                      attrValue,
                      attrValidity,
                    ],
                  );

                  final msgSignature = await credentials.signToSignature(
                    Uint8List.fromList([0x19, 0] + msgToSign),
                  );

                  log('big to int' +
                      msgSignature.r.toRadixString(16).padLeft(64, '0'));
                  log('big to int' +
                      msgSignature.s.toRadixString(16).padLeft(64, '0'));

                  final setAttributeSignedTransaction =
                      await web3serviceImpl.setAttributeSignedTransaction(
                    identityAddr,
                    msgSignature,
                    attrName,
                    attrValue,
                    attrValidity,
                  );

                  // log(bytesToHex(setAttributeSign));
                  // final nonceTx =
                  //     await web3serviceImpl.client.getTransactionCount(
                  //   EthereumAddress.fromHex(
                  //       '0xd25D03722dE1D3E911D68adf0F50FCC039b5B00C'),
                  //   atBlock: const BlockNum.pending(),
                  // );
                  // final txObject = Transaction(
                  //   nonce: nonceTx,
                  //   from: EthereumAddress.fromHex(
                  //       '0xd25D03722dE1D3E911D68adf0F50FCC039b5B00C'),
                  //   /// address contract
                  //   to: EthereumAddress.fromHex(
                  //       '0x03d5003bf0e79C5F5223588F347ebA39AfbC3818'),
                  //   /// native / matic
                  //   value: EtherAmount.inWei(BigInt.from(0)),
                  //   /// 3jt, 500rb
                  //   maxGas: 100000,
                  //   /// 1 gwei (10^9 wei)
                  //   gasPrice: EtherAmount.inWei(
                  //     BigInt.from(1500000000),
                  //     // await web3serviceImpl.getPrice(),
                  //   ),
                  //   /// mau ke fungsi mana parameternya apa,
                  //   /// amount USDC disini
                  //   data: setAttributeSign,
                  //   /// ini untuk EIP1559
                  //   /// 3000000000
                  //   // maxFeePerGas: EtherAmount.inWei(
                  //   //   BigInt.from(1500000000),
                  //   //   // await web3serviceImpl.getPrice(),
                  //   // ),
                  //   // maxPriorityFeePerGas: EtherAmount.inWei(
                  //   //   BigInt.from(1500000000),
                  //   //   // await web3serviceImpl.getPrice(),
                  //   // ),
                  // );

                  // log(txObject.gasPrice!.getInWei.toString());
                  final paymasterKey = EthPrivateKey.fromHex(
                      '0x1b145e2a5b8d344038a5de9414e49b97905e0b0c62716027829f26c42e67891d');

                  /// ini tadi error
                  credentials = CustomCredentialEipService(
                    privateKey: paymasterKey,
                    client: web3serviceImpl.client,
                    chainId: 100,
                  );

                  final result = await web3serviceImpl.client.sendTransaction(
                    credentials,
                    setAttributeSignedTransaction,
                    chainId: 100,
                  );
                  log('txHash ' + result);
                },
              ),
              Center(
                child: ElevatedButton(
                  child: const Text(
                    'Device key EDDSA',
                  ),
                  onPressed: () async {
                    log(bytesToHex(devicePubKey!).toString());
                  },
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text(
                    'User DID',
                  ),
                  onPressed: () async {
                    var a = ConstructDID()
                        .generate(key: controllerKey!, chainId: 5);
                    log(a.toString());
                  },
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text(
                    'Check UserDID',
                  ),
                  onPressed: () async {
                    resolverLoading = true;
                    setState(() {});
                    resolverDID = await CheckUserDID().check(userDID!);
                    resolverLoading = false;
                    setState(() {});
                    log(resolverDID.toString());
                  },
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text(
                    'Eip712',
                  ),
                  onPressed: () async {
                    const privateKey =
                        '4af1bceebf7f3634ec3cff8a2c38e51178d5d4ce585c52d6043e5e2cc3418bb0';
                    const json =
                        r'''{"types":{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}],"Permit":[{"name":"owner","type":"address"},{"name":"spender","type":"address"},{"name":"value","type":"uint256"},{"name":"nonce","type":"uint256"},{"name":"deadline","type":"uint256"}]},"primaryType":"Permit","domain":{"name":"USDC","version":"1","chainId":5,"verifyingContract":"0xD987401017750F88D5be2dAC42850909cc913b05"},"message":{"owner":"0x29C76e6aD8f28BB1004902578Fb108c507Be341b","spender":"0x2Af658dD14D90b0877A8190d7060Ff1562838aBC","value":"10000000","nonce":0,"deadline":1672542000}}''';
                    final signature = EthSigUtil.signTypedData(
                      privateKey: privateKey,
                      jsonData: json,
                      version: TypedDataVersion.V4,
                    );

                    log(signature.toString());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
