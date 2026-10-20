import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import 'crop_detail_screen.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _showRecommended = true;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All', 'Vegetables', 'Herbs', 'Fruits', 'Flowers'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CatalogCrop> _getDisplayList(AppState state) {
    // Use recommended list when no search/filter active
    final base = (_showRecommended && _searchQuery.isEmpty && _selectedFilter == 'All')
        ? state.getRecommendedCatalog()
        : catalogCrops;

    return base.where((crop) {
      final matchesFilter =
          _selectedFilter == 'All' || crop.category == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          crop.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final results = _getDisplayList(state);

        return Scaffold(
          body: Column(
            children: [
              // ── Green Header ──────────────────────────────────────────
              Container(
                color: AppColors.primary,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  right: 16,
                  bottom: 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Crop',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Choose what you want to grow next',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Search + Filters ──────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search crops...',
                        hintStyle: GoogleFonts.inter(
                            color: AppColors.textHint, fontSize: 14),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textHint, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: AppColors.textHint, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final isSelected = _selectedFilter == filter;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFilter = filter),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                filter,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '${results.length} crops available',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        // Toggle recommended / all
                        if (_searchQuery.isEmpty && _selectedFilter == 'All')
                          GestureDetector(
                            onTap: () => setState(
                                () => _showRecommended = !_showRecommended),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _showRecommended
                                    ? AppColors.selectedBg
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _showRecommended
                                      ? AppColors.primary
                                      : AppColors.cardBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 13,
                                    color: _showRecommended
                                        ? AppColors.primary
                                        : AppColors.textHint,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _showRecommended
                                        ? 'For You'
                                        : 'All Crops',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _showRecommended
                                          ? AppColors.primary
                                          : AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

              // ── Crop List ─────────────────────────────────────────────
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔍',
                                style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            Text(
                              'No crops found',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF5F5F5)),
                        itemBuilder: (context, index) {
                          final crop = results[index];
                          return _CropCatalogRow(
                            crop: crop,
                            onTap: () =>
                                _showAddConfirm(context, crop, state),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddConfirm(
      BuildContext context, CatalogCrop crop, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(crop.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Start growing ${crop.name}?',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${crop.duration} · ${crop.difficulty} difficulty',
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final plan = state.addCropFromCatalog(crop);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CropDetailScreen(planId: plan.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Add to My Plans',
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style:
                      GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Catalog Row ──────────────────────────────────────────────────────────────

class _CropCatalogRow extends StatelessWidget {
  final CatalogCrop crop;
  final VoidCallback onTap;

  const _CropCatalogRow({required this.crop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.progressBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(crop.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: crop.tags
                        .take(2)
                        .map((tag) => _CropTag(tag))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Stat('Difficulty', crop.difficulty),
                const SizedBox(height: 4),
                _Stat('Duration', crop.duration),
                const SizedBox(height: 4),
                _Stat('Yield', crop.yield),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10, color: AppColors.textHint)),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

class _CropTag extends StatelessWidget {
  final String label;
  const _CropTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.progressBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.primary,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
