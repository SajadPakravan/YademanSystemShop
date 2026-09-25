import 'package:flutter/material.dart';
import 'package:yad_sys/models/products_list_model.dart';
import 'package:yad_sys/tools/app_colors.dart';
import 'package:yad_sys/tools/app_dimension.dart';
import 'package:yad_sys/widgets/text_views/app_text.dart';

class CategoryFilterTreeView extends StatefulWidget {
  const CategoryFilterTreeView({super.key, required this.categories, required this.selectedIds, required this.onSelectionChanged});

  final List<ProductCategoryFilterModel> categories;
  final Set<int> selectedIds;
  final VoidCallback onSelectionChanged;

  @override
  State<CategoryFilterTreeView> createState() => _CategoryFilterTreeViewState();
}

class _CategoryFilterTreeViewState extends State<CategoryFilterTreeView> {
  final Set<int> _expandedIds = <int>{};
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final query = _query.trim().toLowerCase();
    final isSearching = query.isNotEmpty;
    final searchResults = isSearching ? _search(widget.categories, query) : const <_CategorySearchResult>[];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(r.pageHorizontalPadding, r.space(10), r.pageHorizontalPadding, r.space(8)),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'جستجو در دسته‌بندی‌ها',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'پاک کردن جستجو',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        Expanded(
          child: isSearching
              ? _buildSearchResults(context, searchResults)
              : widget.categories.isEmpty
              ? Center(child: AppText.bodyMedium('دسته‌بندی‌ای برای نمایش وجود ندارد', color: colors.textMuted))
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: widget.categories.length,
                  itemBuilder: (context, index) {
                    return _CategoryTreeNode(
                      category: widget.categories[index],
                      selectedIds: widget.selectedIds,
                      expandedIds: _expandedIds,
                      depth: 0,
                      inheritedSelected: false,
                      onToggleExpanded: _toggleExpanded,
                      onSelectionChanged: _changeSelection,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, List<_CategorySearchResult> results) {
    final r = context.responsive;
    final colors = context.appColors;

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(r.space(24)),
          child: AppText.bodyMedium('دسته‌بندی‌ای با این عنوان پیدا نشد', color: colors.textMuted, textAlign: TextAlign.center),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: results.length,
      separatorBuilder: (_, _) => Divider(height: 1, indent: r.space(16), endIndent: r.space(16), color: colors.divider),
      itemBuilder: (context, index) {
        final result = results[index];
        final value = _checkboxValueById(result.category.id);

        return CheckboxListTile(
          value: value,
          tristate: true,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.symmetric(horizontal: r.space(16), vertical: r.space(2)),
          title: AppText.bodyMedium(result.category.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: result.parentPath.isEmpty
              ? null
              : Padding(
                  padding: EdgeInsets.only(top: r.space(3)),
                  child: AppText.labelSmall(result.parentPath, color: colors.textMuted, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
          secondary: result.category.count > 0 ? AppText.labelSmall('(${result.category.count})', color: colors.textMuted) : null,
          onChanged: (_) => _changeSelection(result.category, value != true),
        );
      },
    );
  }

  void _toggleExpanded(int categoryId) {
    setState(() {
      if (!_expandedIds.add(categoryId)) {
        _expandedIds.remove(categoryId);
      }
    });
  }

  void _changeSelection(ProductCategoryFilterModel category, bool selected) {
    setState(() {
      _materializeSelectedTrees(widget.categories, widget.selectedIds);
      _setTreeSelected(category, widget.selectedIds, selected);
      _syncParentSelections(widget.categories, widget.selectedIds);
    });

    widget.onSelectionChanged();
  }

  bool? _checkboxValueById(int targetId) {
    final path = _pathById(widget.categories, targetId);
    if (path == null || path.isEmpty) return false;

    for (var index = 0; index < path.length - 1; index++) {
      if (widget.selectedIds.contains(path[index].id)) {
        return true;
      }
    }

    return _checkboxValue(path.last, widget.selectedIds);
  }
}

class _CategoryTreeNode extends StatelessWidget {
  const _CategoryTreeNode({
    required this.category,
    required this.selectedIds,
    required this.expandedIds,
    required this.depth,
    required this.inheritedSelected,
    required this.onToggleExpanded,
    required this.onSelectionChanged,
  });

  final ProductCategoryFilterModel category;
  final Set<int> selectedIds;
  final Set<int> expandedIds;
  final int depth;
  final bool inheritedSelected;
  final ValueChanged<int> onToggleExpanded;
  final void Function(ProductCategoryFilterModel category, bool selected) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = context.appColors;
    final hasChildren = category.children.isNotEmpty;
    final expanded = expandedIds.contains(category.id);
    final checkboxValue = inheritedSelected ? true : _checkboxValue(category, selectedIds);
    final childInheritedSelected = inheritedSelected || selectedIds.contains(category.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: hasChildren ? () => onToggleExpanded(category.id) : () => onSelectionChanged(category, checkboxValue != true),
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: r.space(12) + (depth * r.space(18)), end: r.space(8), top: r.space(3), bottom: r.space(3)),
            child: Row(
              children: [
                Checkbox(
                  value: checkboxValue,
                  tristate: true,
                  onChanged: (_) => onSelectionChanged(category, checkboxValue != true),
                  activeColor: context.appColors.textPrimary,
                ),
                Expanded(
                  child: AppText.bodyMedium(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: depth == 0 ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (hasChildren)
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Icon(Icons.keyboard_arrow_down_rounded, size: r.icon(22), color: colors.textSecondary),
                  ),
              ],
            ),
          ),
        ),
        Divider(height: 1, indent: r.space(16), endIndent: r.space(16) + (depth * r.space(18)), color: colors.divider),
        if (hasChildren)
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final child in category.children)
                          _CategoryTreeNode(
                            category: child,
                            selectedIds: selectedIds,
                            expandedIds: expandedIds,
                            depth: depth + 1,
                            inheritedSelected: childInheritedSelected,
                            onToggleExpanded: onToggleExpanded,
                            onSelectionChanged: onSelectionChanged,
                          ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}

class _CategorySearchResult {
  const _CategorySearchResult({required this.category, required this.parentPath});

  final ProductCategoryFilterModel category;
  final String parentPath;
}

List<_CategorySearchResult> _search(List<ProductCategoryFilterModel> categories, String query, {String parentPath = ''}) {
  final result = <_CategorySearchResult>[];

  for (final category in categories) {
    if (category.name.trim().toLowerCase().contains(query)) {
      result.add(_CategorySearchResult(category: category, parentPath: parentPath));
    }

    final nextPath = parentPath.isEmpty ? category.name : '$parentPath ← ${category.name}';

    if (category.children.isNotEmpty) {
      result.addAll(_search(category.children, query, parentPath: nextPath));
    }
  }

  return result;
}

bool? _checkboxValue(ProductCategoryFilterModel category, Set<int> selectedIds) {
  if (selectedIds.contains(category.id)) return true;
  if (category.children.isEmpty) return false;

  var hasSelectedChild = false;
  var allChildrenSelected = true;

  for (final child in category.children) {
    final childValue = _checkboxValue(child, selectedIds);

    if (childValue == true || childValue == null) {
      hasSelectedChild = true;
    }
    if (childValue != true) {
      allChildrenSelected = false;
    }
  }

  if (allChildrenSelected) return true;
  if (hasSelectedChild) return null;
  return false;
}

Set<int> _treeIds(ProductCategoryFilterModel category) {
  final result = <int>{category.id};

  for (final child in category.children) {
    result.addAll(_treeIds(child));
  }

  return result;
}

void _setTreeSelected(ProductCategoryFilterModel category, Set<int> selectedIds, bool selected) {
  final ids = _treeIds(category);

  if (selected) {
    selectedIds.addAll(ids);
  } else {
    selectedIds.removeAll(ids);
  }
}

void _materializeSelectedTrees(List<ProductCategoryFilterModel> categories, Set<int> selectedIds, {bool inheritedSelected = false}) {
  for (final category in categories) {
    final selectedHere = inheritedSelected || selectedIds.contains(category.id);

    if (selectedHere) {
      selectedIds.add(category.id);
    }

    if (category.children.isNotEmpty) {
      _materializeSelectedTrees(category.children, selectedIds, inheritedSelected: selectedHere);
    }
  }
}

void _syncParentSelections(List<ProductCategoryFilterModel> categories, Set<int> selectedIds) {
  for (final category in categories) {
    _syncSingleParent(category, selectedIds);
  }
}

bool _syncSingleParent(ProductCategoryFilterModel category, Set<int> selectedIds) {
  if (category.children.isEmpty) {
    return selectedIds.contains(category.id);
  }

  var allChildrenSelected = true;

  for (final child in category.children) {
    if (!_syncSingleParent(child, selectedIds)) {
      allChildrenSelected = false;
    }
  }

  if (allChildrenSelected) {
    selectedIds.add(category.id);
    return true;
  }

  selectedIds.remove(category.id);
  return false;
}

List<ProductCategoryFilterModel>? _pathById(List<ProductCategoryFilterModel> categories, int targetId) {
  for (final category in categories) {
    if (category.id == targetId) {
      return <ProductCategoryFilterModel>[category];
    }

    final childPath = _pathById(category.children, targetId);
    if (childPath != null) {
      return <ProductCategoryFilterModel>[category, ...childPath];
    }
  }

  return null;
}
