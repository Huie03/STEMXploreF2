import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stemxploref2/navigation_provider.dart';
import 'package:stemxploref2/theme_provider.dart';
import '../learning_materials/material_details_page.dart'; // Ensure this import is correct
import '../widgets/gradient_background.dart';
import '../widgets/language_toggle.dart';
import 'favorite_provider.dart';
import '../widgets/box_shadow.dart';

class FavoritePage extends StatelessWidget {
  static const String routeName = '/favorite';
  final Function(Map<String, dynamic>) onChapterTap; // Add this

  const FavoritePage({super.key, required this.onChapterTap});

  String _translateSubject(String subject, bool isEnglish) {
    if (isEnglish) return subject;
    switch (subject) {
      case "Science":
        return "Sains";
      case "Mathematics":
        return "Matematik";
      case "Computer Science (ASK)":
        return "Asas Sains Komputer (ASK)";
      case "Design and Technology (RBT)":
        return "Reka Bentuk dan Teknologi (RBT)";
      default:
        return subject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final bool isEnglish = navProvider.locale.languageCode == 'en';
    final favorites = context.watch<FavoriteProvider>().bookmarks;
    final Color titleColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(
                isEnglish ? "Favorite" : "Kegemaran",
                titleColor,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isEnglish ? "Last access:" : "Terakhir dicapai:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: favorites.isEmpty
                    ? Center(
                        child: _buildNoRecordContainer(
                          context,
                          isEnglish,
                          isDark,
                        ),
                      )
                    : _buildFavoriteList(context, favorites, isEnglish, isDark),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(String title, Color titleColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: titleColor,
            ),
          ),
          const LanguageToggle(),
        ],
      ),
    );
  }

  Widget _buildNoRecordContainer(
    BuildContext context,
    bool isEnglish,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(35),
        boxShadow: isDark ? [] : appBoxShadow,
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Text(
        isEnglish ? "No record" : "Tiada rekod",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFavoriteList(
    BuildContext context,
    List<Map<String, dynamic>> favorites, // Change to dynamic
    bool isEnglish,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final colorScheme = Theme.of(context).colorScheme;
        final item = favorites[index];
        final String subject = _translateSubject(
          item['title'] ?? '',
          isEnglish,
        );
        final String label = isEnglish ? "Chapter" : "Bab";
        final String title = isEnglish
            ? (item['title_en'] ?? "")
            : (item['title_ms'] ?? "");
        final String chapterNum = item['chapter_num'] ?? "1";
        final String fullSubtitle = "$label $chapterNum - $title";

        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Slidable(
            key: ValueKey(item['chapter_num']),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (context) => Provider.of<FavoriteProvider>(
                    context,
                    listen: false,
                  ).toggleFavorite(item),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                // Map the data to include infographics
                final Map<String, dynamic> chapterData = {
                  'subject': item['title'],
                  'chapter_number': item['chapter_num'],
                  'title_en': item['title_en'],
                  'title_ms': item['title_ms'],
                  'image_url': item['image'],
                  'infographic_en': item['infographic_en'],
                  'infographic_ms': item['infographic_ms'],
                };
                onChapterTap(chapterData);
              },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isDark ? Colors.white10 : colorScheme.outlineVariant,
                  ),
                  boxShadow: isDark ? [] : appBoxShadow,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Text(
                    subject,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    fullSubtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  trailing: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item['image'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.book, size: 40, color: Colors.grey),
                    ),
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
