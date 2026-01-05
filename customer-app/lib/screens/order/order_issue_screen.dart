import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';

/// Issue type enum
enum IssueType {
  missingItem,
  wrongItem,
  foodQuality,
  deliveryIssue,
  packaging,
  other,
}

/// Issue state provider
final isSubmittingIssueProvider = StateProvider<bool>((ref) => false);
final selectedIssueTypeProvider = StateProvider<IssueType?>((ref) => null);
final selectedItemsProvider = StateProvider<List<String>>((ref) => []);
final issueImagesProvider = StateProvider<List<XFile>>((ref) => []);

class OrderIssueScreen extends ConsumerStatefulWidget {
  final Order order;

  const OrderIssueScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<OrderIssueScreen> createState() => _OrderIssueScreenState();
}

class _OrderIssueScreenState extends ConsumerState<OrderIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Reset providers on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedIssueTypeProvider.notifier).state = null;
      ref.read(selectedItemsProvider.notifier).state = [];
      ref.read(issueImagesProvider.notifier).state = [];
      ref.read(isSubmittingIssueProvider.notifier).state = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(selectedIssueTypeProvider);
    final selectedItems = ref.watch(selectedItemsProvider);
    final images = ref.watch(issueImagesProvider);
    final isSubmitting = ref.watch(isSubmittingIssueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإبلاغ عن مشكلة'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Info Card
              _buildOrderInfoCard(context),
              const SizedBox(height: 24),

              // Issue Type Selection
              Text(
                'نوع المشكلة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'اختر نوع المشكلة التي تواجهها',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 12),
              _buildIssueTypeGrid(context, selectedType),
              const SizedBox(height: 24),

              // Affected Items Selection (for certain issue types)
              if (selectedType != null && _shouldShowItemSelection(selectedType)) ...[
                Text(
                  'العناصر المتأثرة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'حدد العناصر التي تعاني من المشكلة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                _buildItemsSelection(context, selectedItems),
                const SizedBox(height: 24),
              ],

              // Description
              Text(
                'وصف المشكلة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'صف المشكلة بالتفصيل...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى وصف المشكلة';
                  }
                  if (value.trim().length < 10) {
                    return 'يرجى كتابة وصف أكثر تفصيلاً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Image Upload
              Text(
                'إرفاق صور (اختياري)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'أضف صوراً توضح المشكلة (حتى 5 صور)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 12),
              _buildImageSection(context, images),
              const SizedBox(height: 24),

              // Preferred Resolution
              Text(
                'الحل المفضل',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildResolutionOptions(context),
              const SizedBox(height: 32),

              // Contact Info
              _buildContactInfo(context),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedType == null || isSubmitting
                      ? null
                      : () => _submitIssue(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('إرسال البلاغ'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب رقم #${widget.order.orderNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.order.restaurant.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(widget.order.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueTypeGrid(BuildContext context, IssueType? selectedType) {
    final issueTypes = [
      {
        'type': IssueType.missingItem,
        'icon': Icons.remove_shopping_cart,
        'title': 'عنصر ناقص',
        'subtitle': 'لم أستلم بعض العناصر',
      },
      {
        'type': IssueType.wrongItem,
        'icon': Icons.swap_horiz,
        'title': 'عنصر خاطئ',
        'subtitle': 'استلمت عنصر مختلف',
      },
      {
        'type': IssueType.foodQuality,
        'icon': Icons.thumb_down_outlined,
        'title': 'جودة الطعام',
        'subtitle': 'الطعام بارد أو سيء',
      },
      {
        'type': IssueType.deliveryIssue,
        'icon': Icons.delivery_dining,
        'title': 'مشكلة توصيل',
        'subtitle': 'تأخير أو سلوك السائق',
      },
      {
        'type': IssueType.packaging,
        'icon': Icons.inventory_2_outlined,
        'title': 'مشكلة تغليف',
        'subtitle': 'تلف أو انسكاب',
      },
      {
        'type': IssueType.other,
        'icon': Icons.more_horiz,
        'title': 'أخرى',
        'subtitle': 'مشكلة أخرى',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: issueTypes.length,
      itemBuilder: (context, index) {
        final issue = issueTypes[index];
        final type = issue['type'] as IssueType;
        final isSelected = selectedType == type;

        return InkWell(
          onTap: () {
            ref.read(selectedIssueTypeProvider.notifier).state = type;
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  issue['icon'] as IconData,
                  size: 28,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  issue['title'] as String,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  issue['subtitle'] as String,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textHint,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemsSelection(BuildContext context, List<String> selectedItems) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.order.items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = widget.order.items[index];
          final isSelected = selectedItems.contains(item.menuItemId);

          return CheckboxListTile(
            value: isSelected,
            onChanged: (value) {
              final current = ref.read(selectedItemsProvider);
              if (value == true) {
                ref.read(selectedItemsProvider.notifier).state = [
                  ...current,
                  item.menuItemId,
                ];
              } else {
                ref.read(selectedItemsProvider.notifier).state = current
                    .where((id) => id != item.menuItemId)
                    .toList();
              }
            },
            title: Text(
              item.displayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
            ),
            subtitle: Text(
              '${item.quantity}x - ${item.total.toStringAsFixed(2)} ج.م',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            secondary: item.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.image!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 40,
                        height: 40,
                        color: AppColors.background,
                        child: const Icon(
                          Icons.fastfood,
                          size: 20,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  )
                : null,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
          );
        },
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, List<XFile> images) {
    return Column(
      children: [
        if (images.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length + (images.length < 5 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == images.length) {
                  return _buildAddImageButton(context);
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(images[index].path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            final current = ref.read(issueImagesProvider);
                            ref.read(issueImagesProvider.notifier).state =
                                current.where((img) => img != images[index]).toList();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ] else ...[
          _buildAddImageButton(context, isLarge: true),
        ],
      ],
    );
  }

  Widget _buildAddImageButton(BuildContext context, {bool isLarge = false}) {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: isLarge ? double.infinity : 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              'إضافة صورة',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionOptions(BuildContext context) {
    final resolutions = [
      {'value': 'refund', 'title': 'استرداد المبلغ', 'icon': Icons.attach_money},
      {'value': 'replacement', 'title': 'استبدال العنصر', 'icon': Icons.swap_horiz},
      {'value': 'credit', 'title': 'رصيد في المحفظة', 'icon': Icons.account_balance_wallet},
      {'value': 'other', 'title': 'اقتراح آخر', 'icon': Icons.edit},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: resolutions.map((resolution) {
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                resolution['icon'] as IconData,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(resolution['title'] as String),
            ],
          ),
          selected: false,
          onSelected: (selected) {
            // Handle selection - can be enhanced with state
          },
        );
      }).toList(),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سنتواصل معك خلال 24 ساعة',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'يمكنك أيضاً التواصل معنا مباشرة على ${AppConstants.supportPhone}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowItemSelection(IssueType type) {
    return type == IssueType.missingItem ||
        type == IssueType.wrongItem ||
        type == IssueType.foodQuality;
  }

  Future<void> _pickImage() async {
    final images = ref.read(issueImagesProvider);
    if (images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الحد الأقصى 5 صور'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
                if (image != null) {
                  ref.read(issueImagesProvider.notifier).state = [...images, image];
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );
                if (image != null) {
                  ref.read(issueImagesProvider.notifier).state = [...images, image];
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitIssue(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final selectedType = ref.read(selectedIssueTypeProvider);
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار نوع المشكلة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref.read(isSubmittingIssueProvider.notifier).state = true;

    try {
      final apiService = ref.read(apiServiceProvider);
      final selectedItems = ref.read(selectedItemsProvider);
      final images = ref.read(issueImagesProvider);

      // Prepare issue data
      final issueData = {
        'orderId': widget.order.id,
        'type': selectedType.name,
        'description': _descriptionController.text.trim(),
        'affectedItems': selectedItems,
        'hasImages': images.isNotEmpty,
      };

      // Submit issue
      final response = await apiService.post(
        '${AppEndpoints.orders}/${widget.order.id}/issue',
        data: issueData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال البلاغ بنجاح. سنتواصل معك قريباً.'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
      } else {
        throw Exception(response.data['message'] ?? 'فشل إرسال البلاغ');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(isSubmittingIssueProvider.notifier).state = false;
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
