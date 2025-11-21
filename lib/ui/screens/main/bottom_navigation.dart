import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/assets_path.dart';
import '../../../constants/colors_lib.dart';
import '../../../constants/text_dimensions.dart';
import '../../../core/main_tab.dart';

class BottomNavigationProvider extends InheritedWidget {
  final ValueNotifier<MainTab> selectedTabNotifier;

  const BottomNavigationProvider({super.key, required super.child, required this.selectedTabNotifier});

  static BottomNavigationProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BottomNavigationProvider>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return this != oldWidget;
  }
}

class BottomNavigation extends StatelessWidget {
  final ValueNotifier<MainTab> selectedTabNotifier;

  const BottomNavigation({super.key, required this.selectedTabNotifier});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationProvider(
      selectedTabNotifier: selectedTabNotifier,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Container(
          height: 68 + MediaQuery.paddingOf(context).bottom,
          padding: const EdgeInsets.symmetric(horizontal: 7.5),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -4),
                blurRadius: 24,
                spreadRadius: 0,
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ],
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BottomNavigationItem(tab: MainTab.home),
              BottomNavigationItem(tab: MainTab.library),
              SizedBox(width: 64 + 8 * 2),
              BottomNavigationItem(tab: MainTab.history),
              BottomNavigationItem(tab: MainTab.more),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavigationItem extends StatelessWidget {
  final MainTab tab;

  const BottomNavigationItem({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    final provider = BottomNavigationProvider.of(context)!;

    return Expanded(
      child: ValueListenableBuilder<MainTab>(
        valueListenable: provider.selectedTabNotifier,
        builder: (_, value, _) {
          final selected = value == tab;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => provider.selectedTabNotifier.value = tab,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    tab.imagePath,
                    height: 28, width: 28,
                    colorFilter: ColorFilter.mode(selected ? ColorsLib.greenMain : ColorsLib.primary2950, BlendMode.srcIn)
                  ),
                ),
                Text(
                  tab.getLabel(context),
                  maxLines: 1,
                  style: selected
                      ? TextDimensions.captionBold12.copyWith(color: ColorsLib.greenMain)
                      : TextDimensions.caption12.copyWith(color: ColorsLib.primary2700),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CenterFabButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CenterFabButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap?.call,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: -4,
              color: Colors.black.withValues(alpha: 0.24),
            ),
          ],
          gradient: const LinearGradient(
            colors: [Color(0xFFFFECEC), Color(0xFFD5E488)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
            child: Hero(tag: 'chatbot-logo', child: Image.asset(AssetsPath.imgLeaf6))
        ),
        // child: SizedBox(),
      ),
    );
  }
}
