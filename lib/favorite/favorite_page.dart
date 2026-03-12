import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/navigation_provider.dart';
import 'package:stemxploref2/theme_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/language_toggle.dart';
import 'favorite_provider.dart';
import '../widgets/box_shadow.dart';
import '../ipaddress.dart';
import '../widgets/rawscrollbar.dart';

class FavoritePage extends StatefulWidget {
  static const String routeName = '/favorite';
  final Function(Map<String, dynamic>) onChapterTap;

  const FavoritePage({super.key, required this.onChapterTap});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final Set<int> _selectedIndices = {};
  bool _isAllSelected = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSelection(int index, int total) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
      _isAllSelected = _selectedIndices.length == total && total > 0;
    });
  }

  void _toggleSelectAll(int total) {
    setState(() {
      _isAllSelected = !_isAllSelected;
      if (_isAllSelected) {
        _selectedIndices.addAll(List.generate(total, (index) => index));
      } else {
        _selectedIndices.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favProvider = context.watch<FavoriteProvider>();
    final favorites = favProvider.bookmarks;

    final bool isDark = themeProvider.isDarkMode;
    final bool isEnglish = navProvider.locale.languageCode == 'en';
    final Color titleColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(
                context,
                isEnglish ? "Favorite" : "Kegemaran",
                titleColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Text(
                      isEnglish ? "Last access:" : "Terakhir dicapai:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: titleColor,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                          ),
                          child: Checkbox(
                            activeColor: const Color(0xFFEB9000),

                            checkColor: Colors.white,
                            side: BorderSide(
                              color: isDark ? Colors.white60 : Colors.black,
                              width: 2.0,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: _isAllSelected,
                            onChanged: favorites.isEmpty
                                ? null
                                : (_) => _toggleSelectAll(favorites.length),
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.delete_sweep_rounded,
                            color: Colors.redAccent,
                            size: 30,
                          ),
                          tooltip: isEnglish
                              ? "Delete selected"
                              : "Padam pilihan",
                          onPressed: _selectedIndices.isEmpty
                              ? null
                              : () =>
                                    _confirmDeleteSelected(context, favorites),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: favorites.isEmpty
                    ? Center(
                        child: _buildNoRecordContainer(
                          context,
                          isEnglish,
                          isDark,
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate height: Each card is roughly 115px (100 height + 15 padding)
                          double contentHeight = favorites.length * 125.0;

                          // Only show scrollbar/arrows if content exceeds the screen height
                          bool needsScroll =
                              contentHeight > constraints.maxHeight;

                          Widget listView = ListView.builder(
                            controller: _scrollController,
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(30, 5, 22, 30),
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              return _buildFavoriteCard(
                                context,
                                favorites[index],
                                index,
                                isEnglish,
                                isDark,
                                favorites.length,
                              );
                            },
                          );
                          if (needsScroll) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 14, 15),
                              child: AppRawScrollbar(
                                controller: _scrollController,
                                child: listView,
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 14, 0),
                              child: listView,
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
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

  Widget _buildFavoriteCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
    bool isEnglish,
    bool isDark,
    int total,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final String rawSubject = item['title'] ?? '';
    final String subject = _translateSubject(rawSubject, isEnglish);
    final String title = isEnglish
        ? (item['title_en'] ?? "")
        : (item['title_ms'] ?? "");
    final String fullImageUrl = '${ipadress.baseUrl}${item['image'] ?? ''}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => widget.onChapterTap(item),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isDark ? [] : appBoxShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                activeColor: const Color(0xFFEB9000),
                checkColor: Colors.white,
                side: BorderSide(
                  color: isDark ? Colors.white60 : Colors.black,
                  width: 2.0,
                ),
                value: _selectedIndices.contains(index),
                onChanged: (_) => _toggleSelection(index, total),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ), // Small gap between title and subtitle
                    Text(
                      "${isEnglish ? 'Chapter' : 'Bab'} ${item['chapter_num']} - $title",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  fullImageUrl,
                  width: 55,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.book, size: 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteSelected(
    BuildContext context,
    List<Map<String, dynamic>> favorites,
  ) async {
    final provider = Provider.of<FavoriteProvider>(context, listen: false);
    final itemsToDelete = _selectedIndices.map((i) => favorites[i]).toList();

    for (var item in itemsToDelete) {
      await provider.toggleFavorite(item);
    }
    setState(() {
      _selectedIndices.clear();
      _isAllSelected = false;
    });
  }

  Widget _buildCustomAppBar(
    BuildContext context,
    String title,
    Color titleColor,
  ) {
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
}
