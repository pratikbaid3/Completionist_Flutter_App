import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:game_trophy_manager/Model/store_item_model.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseProvider extends ChangeNotifier {
  bool isSpinning = false;
  bool isPremiumVersionPurchased = false;

  void changeSpinningState() {
    isSpinning = !isSpinning;
    notifyListeners();
  }

  Map<String, StoreItemModel> storeItemList = {
    'premium_version': StoreItemModel(
        productId: 'premium_version',
        image: 'images/store_items/premium.png',
        name: 'Premium',
        subText: 'Ad free version',
        status: 'Buy',
        isConsumable: false),
  };

  //Initialize
  void initializeInAppPurchase(BuildContext context) {
    StreamSubscription<List<PurchaseDetails>> _subscription;
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList, context);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      print('--STORE ERROR--');
      print(error.toString());
    });
  }

  //Purchase listener
  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList, BuildContext context) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      print(purchaseDetails.status.toString());
      if (purchaseDetails.status == PurchaseStatus.pending) {
        //The purchase is pending
        print("--PENDING--");
        storeItemList[purchaseDetails.productID].status = 'Pending';
        isSpinning = false;
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print('--STORE ERROR--');
          print(purchaseDetails.error.details);
          print(purchaseDetails.error.message);
          isSpinning = false;
          notifyListeners();
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          print('--PURCHASED--');
          deliverProduct(purchaseDetails, context);
          isSpinning = false;
          notifyListeners();
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.restored) {
          print('--PURCHASED PRODUCTS--');
          storeItemList[purchaseDetails.productID].status = 'Purchased';
          print(storeItemList[purchaseDetails.productID].name);
          if (purchaseDetails.productID == 'premium_version') {
            //User owns premium version
            isPremiumVersionPurchased = true;
          }
          notifyListeners();
          // Mark that you've delivered the purchase. This is mandatory.
          InAppPurchase.instance.completePurchase(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          print('--COMPLETING PURCHASE--');
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails, BuildContext context) {
    StoreItemModel product = storeItemList[purchaseDetails.productID];
    if (product.isConsumable) {
      product.status = 'Buy';
    } else {
      product.status = 'Purchased';
    }
    if (purchaseDetails.productID == 'premium_version') {
      isPremiumVersionPurchased = true;
    }
  }

  //Getting store products
  Future<List<ProductDetails>> getStoreProducts(BuildContext context) async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      print('---STORE ERROR---');
      print('Store unavailable');
      // Toasts.showFailToast(msg: 'Error', context: context);
      return [];
    } else {
      const Set<String> _kIds = <String>{'premium_version'};
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        print('---STORE ERROR NO ITEM---');
        print(response.error.toString());
        print(response.error.details);
        // Toasts.showFailToast(msg: 'Error', context: context);
      }
      List<ProductDetails> products = response.productDetails;
      print('--PRODUCTS--');
      for (ProductDetails product in products) {
        print(storeItemList[product.id].name);
      }
      return products;
    }
  }

  void makePurchase(ProductDetails productDetails) {
    try {
      isSpinning = true;
      notifyListeners();
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      StoreItemModel product = storeItemList[productDetails.id];
      if (product.isConsumable) {
        InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
      } else {
        InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      isSpinning = !isSpinning;
      notifyListeners();
    }
  }

  Future<void> getPastPurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }
}
