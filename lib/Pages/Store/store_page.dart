import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Model/store_item_model.dart';
import 'package:game_trophy_manager/Provider/in_app_purchase_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import 'Widgets/store_item_tile.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key key}) : super(key: key);

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<InAppPurchaseProvider>(builder: (context, model, child) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: secondaryColor,
          elevation: 1,
          title: Text("Store"),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 25, right: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
              ),
              Expanded(
                child: FutureBuilder(
                    future: model.getStoreProducts(context),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data.length != 0) {
                        List<ProductDetails> products = snapshot.data;
                        return ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 0),
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            StoreItemModel item =
                                model.storeItemList[products[index].id];
                            return StoreItemTile(
                                item: item, product: products[index]);
                          },
                        );
                      }
                      return Container();
                    }),
              )
            ],
          ),
        ),
      );
    });
  }
}
