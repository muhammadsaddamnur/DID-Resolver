// import 'package:convert/convert.dart';
// import 'package:web3dart/web3dart.dart';

// /// Web3TxService
// class Web3TxService {
//   /// sendTx
//   Future<void> sendTx({
//     required String to,
//     required double amount,
//     required String token,
//     required String nativeToken,
//     required bool isNative,
//     required EthereumAddress from,
//     required String presign,
//   }) async {
//     await _sendTxImpl(
//       presign: presign,
//       amount: amount,
//       isNative: isNative,
//       token: token,
//       nativeToken: nativeToken,
//       to: to,
//       from: from,
//     );
//   }

//   /// sendTxImpl
//   Future<void> _sendTxImpl({
//     required String presign,
//     required String to,
//     required double amount,
//     required String token,
//     required String nativeToken,
//     required bool isNative,
//     required EthereumAddress from,
//   }) async {
//     final web3Service = Web3ServiceImpl();

//     /// Build the transaction
//     ///
//     final nonce = await web3Service.client.getTransactionCount(
//       from,
//       atBlock: const BlockNum.pending(),
//     );
//     var txObject = Transaction();

//     if (isNative) {
//       txObject = Transaction(
//         nonce: nonce,
//         from: from,

//         /// address
//         to: EthereumAddress.fromHex(to),

//         /// native / matic
//         value: EtherAmount.inWei(BigInt.from(amount * 1000000000000000000)),

//         /// 3jt, 500rb
//         maxGas: 100000,

//         /// 1 gwei (10^9 wei)
//         gasPrice: EtherAmount.inWei(
//           BigInt.from(
//             double.parse(
//               await web3Service.getGasFee(
//                 from: from.hex,
//                 to: EthereumAddress.fromHex(to).hex,
//                 value: BigInt.from(amount * 1000000).toString(),
//                 token: token,
//                 nativeToken: nativeToken,
//                 isNative: true,
//               ),
//             ),
//           ),
//         ),

//         /// ini untuk EIP1559
//         maxFeePerGas: EtherAmount.inWei(BigInt.from(25000000000)),
//         maxPriorityFeePerGas: EtherAmount.inWei(BigInt.from(25000000000)),
//       );
//     } else {
//       final data = web3Service.transferFunction.encodeCall(
//         [
//           EthereumAddress.fromHex(to),
//           BigInt.from(amount * 1000000),
//         ],
//       );

//       txObject = Transaction(
//         nonce: nonce,
//         from: from,

//         /// address contract
//         to: ContractList.getContractAddress(token, nativeToken),

//         /// native / matic
//         value: EtherAmount.inWei(BigInt.from(0)),

//         /// 3jt, 500rb
//         maxGas: 100000,

//         /// 1 gwei (10^9 wei)
//         gasPrice: EtherAmount.inWei(
//           BigInt.from(
//             double.parse(
//               await web3Service.getGasFee(
//                 from: from.hex,
//                 to: EthereumAddress.fromHex(to).hex,
//                 value: BigInt.from(amount * 1000000).toString(),
//                 token: token,
//                 nativeToken: nativeToken,
//                 isNative: false,
//               ),
//             ),
//           ),
//         ),

//         /// mau ke fungsi mana parameternya apa,
//         /// amount USDC disini
//         data: data,

//         /// ini untuk EIP1559
//         /// 3000000000
//         maxFeePerGas: EtherAmount.inWei(BigInt.from(25000000000)),
//         maxPriorityFeePerGas: EtherAmount.inWei(BigInt.from(25000000000)),
//       );
//     }

//     print('Nonce with pending blok :${txObject.nonce}');
//     print('from :${txObject.from}');
//     print('to :${txObject.to}');
//     print('value :${txObject.value}');
//     print('data :${txObject.data}');
//     print('maxGas :${txObject.maxGas}');
//     print('gasPrice :${txObject.gasPrice}');

//     /// start foreground
//     // await ForegroundService().startForegroundTask();

//     final chainId = await web3Service.getChainId(
//       token: token,
//       nativeToken: nativeToken,
//     );

//     final credentials = CustomCredentialMPCService(
//       presign: presign,
//       client: web3Service.client,
//       chainId: chainId.toInt(),
//       txObjectModel: TxObjectModel(
//         from: txObject.from.toString(),
//         to: txObject.to.toString(),
//         nonce: txObject.nonce.toString(),
//         data: isNative ? null : hex.encode(txObject.data!),
//         gasPrice: txObject.gasPrice.toString(),
//         maxGas: txObject.maxGas.toString(),
//         value: txObject.value.toString(),
//       ),
//     );

//     final result = await web3Service.client.sendTransaction(
//       credentials,
//       txObject,
//       chainId: chainId.toInt(),
//     );

//     /// save to hive
//     // HiveService().putPendingTx(
//     //   PendingTxModel()
//     //     ..address = txObject.from.toString()
//     //     ..index = '1'
//     //     ..symbol = token.toString()
//     //     ..txHash = ''
//     //     ..value =
//     //         isNative ? txObject.value.toString() : txObject.data.toString(),
//     // );

//     final txHash = result;
//     print(txHash);

//     /// re-generate presign
//     final securityService = SecurityServiceImpl();
//     await securityService.regeneratePresign(from.hex);

//     /// stop foreground
//     // await ForegroundService().stopForegroundTask();
//   }
// }
