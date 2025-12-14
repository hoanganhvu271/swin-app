import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/constants/assets_path.dart';

import 'package:swin/ui/screens/prediction/prediction_screen.dart';
import 'package:swin/ui/widgets/shared/dialog_component.dart';

import '../../../constants/base_status.dart';
import '../../../core/main_tab.dart';
import '../../blocs/update/update_bloc.dart';
import '../../blocs/update/update_event.dart';
import '../../blocs/update/update_state.dart';
import '../../widgets/shared/keep_alive_component.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../library/library_screen.dart';
import '../more/more_screen.dart';
import 'bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late TabController tabController;
  ValueNotifier<MainTab> selectedTab = ValueNotifier(MainTab.home);

  @override
  void initState() {
    super.initState();

    context.read<UpdateBloc>().add(CheckVersionEvent());

    tabController = TabController(length: MainTab.values.length, vsync: this);
    selectedTab.addListener(() => _selectTab(selectedTab.value));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateBloc, UpdateState>(
      listener: (context, state) {
        if (state.status == BaseStatus.success && state.needUpdate) {
          _showUpdateDialog(context);
        }

        if (state.status == BaseStatus.failure) {
          debugPrint("Update error: ${state.errorMessage}");
        }

        if (state.status == BaseStatus.loading) {
          debugPrint("Updating model...");
        }
      },
      child: Material(
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                KeepAliveComponent(child: HomeScreen()),
                KeepAliveComponent(child: LibraryScreen()),
                HistoryScreen(),
                KeepAliveComponent(child: MoreScreen()),
              ],
            ),
            bottomNavigationBar:
            BottomNavigation(selectedTabNotifier: selectedTab),
            floatingActionButton: CenterFabButton(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PredictionScreen()),
              ),
            ),
            floatingActionButtonLocation:
            CustomFabLocation(height: MediaQuery.paddingOf(context).bottom),
            floatingActionButtonAnimator:
            FloatingActionButtonAnimator.noAnimation,
          ),
        ),
      ),
    );
  }

  void _selectTab(MainTab tab) {
    if (selectedTab.value != tab) {
      selectedTab.value = tab;
    }

    tabController.animateTo(tab.index,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogComponent(
        closeIconSize: 20,
        title: "Cập nhật mới",
        widgetContent: SizedBox(
          height: 200,
          child: Image.asset(AssetsPath.imgDialog, fit: BoxFit.contain),
        ),
        buttonLabel: "Cập nhật",
        buttonOnTap: () {
          Navigator.pop(context);
          context.read<UpdateBloc>().add(DownloadModelEvent());
        },
        subButtonOnTap: () => Navigator.pop(context),
        subButtonLabel: "Để sau"
      ),
    );
  }
}

class CustomFabLocation extends FloatingActionButtonLocation {
  final double height;
  const CustomFabLocation({this.height = 0});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final fabX =
        (geometry.scaffoldSize.width - geometry.floatingActionButtonSize.width) /
            2.0;
    final fabY = geometry.scaffoldSize.height -
        geometry.floatingActionButtonSize.height -
        height -
        8;

    return Offset(fabX, fabY);
  }
}
