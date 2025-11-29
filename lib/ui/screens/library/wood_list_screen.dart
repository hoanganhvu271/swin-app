import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/constants/assets_path.dart';
import 'package:swin/ui/blocs/wood/wood_bloc.dart';
import 'package:swin/ui/blocs/wood/wood_event.dart';
import 'package:swin/ui/blocs/wood/wood_state.dart';
import 'package:swin/ui/screens/library/wood_detail_screen.dart';
import 'package:swin/ui/widgets/shared/loading_widget.dart';

import '../../widgets/shared/swin_top_bar.dart';
import '../../../constants/base_status.dart';
import '../../../models/wood_piece.dart';

class WoodListScreen extends StatefulWidget {
  final String databaseId;

  const WoodListScreen({super.key, required this.databaseId});

  @override
  State<WoodListScreen> createState() => _WoodListScreenState();
}

class _WoodListScreenState extends State<WoodListScreen> {
  final ValueNotifier<bool> isGridView = ValueNotifier(true);
  final TextEditingController searchController = TextEditingController();
  late WoodBloc woodBloc;

  @override
  void initState() {
    super.initState();
    woodBloc = WoodBloc();
    woodBloc.add(GetWoodListEvent(widget.databaseId));
  }

  @override
  void dispose() {
    woodBloc.close();
    searchController.dispose();
    isGridView.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: woodBloc,
      child: AnnotatedRegion(
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
              children: [
                // ---------------- TOP BAR ----------------
                SwinTopBar(
                  title: "Danh sách gỗ",
                  iconRightPath: "assets/icons/icon_setting.svg",
                  iconRightOnTap: () {},
                ),

                // ---------------- SEARCH BAR ----------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Tìm kiếm...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                // ---------------- SWITCH VIEW BUTTON ----------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isGridView,
                      builder: (_, grid, __) {
                        return IconButton(
                          icon: Icon(grid ? Icons.list : Icons.grid_view),
                          onPressed: () => isGridView.value = !grid,
                        );
                      },
                    ),
                  ),
                ),

                // ---------------- LIST / GRID VIEW ----------------
                Expanded(
                  child: BlocBuilder<WoodBloc, WoodState>(
                    builder: (context, state) {
                      if (state.status == BaseStatus.loading) {
                        return const Center(child: LoadingWidget());
                      } else if (state.status == BaseStatus.failure) {
                        return const Center(child: Text("Lấy dữ liệu thất bại"));
                      }

                      // Filter theo search text
                      final List<WoodPiece> filtered = state.woods.where((e) {
                        return e.name
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase());
                      }).toList();

                      return ValueListenableBuilder<bool>(
                        valueListenable: isGridView,
                        builder: (_, grid, __) {
                          if (grid) {
                            // ------- GRID VIEW -------
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (_, index) => _GridItem(
                                wood: filtered[index],
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => WoodDetailScreen(piece: filtered[index])),
                                ),
                              ),
                            );
                          } else {
                            // ------- LIST VIEW -------
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (_, index) => _ListItem(
                                wood: filtered[index],
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => WoodDetailScreen(piece: filtered[index])),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final WoodPiece wood;
  final VoidCallback? onTap;

  const _GridItem({required this.wood, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                wood.images.isNotEmpty ? wood.images[0] : 'https://picsum.photos/200/300',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            wood.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final WoodPiece wood;
  final VoidCallback? onTap;

  const _ListItem({required this.wood, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                wood.images.isNotEmpty ? wood.images[0] : 'https://picsum.photos/200/300',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                wood.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }
}
