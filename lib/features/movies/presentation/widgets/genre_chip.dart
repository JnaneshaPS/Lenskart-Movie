import 'package:flutter/material.dart';
import '../../../../core/config/theme_config.dart';

class GenreChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const GenreChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.accentGold, AppColors.accentGoldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.primaryBackground
                : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class GenreChipList extends StatelessWidget {
  final List<String> genres;

  const GenreChipList({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((genre) => GenreChip(label: genre)).toList(),
    );
  }
}

class GenreFilterBar extends StatelessWidget {
  final List<MapEntry<int, String>> genres;
  final int? selectedGenreId;
  final Function(int?) onGenreSelected;

  const GenreFilterBar({
    super.key,
    required this.genres,
    required this.selectedGenreId,
    required this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GenreChip(
                label: 'All',
                isSelected: selectedGenreId == null,
                onTap: () => onGenreSelected(null),
              ),
            );
          }
          final genre = genres[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GenreChip(
              label: genre.value,
              isSelected: selectedGenreId == genre.key,
              onTap: () => onGenreSelected(genre.key),
            ),
          );
        },
      ),
    );
  }
}
