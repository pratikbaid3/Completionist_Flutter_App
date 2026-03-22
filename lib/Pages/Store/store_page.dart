import 'package:flutter/material.dart';
import 'package:game_trophy_manager/Widgets/aurora_background.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_trophy_manager/Model/store_item_model.dart';
import 'package:game_trophy_manager/Provider/in_app_purchase_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import 'Widgets/store_item_tile.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<InAppPurchaseProvider>(builder: (context, model, child) {
      return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'STORE',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: 3,
            ),
          ),
          iconTheme: IconThemeData(color: textPrimary),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    primaryAccentColor.withValues(alpha: 0.3),
                    secondaryAccentColor.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        body: AuroraBackground(
          child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24),
              // Premium header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: neonCardDecoration(glowColor: primaryAccentColor),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'images/app_icon.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'GO PRO',
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: 4,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Remove all ads and unlock\nthe full experience',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, end: 0, duration: 500.ms),
              SizedBox(height: 20),
              // Products list
              Expanded(
                child: FutureBuilder<List<ProductDetails>>(
                  future: model.getStoreProducts(context),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      List<ProductDetails> products = snapshot.data!;
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 0),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          StoreItemModel? item =
                              model.storeItemList[products[index].id];
                          if (item == null) return SizedBox.shrink();
                          return StoreItemTile(
                            item: item,
                            product: products[index],
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 200 + index * 100),
                                duration: 400.ms,
                              )
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                delay: Duration(milliseconds: 200 + index * 100),
                                duration: 400.ms,
                              );
                        },
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: primaryAccentColor,
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        ),
      );
    });
  }
}
