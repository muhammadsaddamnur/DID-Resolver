import 'dart:typed_data';
import 'package:pinenacl/ed25519.dart';
import 'package:pinenacl/tweetnacl.dart';

class GenerateDeviceKey {
  Uint8List generate() {
    final skalicePinenaclGenerate = PrivateKey.generate();
    final skalicePinenacl =
        SigningKey(seed: skalicePinenaclGenerate.asTypedList);

    return skalicePinenacl.publicKey.asTypedList;
  }
}
