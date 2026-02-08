import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '/widgets/gradient_background.dart';
import '/widgets/language_toggle.dart';
import 'favorite_provider.dart';

class FavoritePage extends StatefulWidget {
  static const String routeName = '/favorite';
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    final localization = FlutterLocalization.instance;
    final bool isEnglish =
        localization.currentLocale?.languageCode == 'en' ||
        localization.currentLocale == null;

    final favoriteProvider = context.watch<FavoriteProvider>();
    final favorites = favoriteProvider.bookmarks;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Exact same header logic as InfoPage
              _buildCustomAppBar(isEnglish ? "Favorite" : "Kegemaran"),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isEnglish
                        ? "Last access learning materials:"
                        : "Bahan pembelajaran terakhir dicapai:",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: favorites.isEmpty
                    ? _buildNoRecordContainer(isEnglish)
                    : _buildFavoriteList(context, favorites, isEnglish),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UPDATED: Matches InfoPage structure and padding exactly
  Widget _buildCustomAppBar(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ), // Size 22 matches InfoPage
          ),
          LanguageToggle(
            onLanguageChanged: () {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoRecordContainer(bool isEnglish) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          isEnglish ? "No record" : "Tiada rekod",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteList(
    BuildContext context,
    List<Map<String, String>> favorites,
    bool isEnglish,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Slidable(
            key: ValueKey(item['chapter']),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (context) {
                    Provider.of<FavoriteProvider>(
                      context,
                      listen: false,
                    ).toggleFavorite(item);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                title: Text(
                  item['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item['chapter'] ?? ''),
                trailing: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item['image'] ?? 'assets/images/science_book_cover.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
