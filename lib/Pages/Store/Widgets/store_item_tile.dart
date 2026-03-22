import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_trophy_manager/Model/store_item_model.dart';
import 'package:game_trophy_manager/Provider/in_app_purchase_provider.dart';
import 'package:game_trophy_manager/Utilities/colors.dart';
import 'package:game_trophy_manager/Widgets/snack_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class StoreItemTile extends StatefulWidget {
  final StoreItemModel item;
  final ProductDetails product;
  StoreItemTile({required this.item, required this.product});

  @override
  _StoreItemTileState createState() => _StoreItemTileState();
}

class _StoreItemTileState extends State<StoreItemTile> {
  @override
  Widget build(BuildContext context) {
    double wp = MediaQuery.of(context).size.width;
    return Consumer<InAppPurchaseProvider>(builder: (context, model, child) {
      final status = model.storeItemList[widget.product.id]?.status ?? '';
      final isPurchased = status == 'Purchased';

      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPurchased
                ? neonGreen.withValues(alpha: 0.3)
                : primaryAccentColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isPurchased
                    ? neonGreen.withValues(alpha: 0.1)
                    : primaryAccentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isPurchased ? Icons.check_circle_rounded : Icons.block_rounded,
                size: 28,
                color: isPurchased ? neonGreen : primaryAccentColor,
              ),
            ),
            SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: GoogleFonts.inter(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.item.subText,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            // Purchase button
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                if (status == 'Buy') {
                  model.makePurchase(widget.product);
                } else {
                  snackBar(
                    context,
                    'Already $status',
                    "Cannot purchase again",
                    wp,
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isPurchased ? null : accentGradient,
                  color: isPurchased
                      ? neonGreen.withValues(alpha: 0.15)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isPurchased
                      ? []
                      : [
                          BoxShadow(
                            color: primaryAccentColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Text(
                      status,
                      style: GoogleFonts.inter(
                        color: isPurchased ? neonGreen : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!isPurchased) ...[
                      SizedBox(height: 2),
                      Text(
                        '${widget.product.currencyCode} ${widget.product.price}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
