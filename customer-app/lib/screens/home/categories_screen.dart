import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Category data model for display
class CategoryItem {
  final String id;
  final String name;
  final String nameAr;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.color,
  });
}

/// All categories grid screen
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  static const List<CategoryItem> categories = [
    CategoryItem(
      id: 'pizza',
      name: 'Pizza',
      nameAr: 'بيتزا',
      icon: Icons.local_pizza,
      color: Color(0xFFE53935),
    ),
    CategoryItem(
      id: 'burger',
      name: 'Burger',
      nameAr: 'برجر',
      icon: Icons.lunch_dining,
      color: Color(0xFFFF9800),
    ),
    CategoryItem(
      id: 'grill',
      name: 'Grill',
      nameAr: 'مشويات',
      icon: Icons.kebab_dining,
      color: Color(0xFF795548),
    ),
    CategoryItem(
      id: 'oriental',
      name: 'Oriental',
      nameAr: 'مأكولات شرقية',
      icon: Icons.ramen_dining,
      color: Color(0xFF4CAF50),
    ),
    CategoryItem(
      id: 'pastry',
      name: 'Pastry',
      nameAr: 'معجنات',
      icon: Icons.bakery_dining,
      color: Color(0xFFFFEB3B),
    ),
    CategoryItem(
      id: 'dessert',
      name: 'Dessert',
      nameAr: 'حلويات',
      icon: Icons.icecream,
      color: Color(0xFFE91E63),
    ),
    CategoryItem(
      id: 'drinks',
      name: 'Drinks',
      nameAr: 'مشروبات',
      icon: Icons.local_cafe,
      color: Color(0xFF9C27B0),
    ),
    CategoryItem(
      id: 'seafood',
      name: 'Seafood',
      nameAr: 'مأكولات بحرية',
      icon: Icons.set_meal,
      color: Color(0xFF2196F3),
    ),
    CategoryItem(
      id: 'chicken',
      name: 'Chicken',
      nameAr: 'دجاج',
      icon: Icons.egg_alt,
      color: Color(0xFFFF5722),
    ),
    CategoryItem(
      id: 'sandwiches',
      name: 'Sandwiches',
      nameAr: 'سندويتشات',
      icon: Icons.breakfast_dining,
      color: Color(0xFF607D8B),
    ),
    CategoryItem(
      id: 'healthy',
      name: 'Healthy',
      nameAr: 'أكل صحي',
      icon: Icons.eco,
      color: Color(0xFF8BC34A),
    ),
    CategoryItem(
      id: 'breakfast',
      name: 'Breakfast',
      nameAr: 'فطور',
      icon: Icons.free_breakfast,
      color: Color(0xFFFFC107),
    ),
    CategoryItem(
      id: 'shawarma',
      name: 'Shawarma',
      nameAr: 'شاورما',
      icon: Icons.fastfood,
      color: Color(0xFFCDDC39),
    ),
    CategoryItem(
      id: 'koshary',
      name: 'Koshary',
      nameAr: 'كشري',
      icon: Icons.rice_bowl,
      color: Color(0xFF009688),
    ),
    CategoryItem(
      id: 'falafel',
      name: 'Falafel',
      nameAr: 'فلافل',
      icon: Icons.circle,
      color: Color(0xFF3F51B5),
    ),
    CategoryItem(
      id: 'fresh_juice',
      name: 'Fresh Juice',
      nameAr: 'عصائر طازجة',
      icon: Icons.local_drink,
      color: Color(0xFFFF4081),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع الأقسام'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryCard(
            category: category,
            onTap: () {
              context.push(
                '/category/${category.id}',
                extra: {'name': category.nameAr},
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.color.withValues(alpha: 0.1),
                category.color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 28,
                  color: category.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                category.nameAr,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
