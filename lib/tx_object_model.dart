class TxObjectModel {
  TxObjectModel({
    this.from,
    this.to,
    this.maxGas,
    this.gasPrice,
    this.nonce,
    this.value,
    this.data,
  });
  final String? from;
  final String? to;
  final String? maxGas;
  final String? gasPrice;
  final String? nonce;
  final String? value;
  final String? data;
}
