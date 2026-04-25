import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/bookmark/bookmark_provider.dart';
import 'package:stemxploref2/navigation_provider.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/widgets/rawscrollbar.dart';

class BookmarkPage extends StatefulWidget {
  static const String routeName = '/favorite';
  final Function(Map<String, dynamic>) onChapterTap;

  const BookmarkPage({super.key, required this.onChapterTap});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final Set<int> _selectedIndices = {};
  bool _isAllSelected = false;
  final ScrollController _scrollController = ScrollController();
  bool _needsScrollReset = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_needsScrollReset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
          _needsScrollReset = false;
        }
      });
    }
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

  void _deleteSelected(
    BuildContext context,
    List<Map<String, dynamic>> favorites,
  ) async {
    final provider = Provider.of<BookmarkProvider>(context, listen: false);
    final itemsToDelete = _selectedIndices.map((i) => favorites[i]).toList();

    for (var item in itemsToDelete) {
      await provider.toggleFavorite(item);
    }

    setState(() {
      _selectedIndices.clear();
      _isAllSelected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favProvider = context.watch<BookmarkProvider>();
    final favorites = favProvider.bookmarks;

    final bool isDark = themeProvider.isDarkMode;
    final bool isEnglish = navProvider.locale.languageCode == 'en';
    final Color titleColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildCustomAppBar(
                    context,
                    isEnglish ? "Bookmarks" : "Penanda buku",
                    titleColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // The Selection Row
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
                            // Delete icon beside the Select All checkbox
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.only(left: 8),
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
                                  : () => _deleteSelected(context, favorites),
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
                              double contentHeight = favorites.length * 125.0;
                              bool needsScroll =
                                  contentHeight > constraints.maxHeight;

                              Widget listView = ListView.builder(
                                key: UniqueKey(),
                                controller: _scrollController,
                                physics: const ClampingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  30,
                                  0,
                                  30,
                                  80,
                                ),
                                itemCount: favorites.length,
                                itemBuilder: (context, index) {
                                  return _buildBookmarkCard(
                                    context,
                                    favorites[index],
                                    index,
                                    isEnglish,
                                    isDark,
                                    favorites.length,
                                  );
                                },
                              );

                              return needsScroll
                                  ? AppRawScrollbar(
                                      controller: _scrollController,
                                      child: listView,
                                    )
                                  : listView;
                            },
                          ),
                  ),
                ],
              ),

              // Animated Red Delete Button
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                bottom: _selectedIndices.isNotEmpty ? 30 : -100,
                right: 30,
                child: GestureDetector(
                  onTap: () => _deleteSelected(context, favorites),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isDark ? [] : appBoxShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delete_forever, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          isEnglish
                              ? "Delete (${_selectedIndices.length})"
                              : "Padam (${_selectedIndices.length})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
    if (isEnglish) {
      switch (subject) {
        case "Computer Science (ASK)":
          return "Fundamentals of Computer Science";
        case "Design and Technology (RBT)":
          return "Design and Technology";
        default:
          return subject;
      }
    }

    switch (subject) {
      case "Science":
        return "Sains";
      case "Mathematics":
        return "Matematik";
      case "Computer Science (ASK)":
        return "Asas Sains Komputer";
      case "Design and Technology (RBT)":
        return "Reka Bentuk dan Teknologi (RBT)";
      default:
        return subject;
    }
  }

  Widget _buildBookmarkCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
    bool isEnglish,
    bool isDark,
    int total,
  ) {
    final String rawSubject = item['title'] ?? item['subject'] ?? '';
    final String subject = _translateSubject(rawSubject, isEnglish);
    final String title = isEnglish
        ? (item['title_en'] ?? "")
        : (item['title_ms'] ?? "");
    final String assetPath = item['image'] ?? item['image_url'] ?? '';
    final String chapterNum =
        item['chapter_num'] ?? item['chapter_number'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => widget.onChapterTap(item),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                    const SizedBox(height: 4),
                    Text(
                      "${isEnglish ? 'Chapter' : 'Bab'} $chapterNum - $title",
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
                child: Image.asset(
                  assetPath,
                  width: 55,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.book, size: 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(
    BuildContext context,
    String title,
    Color titleColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
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
