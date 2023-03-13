import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game_trophy_manager/Model/store_item_model.dart';
import 'package:game_trophy_manager/Provider/in_app_purchase_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/snack_bar.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class StoreItemTile extends StatefulWidget {
  StoreItemModel item;
  ProductDetails product;
  StoreItemTile({@required this.item, @required this.product});

  @override
  _StoreItemTileState createState() => _StoreItemTileState();
}

class _StoreItemTileState extends State<StoreItemTile> {
  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return Consumer<InAppPurchaseProvider>(builder: (context, model, child) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        margin: new EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: new BorderRadius.all(const Radius.circular(10)),
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.ad,
                      size: 40,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                            overflow: TextOverflow.visible,
                          ),
                          Text(
                            widget.item.subText,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // model.changeSpinningState();
                    if (model.storeItemList[widget.product.id].status ==
                        'Buy') {
                      //The product is ready to be purchased
                      model.makePurchase(widget.product);
                    } else {
                      //The product is either ending or already purchased
                      snackBar(
                          context,
                          'Already ' +
                              model.storeItemList[widget.product.id].status,
                          "Cannot purchase again",
                          wp);
                    }
                  },
                  // color: primaryAccentColor,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(8),
                  // ),
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          model.storeItemList[widget.product.id].status,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          widget.product.currencyCode +
                              ' ' +
                              widget.product.price,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
