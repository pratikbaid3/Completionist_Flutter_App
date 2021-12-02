import 'package:flutter/material.dart';

class StoreItemModel {
  String productId;
  String name;
  String subText;
  String image;
  String status;
  bool isConsumable;
  StoreItemModel(
      {@required this.productId,
      @required this.image,
      @required this.name,
      @required this.subText,
      @required this.status,
      @required this.isConsumable});
}
