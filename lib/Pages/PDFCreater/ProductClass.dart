class Product {
  final String productId;
  final String productName;
  final double price;
  final num quantity;
  final int quantityType;
  final String quantityTypeName;
  final int kdv;
  final double brut;
  final double total;

  Product(
      this.productId,
      this.productName,
      this.price,
      this.quantity,
      this.quantityType,
      this.kdv,
      this.total,
      this.brut,
      this.quantityTypeName);
}
