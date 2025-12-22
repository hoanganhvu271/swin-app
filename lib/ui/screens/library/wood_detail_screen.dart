import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:swin/constants/text_dimensions.dart';
import 'package:swin/l10n/generated/app_localizations.dart';
import 'package:swin/l10n/generated/app_localizations_vi.dart';
import 'package:swin/models/wood_piece.dart';
import '../../widgets/shared/swin_top_bar.dart';

class WoodDetailScreen extends StatelessWidget {
  final WoodPiece piece;

  const WoodDetailScreen({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context) ?? AppLocalizationsVi();

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SwinTopBar(
                title: localization.details,
                iconRightPath: "assets/icons/icon_setting.svg",
                iconRightOnTap: () {},
              ),
              Expanded(
                child: ListView(
                  children: [
                    if (piece.images.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CarouselSlider(
                              items: piece.images
                                  .take(3)
                                  .map(
                                    (image) => ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    image,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              )
                                  .toList(),
                              options: CarouselOptions(
                                height: 220,
                                autoPlay: piece.images.length > 1,
                                enlargeCenterPage: true,
                                viewportFraction: 0.8,
                                enableInfiniteScroll: piece.images.length > 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Html(data: piece.description),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
