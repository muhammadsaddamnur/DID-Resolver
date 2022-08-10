import 'package:eth_sig_util/util/utils.dart' as eth_sig_util;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart';

class ConstructDID {
  String generate({
    required EthPrivateKey key,
    required int chainId,
  }) {
    var hexChainId = eth_sig_util.intToHex(chainId);
    return 'did:ethr:$hexChainId:' +
        bytesToHex(key.publicKey.getEncoded(), include0x: true);
  }
}
