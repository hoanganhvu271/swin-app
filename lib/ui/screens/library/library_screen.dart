import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/constants/assets_path.dart';
import 'package:swin/l10n/generated/app_localizations.dart';
import 'package:swin/l10n/generated/app_localizations_vi.dart';
import 'package:swin/ui/blocs/library/library_bloc.dart';
import 'package:swin/ui/blocs/library/library_state.dart';
import 'package:swin/ui/screens/library/wood_list_screen.dart';
import 'package:swin/ui/widgets/shared/loading_widget.dart';

import '../../../constants/base_status.dart';
import '../../../constants/colors_lib.dart';
import '../../../constants/text_dimensions.dart';
import '../../blocs/library/library_event.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizationsVi();

    return BlocProvider(
      create: (_) => LibraryBloc(),
      child: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          return Material(
            color: ColorsLib.primary2050,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- TITLE ----------
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text(
                      localizations.library,
                      style: TextDimensions.titleBold28
                          .copyWith(color: ColorsLib.primary2950),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---------- BODY ----------
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _buildBody(context, state),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, LibraryState state) {
    switch (state.status) {
      case BaseStatus.loading:
        return const Center(
          child: LoadingWidget(),
        );

      case BaseStatus.success:
        final list = state.databases ?? [];
        if (list.isEmpty) {
          return const Center(child: Text("Empty data"));
        }

        return SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              for (final db in list)
                WoodDatabaseBanner(
                  title: db.title,
                  description: db.description,
                  imagePath: db.image,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => WoodListScreen(databaseId: db.id,)),
                  ),
                )
            ],
          ),
        );

      case BaseStatus.failure:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Text("Có lỗi xảy ra:\n${state.errorMessage}"),
              ElevatedButton(
                onPressed: () {
                  context.read<LibraryBloc>().add(LoadLibraryEvent());
                },
                child: const Text("Thử lại"),
              )
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }
}


class WoodDatabaseBanner extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const WoodDatabaseBanner({
    super.key,
    this.imagePath = "",
    this.title = "",
    this.description = "",
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imagePath,
              height: 180,
              fit: BoxFit.fitWidth,
              width: double.infinity,
            ),
            Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      title,
                      style: TextDimensions.headlineBold17.copyWith(color: Colors.black),
                    ),
                    Text(
                      description,
                      style: TextDimensions.footnote13.copyWith(color: ColorsLib.primary2750),
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
