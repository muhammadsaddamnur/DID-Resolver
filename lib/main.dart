import 'dart:developer';

import 'package:did_demo/check_user_did.dart';
import 'package:did_demo/generate_controller_key.dart';
import 'package:did_demo/generate_device_key.dart';
import 'package:did_demo/web3_service.dart';
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
  Uint8List? deviceKey;
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
                        (deviceKey == null ? '' : bytesToHex(deviceKey!)),
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
                  ? Center(child: CircularProgressIndicator())
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
                    deviceKey = GenerateDeviceKey().generate();
                    setState(() {});
                    log(deviceKey.toString());
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
                        .generate(key: controllerKey!, chainId: 5);
                    setState(() {});
                    log(userDID.toString());
                  },
                ),
              ),
              // Center(
              //   child: ElevatedButton(
              //     child: const Text(
              //       'setAttributeSigned',
              //     ),
              //     onPressed: () async {
              //       // log('pk ' + bytesToHex(controllerKey!.privateKey));
              //       Web3ServiceImpl web3serviceImpl = Web3ServiceImpl();
              //       web3serviceImpl.init(
              //           'https://nd-597-324-099.p2pify.com/b539bdf723b75c6a98e7038674ede7f0');

              //       /// identityOwner
              //       String? identityOwner = await web3serviceImpl
              //           .getIdentity(controllerKey!.address.hex);
              //       print('identityOwner : ' + identityOwner);

              //       /// nonce
              //       String? nonce =
              //           await web3serviceImpl.getNonce(identityOwner);
              //       print('nonce : ' + nonce);

              //       var credentials = CustomCredentialEipService(
              //         client: web3serviceImpl.client,
              //         chainId: 5,
              //         privateKey: controllerKey,
              //       );

              //       final payload = Solidity().solidityPack(
              //         [
              //           EthereumAddress.fromHex(
              //             '0xdca7ef03e98e0dc2b855be647c39abe984fcf21b',
              //           ),
              //           int.parse(nonce),
              //           EthereumAddress.fromHex(identityOwner),
              //           'setAttribute',
              //           hexToBytes(
              //               '0x6469642f7075622f456432353531392f766572694b65792f6261736536340000'),
              //           deviceKey,
              //           300,
              //         ],
              //       );
              //       final sign = await credentials.signToSignature(
              //         payload,
              //       );

              //       log('big to int' + sign.r.toRadixString(16));

              //       final setAttributeSign =
              //           await web3serviceImpl.setAttributeSigned(
              //         EthereumAddress.fromHex(
              //             '0x8d392fd5d7df5d4b08dd904ea141ebdfa74948e6'),
              //         27,
              //         hexToBytes(sign.r.toRadixString(16)),
              //         hexToBytes(sign.s.toRadixString(16)),
              //         hexToBytes(
              //             '0x6469642f7075622f456432353531392f766572694b65792f6261736536340000'),
              //         hexToBytes(
              //             '0x8b7f9af9bb54309ead60930887bc750c904ecc760959b0adefe15d8da74baab6'),
              //         BigInt.from(300),
              //       );

              //       log(bytesToHex(setAttributeSign));
              //     },
              //   ),
              // ),
              ElevatedButton(
                onPressed: () async {
                  Web3ServiceImpl web3serviceImpl = Web3ServiceImpl();

                  web3serviceImpl.init(
                      'https://nd-597-324-099.p2pify.com/b539bdf723b75c6a98e7038674ede7f0');

                  /// identityOwner
                  String? identityOwner = await web3serviceImpl
                      .getIdentity(controllerKey!.address.hex);
                  print('identityOwner : ' + identityOwner);

                  /// nonce
                  String? nonce = await web3serviceImpl.getNonce(identityOwner);
                  print('nonce : ' + nonce);

                  var credentials = CustomCredentialEipService(
                    client: web3serviceImpl.client,
                    chainId: 5,
                    privateKey: controllerKey,
                  );

                  final payload = Solidity().solidityPack(
                    [
                      EthereumAddress.fromHex(
                        '0xdca7ef03e98e0dc2b855be647c39abe984fcf21b',
                      ),
                      int.parse(nonce),
                      EthereumAddress.fromHex(controllerKey!.address.hex),
                      'setAttribute',
                      hexToBytes(
                          '0x6469642f7075622f456432353531392f766572694b65792f6261736536340000'),
                      deviceKey,
                      300,
                    ],
                  );
                  final sign = await credentials.signToSignature(
                    payload,
                  );

                  log('big to int' + sign.r.toRadixString(16));

                  final setAttributeSign =
                      await web3serviceImpl.setAttributeSigned(
                    EthereumAddress.fromHex(controllerKey!.address.hex),
                    sign.v,
                    hexToBytes(sign.r.toRadixString(16)),
                    hexToBytes(sign.s.toRadixString(16)),
                    hexToBytes(
                        '0x6469642f7075622f456432353531392f766572694b65792f6261736536340000'),
                    deviceKey!,
                    BigInt.from(300),
                  );

                  log(bytesToHex(setAttributeSign));

                  final nonceTx =
                      await web3serviceImpl.client.getTransactionCount(
                    EthereumAddress.fromHex(
                        '0xd25D03722dE1D3E911D68adf0F50FCC039b5B00C'),
                    atBlock: const BlockNum.pending(),
                  );

                  final txObject = Transaction(
                    nonce: nonceTx,
                    from: EthereumAddress.fromHex(
                        '0xd25D03722dE1D3E911D68adf0F50FCC039b5B00C'),

                    /// address contract
                    to: EthereumAddress.fromHex(
                        '0xdCa7EF03e98e0DC2B855bE647C39ABe984fcF21B'),

                    /// native / matic
                    value: EtherAmount.inWei(BigInt.from(0)),

                    /// 3jt, 500rb
                    maxGas: 100000,

                    /// 1 gwei (10^9 wei)
                    gasPrice: EtherAmount.inWei(
                      BigInt.from(1500000000),
                      // await web3serviceImpl.getPrice(),
                    ),

                    /// mau ke fungsi mana parameternya apa,
                    /// amount USDC disini
                    data: setAttributeSign,

                    /// ini untuk EIP1559
                    /// 3000000000
                    maxFeePerGas: EtherAmount.inWei(
                      BigInt.from(1500000000),
                      // await web3serviceImpl.getPrice(),
                    ),
                    maxPriorityFeePerGas: EtherAmount.inWei(
                      BigInt.from(1500000000),
                      // await web3serviceImpl.getPrice(),
                    ),
                  );

                  log(txObject.gasPrice!.getInWei.toString());
                  final paymasterKey = EthPrivateKey.fromHex(
                      '0x1b145e2a5b8d344038a5de9414e49b97905e0b0c62716027829f26c42e67891d');

                  /// ini tadi error
                  credentials = CustomCredentialEipService(
                    privateKey: paymasterKey,
                    client: web3serviceImpl.client,
                    chainId: 5,
                  );

                  final result = await web3serviceImpl.client.sendTransaction(
                    credentials,
                    txObject,
                    chainId: 5,
                  );
                  log('txHash ' + result);
                },
                child: Text('Send Goerli'),
              ),
              ElevatedButton(
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

                  final payload = Solidity().solidityPack(
                    [
                      /// contract address
                      EthereumAddress.fromHex(
                        '0x03d5003bf0e79C5F5223588F347ebA39AfbC3818',
                      ),
                      int.parse(nonce),
                      EthereumAddress.fromHex(controllerKey!.address.hex),
                      'setAttribute',
                      hexToBytes(
                          '0x6469642f7075622f456432353531392f766572694b65792f6261736536340000'),
                      hexToBytes(
                          eth_sig_util.bytesToHex(deviceKey!, include0x: true)),
                      300,
                    ],
                  );
                  final sign = await credentials.signToSignature(
                    payload,
                  );

                  log('big to int' + sign.r.toRadixString(16).padLeft(64, '0'));
                  log('big to int' + sign.s.toRadixString(16).padLeft(64, '0'));

                  final setAttributeSign =
                      await web3serviceImpl.setAttributeSigned(
                    EthereumAddress.fromHex(controllerKey!.address.hex),
                    sign.v,
                    hexToBytes(sign.r.toRadixString(16).padLeft(64, '0')),
                    hexToBytes(
                      sign.s.toRadixString(16).padLeft(64, '0'),
                    ),
                    hexToBytes(
                        '0x6469642f7075622f456432353531392f766572694b65792f6261736536340000'),
                    hexToBytes(
                        eth_sig_util.bytesToHex(deviceKey!, include0x: true)),
                    BigInt.from(300),
                  );

                  log(bytesToHex(setAttributeSign));

                  final nonceTx =
                      await web3serviceImpl.client.getTransactionCount(
                    EthereumAddress.fromHex(
                        '0xd25D03722dE1D3E911D68adf0F50FCC039b5B00C'),
                    atBlock: const BlockNum.pending(),
                  );

                  final txObject = Transaction(
                    nonce: nonceTx,
                    from: EthereumAddress.fromHex(
                        '0xd25D03722dE1D3E911D68adf0F50FCC039b5B00C'),

                    /// address contract
                    to: EthereumAddress.fromHex(
                        '0x03d5003bf0e79C5F5223588F347ebA39AfbC3818'),

                    /// native / matic
                    value: EtherAmount.inWei(BigInt.from(0)),

                    /// 3jt, 500rb
                    maxGas: 100000,

                    /// 1 gwei (10^9 wei)
                    gasPrice: EtherAmount.inWei(
                      BigInt.from(1500000000),
                      // await web3serviceImpl.getPrice(),
                    ),

                    /// mau ke fungsi mana parameternya apa,
                    /// amount USDC disini
                    data: setAttributeSign,

                    /// ini untuk EIP1559
                    /// 3000000000
                    // maxFeePerGas: EtherAmount.inWei(
                    //   BigInt.from(1500000000),
                    //   // await web3serviceImpl.getPrice(),
                    // ),
                    // maxPriorityFeePerGas: EtherAmount.inWei(
                    //   BigInt.from(1500000000),
                    //   // await web3serviceImpl.getPrice(),
                    // ),
                  );

                  log(txObject.gasPrice!.getInWei.toString());
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
                    txObject,
                    chainId: 100,
                  );
                  log('txHash ' + result);
                },
                child: Text('Send Edge'),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text(
                    'Device key EDDSA',
                  ),
                  onPressed: () async {
                    log(bytesToHex(deviceKey!).toString());
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
            ],
          ),
        ),
      ),
    );
  }
}
