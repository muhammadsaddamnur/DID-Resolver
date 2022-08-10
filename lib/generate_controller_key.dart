import 'dart:math';

import 'package:web3dart/web3dart.dart';

class GenerateControllerKey {
  EthPrivateKey generate() {
    var rng = Random.secure();
    EthPrivateKey random = EthPrivateKey.createRandom(rng);

    return random;
  }
}
